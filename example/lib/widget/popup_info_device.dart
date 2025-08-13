import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alsos_bluewave/alsos_bluewave.dart';

Future<void> showDeviceStatusDialog(
  BuildContext context, {
  required String deviceId,
  String? deviceName,
}) {
  return showDialog(
    context: context,
    builder: (_) => _DeviceStatusDialog(deviceId: deviceId, deviceName: deviceName),
  );
}

class _DeviceStatusDialog extends StatefulWidget {
  final String deviceId;
  final String? deviceName;

  const _DeviceStatusDialog({required this.deviceId, this.deviceName});

  @override
  State<_DeviceStatusDialog> createState() => _DeviceStatusDialogState();
}

class _DeviceStatusDialogState extends State<_DeviceStatusDialog> {
  BlueWaveDevice? _dev;                  // ⬅️ connessione viva finché il dialog è aperto
  Map<String, dynamic>? _status;
  Map<String, dynamic>? _current;
  String? _error;
  bool _loading = true;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _openAndLoad();
  }

  @override
  void dispose() {
    // chiudi la connessione quando il popup si chiude
    () async {
      try { await _dev?.disconnect(); } catch (_) {}
    }();
    super.dispose();
  }

  Future<void> _openAndLoad() async {
    setState(() { _loading = true; _error = null; _connecting = true; });

    try {
      _dev ??= await BlueWaveDevice.connect(widget.deviceId);

      final status = await _dev!.readDeviceStatus();
      final current = await _dev!.readCurrentData();

      setState(() {
        _status  = _asMap(status);
        _current = _asCurrentMap(current);
      });
    } catch (e, st) {
      debugPrint('[DeviceStatusDialog] open/load failed: $e\n$st');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() { _loading = false; _connecting = false; });
    }
  }

  Future<void> _refreshCurrent() async {
    if (_dev == null) {
      // se per qualche motivo la connessione è caduta, prova a riaprirla una volta
      await _openAndLoad();
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final current = await _dev!.readCurrentData();
      setState(() => _current = _asCurrentMap(current));
    } catch (e, st) {
      debugPrint('[DeviceStatusDialog] refresh current failed: $e\n$st');
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --------- helpers di conversione ----------
  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map) return v.cast<String, dynamic>();
    // fallback: se la libreria restituisse un oggetto con toMap()
    try {
      final m = (v as dynamic).toMap();
      if (m is Map) return m.cast<String, dynamic>();
    } catch (_) {}
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asCurrentMap(dynamic v) {
    if (v is Map) return v.cast<String, dynamic>();
    try {
      final t = (v as dynamic).temperature as num?;
      final p = (v as dynamic).pressure as num?;
      return {
        'temperature': t,
        'pressure': p,
      };
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  // --------- helpers di formattazione ----------
  String _fmtUptime(dynamic seconds) {
    if (seconds is! int) return '—';
    final d = Duration(seconds: seconds);
    String two(int v) => v.toString().padLeft(2, '0');
    if (d.inDays > 0) {
      return '${d.inDays}d ${two(d.inHours % 24)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
    }
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  // °C: taglia al 3° decimale e arrotonda al 2°
  String _fmtTemp(num? v) {
    if (v == null) return '—';
    final t3 = (v * 1000).truncateToDouble() / 1000.0;
    return t3.toStringAsFixed(2);
  }

  // mbar: taglia al 1° decimale e poi arrotonda a intero
  String _fmtMbar(num? v) {
    if (v == null) return '—';
    final t1 = (v * 10).truncateToDouble() / 10.0;
    return t1.round().toString();
  }

  String _batteryPretty(Map<String, dynamic>? sys) {
    if (sys == null) return '—';
    final mv = sys['batteryMv'];
    final total = sys['batteryTotal'];
    final used = sys['batteryUsed'];
    if (total is int && total > 0 && used is int) {
      final remaining = (100.0 * (1.0 - (used / total))).clamp(0.0, 100.0);
      return '${remaining.toStringAsFixed(0)}% (${mv ?? '—'} mV)';
    }
    if (mv is int) return '$mv mV';
    return '—';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.deviceName ?? 'Device Status';

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (_connecting) const SizedBox(width: 12),
          if (_connecting) const SizedBox(
            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: _loading
            ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
            : _error != null
                ? SizedBox(
                    height: 120,
                    child: Center(
                      child: Text('Errore: $_error', style: const TextStyle(color: Colors.red)),
                    ),
                  )
                : _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: _status == null
              ? null
              : () async {
                  final jsonStr = const JsonEncoder.withIndent('  ').convert(_status);
                  await Clipboard.setData(ClipboardData(text: jsonStr));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status copiato negli appunti')),
                    );
                  }
                },
          child: const Text('Copy JSON'),
        ),
        TextButton(
          onPressed: _loading ? null : _refreshCurrent,   // ⬅️ usa la connessione già aperta
          child: const Text('Refresh'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),   // ⬅️ in dispose() facciamo disconnect
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final status = _status ?? const {};
    final sys = (status['systemInfo'] as Map?)?.cast<String, dynamic>()
        ?? (status['sys'] as Map?)?.cast<String, dynamic>();

    final manufacturer = (status['manufacturer'] ?? '').toString();
    final modelInfo = (status['model'] ?? '').toString();
    final hwRev = (status['hwRev'] ?? '').toString();

    final modelDecoded = (sys?['model'] ?? '').toString();
    final modelKey = (sys?['modelKey'] ?? '').toString();
    final firmware = (sys?['version'] ?? sys?['firmware'] ?? '').toString();
    final serial = (sys?['serial'] ?? sys?['mac'] ?? '').toString();
    final desc = (sys?['description'] ?? '').toString();

    final flashSize = sys?['flashSize']?.toString() ?? '—';
    final e2romSize = sys?['e2romSize']?.toString() ?? '—';
    final totalAcq = sys?['totalAcq']?.toString() ?? '—';
    final uptime = _fmtUptime(sys?['uptimeSeconds']);

    final currentTemp = _fmtTemp(_current?['temperature'] as num?);
    final currentPress = _fmtMbar(_current?['pressure'] as num?);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Device Information', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _row('Manufacturer', manufacturer.isEmpty ? '—' : manufacturer),
          _row('Model', modelInfo.isEmpty ? '—' : modelInfo),
          _row('HW Rev', hwRev.isEmpty ? '—' : hwRev),
          const SizedBox(height: 12),

          const Text('System Info', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _row('Model (decoded)', modelDecoded.isEmpty ? '—' : modelDecoded),
          _row('Model key', modelKey.isEmpty ? '—' : modelKey),
          _row('Firmware', firmware.isEmpty ? '—' : firmware),
          _row('Serial/MAC', serial.isEmpty ? '—' : serial),
          _row('Description', desc.isEmpty ? '—' : desc),
          _row('Battery', _batteryPretty(sys)),
          _row('Uptime', uptime),
          _row('Flash size', flashSize),
          _row('E2ROM size', e2romSize),
          _row('Total acquisitions', totalAcq),

          const SizedBox(height: 12),
          const Text('Dati correnti', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _row('Temperatura', currentTemp == '—' ? '—' : '$currentTemp °C'),
          _row('Pressione',  currentPress == '—' ? '—' : '$currentPress mbar'),
        ],
      ),
    );
  }
}