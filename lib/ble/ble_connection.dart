import '../models/guid.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

/// Connection to a single BLE device.
class BleConnection {
  final fbp.BluetoothDevice _device;
  List<fbp.BluetoothService>? _cachedSvcs;

  BleConnection(this._device);

  Future<void> disconnect() => _device.disconnect();

  Future<List<Object>> services() async {
    _cachedSvcs ??= await _device.discoverServices();
    return _cachedSvcs!;
  }

  Future<List<int>> read(Guid uuid) async => (await _findChar(uuid)).read();

  Future<void> write(Guid uuid, List<int> value, {bool withResponse = true}) async {
    final chr = await _findChar(uuid);
    await chr.write(value, withoutResponse: !withResponse);
  }

  Stream<List<int>> subscribe(Guid uuid) async* {
    final chr = await _findChar(uuid);
    await chr.setNotifyValue(true);
    yield* chr.lastValueStream;
  }

  Future<void> enableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    if (!chr.properties.indicate) throw StateError('Indications not supported');
    await chr.setNotifyValue(true);
  }

  Future<void> disableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    if (!chr.properties.indicate) throw StateError('Indications not supported');
    await chr.setNotifyValue(false);
  }

  Future<fbp.BluetoothCharacteristic> _findChar(Guid uuid) async {
    _cachedSvcs ??= await _device.discoverServices();
    for (final svc in _cachedSvcs!) {
      for (final chr in svc.characteristics) {
        if (uuid.matchesFlutter(chr.uuid)) return chr;
      }
    }
    throw StateError('Characteristic ${uuid.value} not found');
  }
}