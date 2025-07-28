import 'dart:async';
import 'package:alsos_bluewave_core/ble/ble_connection.dart';
import 'package:alsos_bluewave_core/ble/ble_device.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

/// BLE adapter for scanning and connecting to devices.
class BleAdapter {
  static final BleAdapter instance = BleAdapter._();
  BleAdapter._();

  final List<BleConnection> _connections = [];

  /// Scan for nearby BLE devices.
  Stream<List<BleDevice>> scan({Duration timeout = const Duration(seconds: 5)}) {
    final controller = StreamController<List<BleDevice>>.broadcast();
    final found = <String, BleDevice>{};
    _startScan(controller, found, timeout);
    return controller.stream;
  }

  Future<void> _startScan(
    StreamController<List<BleDevice>> controller,
    Map<String, BleDevice> found,
    Duration timeout,
  ) async {
    if (!await _checkPermissions()) {
      controller.addError('BLE permissions denied');
      await controller.close();
      return;
    }

    await fbp.FlutterBluePlus.startScan(timeout: timeout);
    final sub = fbp.FlutterBluePlus.scanResults.listen((batch) {
      for (final r in batch) {
        final id = r.device.remoteId.str;
        if (found.containsKey(id)) continue;

        found[id] = BleDevice(
          id: id,
          name: r.device.platformName,
          rssi: r.rssi,
        );
        controller.add(found.values.toList(growable: false));
      }
    });

    await Future.delayed(timeout);
    await fbp.FlutterBluePlus.stopScan();
    await sub.cancel();
    await controller.close();
  }

  /// Connect to device by ID.
  Future<BleConnection> connect(String deviceId, {Duration timeout = const Duration(seconds: 20)}) async {
    final dev = fbp.BluetoothDevice.fromId(deviceId);
    try {
      await dev.connect(autoConnect: false, timeout: timeout);
    } catch (e) {
      throw Exception('Connection error with $deviceId: $e');
    }
    final conn = BleConnection(dev);
    _connections.add(conn);
    return conn;
  }

  /// Disconnect all active connections.
  Future<void> disconnectAll() async {
    for (final conn in _connections) {
      try {
        await conn.disconnect();
      } catch (_) {}
    }
    _connections.clear();
  }

  Future<bool> _checkPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}