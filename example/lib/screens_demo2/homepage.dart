import 'real_time_page.dart';
import 'start_scan_page.dart';
import 'package:flutter/material.dart';

import 'download_blob.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BlueWave Controller')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _homeButton(context, 'Start', Icons.play_arrow, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StartScanPage()),
              );
            }),
            const SizedBox(height: 20),
            _homeButton(context, 'Real Time', Icons.show_chart, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RealTimePage()),
              );
            }),
            const SizedBox(height: 20),
            _homeButton(context, 'Download', Icons.download, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadScanPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _homeButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
