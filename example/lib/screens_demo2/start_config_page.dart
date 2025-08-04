import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class StartConfigPage extends StatefulWidget {
  final List<Map<String, dynamic>> selected;

  const StartConfigPage({super.key, required this.selected});

  @override
  State<StartConfigPage> createState() => _StartConfigPageState();
}

class _StartConfigPageState extends State<StartConfigPage> {
  Duration delay = const Duration(seconds: 0);
  Duration period = const Duration(seconds: 10);
  Duration duration = const Duration(seconds: 0);

  int flags = 0x8000;
  bool useCh0 = true;
  bool useCh1 = true;
  int checkPeriod = 0;
  int checkTrigger = 0;
  int advRate = 10;
  final List<BlueWaveDevice> _connectedDevices = [];

  final List<String> _log = [];
  bool _running = false;

  void _appendLog(String msg) {
    setState(() => _log.add(msg));
  }

  Future<void> _startMissions() async {
    setState(() => _running = true);

    for (final device in widget.selected) {
      final id = device['id'] ?? '';
      final name = device['name'] ?? '';

      try {
        _appendLog('🔎 Connecting to $name...');
        final dev = await BlueWaveDevice.connect(id);
        _connectedDevices.add(dev);

        await dev.startMission(
          delay: delay,
          frequency: period,
          duration: duration,
          flags: flags,
          checkPeriod: checkPeriod,
          checkTrigger: checkTrigger,
          advRate: advRate,
          enableCh0: useCh0,
          enableCh1: useCh1,
        );

        await dev.disconnect();
        _appendLog('✅ Mission started on $name');
        _appendLog('🔌 Disconnected');
      } catch (e) {
        _appendLog('❌ Error on $name: $e');
      }
    }

    _appendLog('✅ All missions completed');

    setState(() => _running = false);
    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
          (_) => false,
    );
  }

  @override
  void dispose() {
    BlueWaveDevice.disconnectAll(_connectedDevices);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Configure Mission')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildDurationField(
            'Delay (sec)',
            delay,
                (v) => delay = Duration(seconds: v),
          ),
          _buildDurationField(
            'Period (sec)',
            period,
                (v) => period = Duration(seconds: v),
          ),
          _buildDurationField(
            'Duration (sec)',
            duration,
                (v) => duration = Duration(seconds: v),
          ),
          _buildIntField('Flags (hex)', flags, (v) => flags = v, isHex: true),
          _buildIntField('Check Period (sec)', checkPeriod, (v) => checkPeriod = v),
          _buildIntField('Check Trigger (raw)', checkTrigger, (v) => checkTrigger = v),
          _buildIntField('Advertising Rate (x0.1s)', advRate, (v) => advRate = v),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text("Enable CH0 (RAW + USER + FACTORY)"),
            value: useCh0,
            onChanged: (val) => setState(() => useCh0 = val ?? false),
          ),
          CheckboxListTile(
            title: const Text("Enable CH1 (RAW + USER + FACTORY)"),
            value: useCh1,
            onChanged: (val) => setState(() => useCh1 = val ?? false),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _running ? null : _startMissions,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Mission'),
          ),
          const SizedBox(height: 16),
          ..._log.map(
                (l) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(l),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDurationField(String label, Duration value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: TextFormField(
            initialValue: value.inSeconds.toString(),
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(suffixText: 's'),
            onChanged: (val) {
              final v = int.tryParse(val);
              if (v != null) setState(() => onChanged(v));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIntField(String label, int value, ValueChanged<int> onChanged, {bool isHex = false}) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: isHex
                ? '0x${value.toRadixString(16).toUpperCase()}'
                : value.toString(),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(),
            onChanged: (val) {
              try {
                final parsed = isHex
                    ? int.parse(val.replaceFirst('0x', ''), radix: 16)
                    : int.parse(val);
                setState(() => onChanged(parsed));
              } catch (_) {}
            },
          ),
        ),
      ],
    );
  }
}
