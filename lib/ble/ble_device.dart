import 'package:alsos_bluewave_core/models/advertising.dart';

/// BLE device wrapper used in scan results.
class BleDevice {
  final String id;
  final String name;
  final int rssi;
  final Advertising? advertising;
  final String? localName;
  final String? appearance;

  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.advertising,
    this.localName,
    this.appearance,
  });
}