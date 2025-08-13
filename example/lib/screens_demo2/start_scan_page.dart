import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:alsos_bluewave_app/widget/popup_info_device.dart';
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
    BlueWaveDevice.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Select device')),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: BlueWaveDevice.scanResults,
          initialData: const [],
          builder: (_, snap) {
            final devices = snap.data ?? const <Map<String, dynamic>>[];

            return Stack(
              children: [
                ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (_, i) {
                    final d = devices[i];
                    final deviceId = (d['id'] ?? '').toString();
                    final isSelected = _selected.contains(deviceId);

                    final model = (d['name'] ?? d['model'] ?? '').toString();
                    final vendor = (d['manufacturer'] ?? '').toString();

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
                      title: Text(model.isEmpty ? 'Unknown device' : model),
                      subtitle: Text(vendor),
                      controlAffinity: ListTileControlAffinity.leading,

                      // ⬇️ icona info (solo questa apre il popup)
                      secondary: IconButton.filledTonal(
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Dettagli / Live',
                        onPressed: deviceId.isEmpty
                            ? null
                            : () => showDeviceStatusDialog(
                                  context,
                                  deviceId: deviceId,
                                  deviceName: model,
                                ),
                      ),

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
                        // 1) Keep only the selected devices
                        final selectedDevices = devices
                            .where((d) =>
                                _selected.contains((d['id'] ?? '').toString()))
                            .toList();

                        // 2) Build 'models' from selected devices (name OR model field)
                        final models = selectedDevices
                            .map((d) =>
                                (d['name'] ?? d['model'] ?? '').toString())
                            .where((s) => s.isNotEmpty)
                            .toSet() // dedupe
                            .toList();

                        debugPrint('[StartScanPage] selected devices: '
                            '${selectedDevices.map((d) => d['name']).toList()}');
                        debugPrint('[StartScanPage] models: $models');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StartConfigPage(
                              selected: selectedDevices,
                              models: models,
                            ),
                          ),
                        );
                      },
                      label: Text('Next (${_selected.length})'),
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
              ],
            );
          },
        ),
      );
}
