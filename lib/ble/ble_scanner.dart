import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alsos_bluewave_core/ble/ble_adapter.dart';

const _blueWaveService = '4f4600';
const _scanTime        = Duration(seconds: 8);

class BleScanner {
  BleScanner._();
  static final instance = BleScanner._();

  /* stream pubblico – solo modelli neutri */
  final _ctrl = StreamController<List<BleDevice>>.broadcast();
  Stream<List<BleDevice>> get results => _ctrl.stream;

  final Map<String, BleDevice> _found = {};   // key = MAC / id
  bool _scanning = false;
  bool get isScanning => _scanning;

  /*──────────────────────────── scan ────────────────────────────*/
  Future<void> startScan() async {
    if (_scanning) return;
    if (!await _ensurePermissions()) return;

    _scanning = true;
    _found.clear();
    _ctrl.add(const []);

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: _scanTime);

    final sub = FlutterBluePlus.scanResults.listen((batch) {
      for (final r in batch) {
        // filtra solo BlueWave dal nome o dal service UUID
        final okName    = r.device.platformName.toUpperCase().startsWith('BLUEWAVE');
        final okService = r.advertisementData.serviceUuids
            .any((u) => u.toString().toLowerCase().startsWith(_blueWaveService));
        if (!(okName || okService)) continue;

        final id = r.device.remoteId.str;
        if (_found.containsKey(id)) continue;

        _found[id] = BleDevice(
          id:  id,
          name: r.device.platformName,
          rssi: r.rssi,
        );
        _ctrl.add(_found.values.toList());
      }
    });

    await Future.delayed(_scanTime);
    await FlutterBluePlus.stopScan();
    await sub.cancel();

    _scanning = false;
    _ctrl.add(_found.values.toList());
  }

  /*──────────────────── permissions helper ─────────────────────*/
  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,   // Android ≤ 11
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}
