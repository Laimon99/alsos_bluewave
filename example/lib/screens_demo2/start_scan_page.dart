import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:flutter/material.dart';
import 'start_config_page.dart';

class StartScanPage extends StatefulWidget {
  const StartScanPage({super.key});

  @override
  State<StartScanPage> createState() => _StartScanPageState();
}

class _StartScanPageState extends State<StartScanPage> {
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    BlueWaveDevice.startScan();
  }

  @override
  void dispose() {
    BlueWaveDevice.stopScan(); // opzionale ma pulito
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Select device')),
    body: StreamBuilder<List<Map<String, dynamic>>>(
      stream: BlueWaveDevice.scanResults,
      initialData: const [],
      builder: (_, snap) {
        final devices = snap.data!;

        return Stack(
          children: [
            ListView.builder(
              itemCount: devices.length,
              itemBuilder: (_, i) {
                final d = devices[i];
                final deviceId = d['id'];
                final isSelected = _selected.contains(deviceId);

                final model = d['name'] ?? '';
                final vendor = d['manufacturer'] ?? '';

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (_) {
                    setState(() {
                      if (isSelected) {
                        _selected.remove(deviceId);
                      } else {
                        _selected.add(deviceId);
                      }
                    });
                  },
                  title: Text(model),
                  subtitle: Text(vendor),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                );
              },
            ),
            if (_selected.isNotEmpty)
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    final selectedDevices = devices
                        .where((d) => _selected.contains(d['id']))
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StartConfigPage(
                          selected: selectedDevices,
                        ),
                      ),
                    );
                  },
                  label: const Text('Next'),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
          ],
        );
      },
    ),
  );
}
