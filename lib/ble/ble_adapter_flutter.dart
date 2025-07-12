import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:alsos_bluewave_core/ble/ble_adapter.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// Helper: confronto rapido fra il nostro `Guid` (core) e il `Guid` del
/// plugin flutter_blue_plus.
extension _GuidX on Guid {
  String get _clean =>
      value.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();

  bool matches(fbp.Guid uuid) {
    final other = uuid.str // stringa originaria
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '') // rimuovi trattini
        .toLowerCase();
    return other.startsWith(_clean); // ora combacia
  }
}

// ═══════════════════════════════════════════════════════════════════
//  BleAdapter implementato con flutter_blue_plus
// ═══════════════════════════════════════════════════════════════════
class BleAdapterFlutter implements BleAdapter {
  // Singleton canonico
  static final BleAdapterFlutter instance = BleAdapterFlutter._();
  BleAdapterFlutter._();

  //────────────────────────── SCAN ──────────────────────────//

  @override
  Stream<List<BleDevice>> scan(
      {Duration timeout = const Duration(seconds: 5)}) {
    final controller = StreamController<List<BleDevice>>.broadcast();
    final found = <String, BleDevice>{};

    unawaited(_runScan(controller, found, timeout));
    return controller.stream;
  }

  Future<void> _runScan(
    StreamController<List<BleDevice>> controller,
    Map<String, BleDevice> found,
    Duration timeout,
  ) async {
    if (!await _ensurePermissions()) {
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

    // Timer di chiusura
    await Future.delayed(timeout);
    await fbp.FlutterBluePlus.stopScan();
    await sub.cancel();
    await controller.close();
  }

  //──────────────────────── CONNECT ─────────────────────────//

  @override
  Future<BleConnection> connect(
    String deviceId, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final dev = fbp.BluetoothDevice.fromId(deviceId);
    await dev.connect(autoConnect: false, timeout: timeout);
    return _BleConnectionFlutter(dev);
  }

  //────────────────────── PERMISSIONS ──────────────────────//

  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse, // solo Android ≤ 11
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Wrapper di BleConnection per flutter_blue_plus
// ═══════════════════════════════════════════════════════════════════
class _BleConnectionFlutter implements BleConnection {
  _BleConnectionFlutter(this._device);

  final fbp.BluetoothDevice _device;
  List<fbp.BluetoothService>? _cachedSvcs;

  @override
  Future<List<Object>> services() async {
    _cachedSvcs ??= await _device.discoverServices();
    return _cachedSvcs!;
  }

  Future<void> enableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    // Verifica se la caratteristica supporta indications
    if (!chr.properties.indicate) {
      throw StateError('Characteristic does not support indications');
    }
    await chr.setNotifyValue(true);
  }

  Future<void> disableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    // Verifica se la caratteristica supporta indications
    if (!chr.properties.indicate) {
      throw StateError('Characteristic does not support indications');
    }
    await chr.setNotifyValue(false);
  }

  //────────────── I/O caratteristica ──────────────//

  Future<fbp.BluetoothCharacteristic> _findChar(Guid uuid) async {
    _cachedSvcs ??= await _device.discoverServices();
    for (final svc in _cachedSvcs!) {
      for (final chr in svc.characteristics) {
        if (uuid.matches(chr.uuid)) return chr;
      }
    }
    throw StateError('Characteristic ${uuid.value} not found');
  }

  @override
  Future<List<int>> readCharacteristic(Guid uuid) async =>
      (await _findChar(uuid)).read();

  @override
  Future<void> writeCharacteristic(
    Guid uuid,
    List<int> value, {
    bool withResponse = true,
  }) async =>
      (await _findChar(uuid)).write(value, withoutResponse: !withResponse);

  Stream<List<int>> subscribeCharacteristic(Guid uuid) async* {
    final chr = await _findChar(uuid);
    print('[DEBUG] Subscribing to characteristic ${uuid.value}');
    await chr.setNotifyValue(true);
    yield* chr.lastValueStream.map((data) {
      print('[DEBUG] Received notification (${data.length} bytes): $data');
      return data;
    }).handleError((e) {
      print('[DEBUG] Error in subscription stream: $e');
    });
  }

  @override
  Future<void> disconnect() => _device.disconnect();
}
