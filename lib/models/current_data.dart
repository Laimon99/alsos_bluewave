import 'dart:typed_data';

/// Represents the latest available temperature and pressure data
/// retrieved from the BlueWave "Current Data" characteristic.
class CurrentData {
  final double temperature;
  final double pressure;

  const CurrentData({
    required this.temperature,
    required this.pressure,
  });

  /// Parses raw bytes from the BLE characteristic and extracts
  /// temperature and pressure values in user-calibrated format.
  factory CurrentData.fromBytes(List<int> data) {
    if (data.length < 38) {
      throw Exception('Current Data is too short (${data.length} bytes)');
    }

    final bd = ByteData.sublistView(Uint8List.fromList(data));

    // Offset 30 = temperature user-calibrated (float32)
    // Offset 34 = pressure user-calibrated (float32)
    final temp = bd.getFloat32(30, Endian.little);
    final press = bd.getFloat32(34, Endian.little);

    double safe(double v) =>
        (v.isNaN || v.isInfinite || v.abs() > 1e6) ? 0.0 : v;

    return CurrentData(
      temperature: safe(temp),
      pressure: safe(press),
    );
  }

  @override
  String toString() =>
      'CurrentData(temperature: ${temperature.toStringAsFixed(2)} °C, '
      'pressure: ${pressure.toStringAsFixed(2)} mBar)';
}
