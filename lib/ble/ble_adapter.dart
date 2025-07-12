import 'dart:async';

class Guid {
  final String value;
  const Guid(this.value);
  int? get short =>
      value.length >= 8 ? int.tryParse(value.substring(4, 8), radix: 16) : null;
  @override
  String toString() => value;
}

class BleDevice {
  final String id;
  final String name;
  final int rssi;

  BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}

abstract class BleConnection {
  Future<void> disconnect();
  Future<List<Object>> services();
  Future<List<int>> readCharacteristic(Guid charUuid);
  Future<void> writeCharacteristic(Guid charUuid, List<int> value,
      {bool withResponse = true});
  Stream<List<int>> subscribeCharacteristic(Guid charUuid);
  Future<void> enableIndications(
    Guid charUuid,
  );
  Future<void> disableIndications(
    Guid charUuid,
  );
}

abstract class BleAdapter {
  Stream<List<BleDevice>> scan({Duration timeout = const Duration(seconds: 5)});
  Future<BleConnection> connect(
    String deviceId, {
    Duration timeout = const Duration(seconds: 20),
  });
}

class BleAdapterDefault {
  static late BleAdapter instance;
}
