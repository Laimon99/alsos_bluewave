import 'dart:convert';
import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'homepage.dart';

class DownloadResultsPage extends StatefulWidget {
  final List<Map<String, dynamic>> selected; // ✅ Ora è una lista di mappe

  const DownloadResultsPage({super.key, required this.selected});

  @override
  State<DownloadResultsPage> createState() => _DownloadResultsPageState();
}

class _DownloadResultsPageState extends State<DownloadResultsPage> {
  final List<String> _log = [];
  final List<Map<String, dynamic>> _blobs = [];
  bool _running = false;
  bool debugPauseAfterStop = false;
  final List<BlueWaveDevice> _connectedDevices = [];

  void _appendLog(String msg) {
    setState(() => _log.add(msg));
  }

  Future<void> _downloadAll() async {
    setState(() {
      _running = true;
      _log.clear();
      _blobs.clear();
    });

    for (final device in widget.selected) {
      final name = device['name'] ?? '';
      final id = device['id'];

      try {
        _appendLog('Connecting to $name...');
        final dev = await BlueWaveDevice.connect(id);
        _connectedDevices.add(dev);

        _appendLog('Stopping mission on $name...');
        await dev.stopMission();

        if (debugPauseAfterStop) {
          _appendLog('10-second pause for shutdown test');
          await Future.delayed(const Duration(seconds: 10));
        }

        final blob = await dev.toMissionBlob();

        setState(() => _blobs.add(blob));
        _appendLog('Download completed for $name');
      } catch (e) {
        _appendLog('❌ Error on $name: $e');
      }
    }

    _appendLog('✅ All downloads completed');
    setState(() => _running = false);
  }

  @override
  void initState() {
    super.initState();
    _downloadAll();
  }

  @override
  void dispose() {
    BlueWaveDevice.disconnectAll(_connectedDevices);
    BlueWaveDevice.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Mission BLOBs:', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy BLOB',
            onPressed: () {
              final allBlobs = _blobs
                  .map((b) => const JsonEncoder.withIndent('  ').convert(b))
                  .join('\n\n');

              Clipboard.setData(ClipboardData(text: allBlobs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mission BLOB copied to clipboard')),
              );
            },
          ),
        ],
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_running) const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Debug pause after stop'),
              Switch(
                value: debugPauseAfterStop,
                onChanged: (v) => setState(() => debugPauseAfterStop = v),
              ),
            ],
          ),
          const Text('Operation log:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._log.map((e) => Text(e)),
          const Divider(height: 32),
          const Text('Mission BLOBs:', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: _blobs.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(_blobs[i]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Back to the Home'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
