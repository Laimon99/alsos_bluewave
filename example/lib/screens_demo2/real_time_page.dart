import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:alsos_bluewave_app/widget/popup_info_device.dart';
import 'package:flutter/material.dart';

class RealTimePage extends StatefulWidget {
  const RealTimePage({super.key});

  @override
  State<RealTimePage> createState() => _RealTimePageState();
}

class _RealTimePageState extends State<RealTimePage> {
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

  Color _statusColor(String status) {
    switch (status) {
      case 'RUNNING':
        return Colors.green;
      case 'STOPPED':
        return Colors.red;
      case 'WAITING TRIGGER':
        return Colors.orange;
      case 'MEM FULL':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Real Time Devices')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Start Scan'),
                onPressed: () => BlueWaveDevice.startScan(),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: BlueWaveDevice.scanResults,
                initialData: const [],
                builder: (_, snap) {
                  final devices = snap.data ?? const [];

                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (_, i) {
                      final d = devices[i];
                      final id = (d['id'] ?? '').toString();
                      final name = (d['name'] ?? '').toString();
                      final manufacturer = (d['manufacturer'] ?? '').toString();
                      final status = (d['status'] ?? '—').toString();
                      final measures = (d['measurements'] ?? '').toString();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Stack(
                          children: [
                            // contenuto
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 56, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.memory_outlined,
                                      color: _statusColor(status)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 2),
                                        Text('Manufacturer: $manufacturer'),
                                        if (status != '—')
                                          Text('State: $status'),
                                        if (measures.isNotEmpty)
                                          Text(measures),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // icona tappabile SOLO in basso a destra
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: IconButton.filledTonal(
                                tooltip: 'Dettagli / Live',
                                icon: const Icon(Icons.info_outline),
                                onPressed: id.isEmpty
                                    ? null
                                    : () => showDeviceStatusDialog(
                                          context,
                                          deviceId: id,
                                          deviceName: name,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
}
