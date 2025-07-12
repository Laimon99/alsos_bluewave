import 'dart:typed_data';

class CurrentData {
  final double temperature;
  final double pressure;

  CurrentData({
    required this.temperature,
    required this.pressure,
  });

  /// Decodifica i bytes letti dalla caratteristica Current Data e li converte
  /// in valori reali secondo BlueWave Technical Reference.
  factory CurrentData.fromBytes(List<int> data) {
    if (data.length < 28) {
      throw Exception('Current Data troppo corto (${data.length} bytes)');
    }

    final uint8 = Uint8List.fromList(data);
    final bd = ByteData.sublistView(uint8);

    final tempRaw = bd.getFloat32(30, Endian.little);
    final pressRaw = bd.getFloat32(34, Endian.little);

    final tempUser0 = bd.getFloat32(30, Endian.little);
    final tempUser1 = bd.getFloat32(34, Endian.little);

    print('lastMeasureUser[0]: $tempUser0');
    print('lastMeasureUser[1]: $tempUser1');

    // Validazione base
    double safe(double v) => (v.isNaN || v.isInfinite || v.abs() > 1e6) ? 0 : v;

    return CurrentData(
      temperature: safe(tempRaw),
      pressure: safe(pressRaw),
    );
  }

  @override
  String toString() =>
      'CurrentData(temperature: ${temperature.toStringAsFixed(2)} °C, pressure: ${pressure.toStringAsFixed(2)} mBar)';
}
