import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class StartConfigPage extends StatefulWidget {
  final List<Map<String, dynamic>> selected;
  final List<dynamic>
  models; // kept for compatibility, but we will rebuild from 'selected'

  const StartConfigPage({
    super.key,
    required this.selected,
    required this.models,
  });

  @override
  State<StartConfigPage> createState() => _StartConfigPageState();
}

class _StartConfigPageState extends State<StartConfigPage> {
  // Core mission parameters
  Duration delay = const Duration(seconds: 0);
  Duration period = const Duration(seconds: 10);
  Duration duration = const Duration(seconds: 0);

  int flags = 0x8000; // default STARTED bit
  int checkPeriod = 0;
  int checkTrigger = 0;
  int? advRate = 10; // nullable: only used if supported

  // Per-channel options
  bool ch0Raw = false;
  bool ch0Factory = false;
  bool ch0User = false;
  bool ch1Raw = false;
  bool ch1Factory = false;
  bool ch1User = false;

  // Capabilities-driven form
  Map<String, Map<String, dynamic>> _cfg = {};
  bool _capabilitiesLoaded = false;

  final List<BlueWaveDevice> _connectedDevices = [];
  final List<String> _log = [];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    try {
      // Build names from actually selected devices (advertised names)
      final lookupNames = widget.selected
          .map((d) => (d['name'] ?? d['model'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet() // dedupe
          .toList();

      // Fallback to provided models (as strings) if selection has no names
      final models = lookupNames.isNotEmpty
          ? lookupNames
          : widget.models.map((e) => e.toString()).toList();

      debugPrint('[StartConfigPage] capability lookup names: $models');

      // ✅ Pass the names list (not a single "name" var)
      final cfg = await BlueWaveDevice.getMissionConfig(models);

      if (!mounted) return;
      setState(() {
        _cfg = cfg;
        _capabilitiesLoaded = true;

        debugPrint(
          '[StartConfigPage] supported keys: ${_cfg.keys.toList()..sort()}',
        );

        // If advRate is not supported, keep it null so we won't send it
        if (!_supports('advRate')) {
          advRate = null;
        }

        // Sensible defaults
        if (_supports('enableCh0Raw')) ch0Raw = true;
        if (_supports('enableCh0Factory')) ch0Factory = true;
        if (_supports('enableCh0User')) ch0User = false;

        // CH1 defaults off; l'utente li abilita se serve
        ch1Raw = false;
        ch1Factory = false;
        ch1User = false;
      });
    } catch (e) {
      _appendLog('⚠️ Capabilities load failed: $e');
      setState(() {
        _capabilitiesLoaded = true;
      });
    }
  }

  bool _supports(String id) => _cfg.containsKey(id);

  void _appendLog(String msg) {
    setState(() => _log.add(msg));
  }

  Future<void> _startMissions() async {
    setState(() => _running = true);

    for (final device in widget.selected) {
      final id = (device['id'] ?? '').toString();
      final name = (device['name'] ?? '').toString();

      try {
        _appendLog('🔎 Connecting to $name...');
        final dev = await BlueWaveDevice.connect(id);
        _connectedDevices.add(dev);

        // Gate by capability
        final bool useCh0Raw = _supports('enableCh0Raw') && ch0Raw;
        final bool useCh0Factory = _supports('enableCh0Factory') && ch0Factory;
        final bool useCh0User = _supports('enableCh0User') && ch0User;

        final bool useCh1Raw = _supports('enableCh1Raw') && ch1Raw;
        final bool useCh1Factory = _supports('enableCh1Factory') && ch1Factory;
        final bool useCh1User = _supports('enableCh1User') && ch1User;

        final int safeCheckTrigger = _supports('startOnChannel')
            ? checkTrigger
            : 0;
        final int safeCheckPeriod = _supports('checkPeriod') ? checkPeriod : 0;
        final int? safeAdvRate = _supports('advRate') ? advRate : null;

        debugPrint(
          '[StartConfigPage] sending to $name -> '
          'delay=${delay.inSeconds}s, period=${period.inSeconds}s, duration=${duration.inSeconds}s, '
          'flags=0x${flags.toRadixString(16).toUpperCase()}, '
          'checkPeriod=$safeCheckPeriod, checkTrigger=$safeCheckTrigger, advRate=${safeAdvRate ?? 'null'}, '
          'ch0Raw=$useCh0Raw, ch0Factory=$useCh0Factory, ch0User=$useCh0User, '
          'ch1Raw=$useCh1Raw, ch1Factory=$useCh1Factory, ch1User=$useCh1User',
        );

        await dev.startMission(
          delay: delay,
          frequency: period,
          duration: duration,
          flags: flags,
          checkPeriod: safeCheckPeriod,
          checkTrigger: safeCheckTrigger,
          advRate: safeAdvRate,
          ch0Raw: useCh0Raw,
          ch0Factory: useCh0Factory,
          ch0User: useCh0User,
          ch1Raw: useCh1Raw,
          ch1Factory: useCh1Factory,
          ch1User: useCh1User,
          modelHint: name,
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
    BlueWaveDevice.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Mission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _capabilitiesLoaded
            ? ListView(
                children: [
                  if (_supports('delay'))
                    _buildDurationField(
                      'Delay (sec)',
                      delay,
                      (v) => delay = Duration(seconds: v),
                    ),
                  if (_supports('frequency'))
                    _buildDurationField(
                      'Period (sec)',
                      period,
                      (v) => period = Duration(seconds: v),
                    ),
                  if (_supports('duration'))
                    _buildDurationField(
                      'Duration (sec)',
                      duration,
                      (v) => duration = Duration(seconds: v),
                    ),

                  _buildIntField(
                    'Flags (hex)',
                    flags,
                    (v) => flags = v,
                    isHex: true,
                  ),

                  if (_supports('checkPeriod'))
                    _buildIntField(
                      'Check Period (sec)',
                      checkPeriod,
                      (v) => checkPeriod = v,
                    ),

                  if (_supports('startOnChannel'))
                    _buildIntField(
                      'Check Trigger (raw)',
                      checkTrigger,
                      (v) => checkTrigger = v,
                    ),

                  if (_supports('advRate'))
                    _buildIntField(
                      'Advertising Rate (x0.1s)',
                      (advRate ?? 0),
                      (v) => advRate = v,
                    ),

                  const SizedBox(height: 12),

                  // Channel 0
                  if (_supports('enableCh0Raw') ||
                      _supports('enableCh0Factory') ||
                      _supports('enableCh0User'))
                    _buildChannelGroup(
                      title: 'Channel 0',
                      rows: [
                        if (_supports('enableCh0Raw'))
                          _buildToggleRow(
                            'Record RAW (CH0)',
                            ch0Raw,
                            (v) => setState(() => ch0Raw = v),
                          ),
                        if (_supports('enableCh0Factory'))
                          _buildToggleRow(
                            'Advertise FACTORY (CH0)',
                            ch0Factory,
                            (v) => setState(() => ch0Factory = v),
                          ),
                        if (_supports('enableCh0User'))
                          _buildToggleRow(
                            'Advertise USER (CH0)',
                            ch0User,
                            (v) => setState(() => ch0User = v),
                          ),
                      ],
                    ),

                  // Channel 1
                  if (_supports('enableCh1Raw') ||
                      _supports('enableCh1Factory') ||
                      _supports('enableCh1User'))
                    _buildChannelGroup(
                      title: 'Channel 1',
                      rows: [
                        if (_supports('enableCh1Raw'))
                          _buildToggleRow(
                            'Record RAW (CH1)',
                            ch1Raw,
                            (v) => setState(() => ch1Raw = v),
                          ),
                        if (_supports('enableCh1Factory'))
                          _buildToggleRow(
                            'Advertise FACTORY (CH1)',
                            ch1Factory,
                            (v) => setState(() => ch1Factory = v),
                          ),
                        if (_supports('enableCh1User'))
                          _buildToggleRow(
                            'Advertise USER (CH1)',
                            ch1User,
                            (v) => setState(() => ch1User = v),
                          ),
                      ],
                    ),

                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _running ? null : _startMissions,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Mission'),
                  ),
                  const SizedBox(height: 16),

                  // Debug area (optional)
                  if (_cfg.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Supported fields: ${(_cfg.keys.toList()..sort()).join(', ')}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                  ..._log.map(
                    (l) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(l),
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // ---- UI helpers ----

  Widget _buildDurationField(
    String label,
    Duration value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
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

  Widget _buildIntField(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    bool isHex = false,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 160,
          child: TextFormField(
            initialValue: isHex
                ? '0x${value.toRadixString(16).toUpperCase()}'
                : value.toString(),
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(),
            onChanged: (val) {
              try {
                final parsed = isHex
                    ? int.parse(
                        val.replaceFirst(
                          RegExp(r'^0x', caseSensitive: false),
                          '',
                        ),
                        radix: 16,
                      )
                    : int.parse(val);
                setState(() => onChanged(parsed));
              } catch (_) {}
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChannelGroup({
    required String title,
    required List<Widget> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...rows,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: (val) => onChanged(val),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
