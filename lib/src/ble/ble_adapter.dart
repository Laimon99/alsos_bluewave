import 'dart:async';
import 'dart:io' show Platform;
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:collection/collection.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ble_device.dart';
import 'ble_connection.dart';

class BleAdapter {
  static final BleAdapter instance = BleAdapter._();
  BleAdapter._();

  final List<BleConnection> _connections = [];

  Stream<List<BleDevice>> scan({Duration timeout = const Duration(seconds: 5)}) {
    final controller = StreamController<List<BleDevice>>.broadcast();
    final found = <UUID, BleDevice>{};
    _startScan(controller, found, timeout);
    return controller.stream;
  }

  Future<void> _startScan(
    StreamController<List<BleDevice>> controller,
    Map<UUID, BleDevice> found,
    Duration timeout,
  ) async {
    if (!await _ensurePermissions()) {
      controller.addError('BLE permissions denied');
      await controller.close();
      return;
    }

    final manager = CentralManager();
    final state = await manager.state;
    if (state != BluetoothLowEnergyState.poweredOn) {
      controller.addError('Bluetooth is not powered on');
      await controller.close();
      return;
    }

    final sub = manager.discovered.listen((event) {
      final peripheral = event.peripheral;
      final id = peripheral.uuid;
      if (found.containsKey(id)) return;

      final name = event.advertisement.name ?? 'Unknown';
      final rssi = event.rssi;

      found[id] = BleDevice(
        id: id.toString(),
        name: name,
        rssi: rssi,
      );
      controller.add(found.values.toList(growable: false));
    });

    await manager.startDiscovery();
    await Future.delayed(timeout);
    await manager.stopDiscovery();
    await sub.cancel();
    await controller.close();
  }

  Future<BleConnection> connect(String deviceId,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final manager = CentralManager();
    final peripherals = await manager.retrieveConnectedPeripherals();
    Peripheral? peripheral = peripherals.firstWhereOrNull(
      (p) => p.uuid.toString() == deviceId,
    );

    if (peripheral == null) {
      final discoveries = <DiscoveredEventArgs>[];
      final sub = manager.discovered.listen(discoveries.add);
      await manager.startDiscovery();
      await Future.delayed(timeout);
      await manager.stopDiscovery();
      await sub.cancel();

      peripheral = discoveries
          .map((e) => e.peripheral)
          .firstWhereOrNull((p) => p.uuid.toString() == deviceId);

      if (peripheral == null) {
        throw Exception('Peripheral $deviceId not found');
      }
    }

    await manager.connect(peripheral);
    final conn = BleConnection(peripheral);
    _connections.add(conn);
    return conn;
  }

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 31) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      return statuses.values.every((s) => s.isGranted);
    }

    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      print('⚠️ Location permission not granted.');
      return false;
    }

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}
