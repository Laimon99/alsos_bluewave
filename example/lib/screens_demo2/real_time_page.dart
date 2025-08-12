import 'package:alsos_bluewave/alsos_bluewave.dart';
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
  void dispose() {
    BlueWaveDevice.stopScan();
    super.dispose();
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
              final devices = snap.data!;

              return ListView.builder(
                itemCount: devices.length,
                itemBuilder: (_, i) {
                  final device = devices[i];

                  final name = device['name'] ?? '';
                  final manufacturer = device['manufacturer'] ?? '';
                  final status = device['status'] ?? '—';
                  final measures = device['measurements'] ?? '';

                  return ListTile(
                    leading: Icon(Icons.memory_outlined,
                        color: _statusColor(status)),
                    title: Text(name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manufacturer: $manufacturer'),
                        if (status != '—') Text('State: $status'),
                        if (measures.toString().isNotEmpty)
                          Text(measures),
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
