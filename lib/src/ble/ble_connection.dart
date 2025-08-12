import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import '../models/guid.dart';

class BleConnection {
  final Peripheral _peripheral;
  final CentralManager _manager = CentralManager();
  List<GATTService>? _cachedSvcs;

  BleConnection(this._peripheral);

  Future<void> disconnect() => _manager.disconnect(_peripheral);

  Future<List<GATTService>> services() async {
    _cachedSvcs ??= await _manager.discoverGATT(_peripheral);
    return _cachedSvcs!;
  }

  Future<List<int>> read(Guid uuid) async {
    final chr = await _findChar(uuid);
    return _manager.readCharacteristic(_peripheral, chr);
  }

  Future<void> write(Guid uuid, List<int> value,
      {bool withResponse = true}) async {
    final chr = await _findChar(uuid);
    final type = withResponse
        ? GATTCharacteristicWriteType.withResponse
        : GATTCharacteristicWriteType.withoutResponse;

    await _manager.writeCharacteristic(
      _peripheral,
      chr,
      value: Uint8List.fromList(value),
      type: type,
    );
  }

  Stream<List<int>> subscribe(Guid uuid) async* {
    final chr = await _findChar(uuid);
    await _manager.setCharacteristicNotifyState(_peripheral, chr, state: true);

    yield* _manager.characteristicNotified
        .where((e) => e.peripheral == _peripheral && e.characteristic == chr)
        .map((e) => e.value);
  }

  Future<void> enableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    if (!chr.properties.contains(GATTCharacteristicProperty.indicate)) {
      throw StateError('Indications not supported');
    }
    await _manager.setCharacteristicNotifyState(_peripheral, chr, state: true);
  }

  Future<void> disableIndications(Guid uuid) async {
    final chr = await _findChar(uuid);
    if (!chr.properties.contains(GATTCharacteristicProperty.indicate)) {
      throw StateError('Indications not supported');
    }
    await _manager.setCharacteristicNotifyState(_peripheral, chr, state: false);
  }

  Future<GATTCharacteristic> _findChar(Guid uuid) async {
    _cachedSvcs ??= await _manager.discoverGATT(_peripheral);

    for (final svc in _cachedSvcs!) {
      for (final chr in svc.characteristics) {
        if (uuid.matchesFlutter(chr.uuid)) {
          return chr;
        }
      }
    }
    throw StateError('Characteristic ${uuid.value} not found');
  }
}
