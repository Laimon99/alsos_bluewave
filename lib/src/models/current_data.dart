import 'dart:typed_data';

class CurrentData {
  final double temperature; // °C, 2 decimali (regola: taglia 3°, poi arrotonda 2)
  final double pressure;    // mbar, intero (regola: taglia 1°, poi arrotonda 0)

  const CurrentData({
    required this.temperature,
    required this.pressure,
  });

  static double _fmtCelsius(double v) {
    final t3 = (v * 1000).truncateToDouble() / 1000.0;
    return double.parse(t3.toStringAsFixed(2));
  }

  static int _fmtMbarInt(double v) {
    final t1 = (v * 10).truncateToDouble() / 10.0;
    return t1.round();
  }

  factory CurrentData.fromBytes(List<int> data) {
    if (data.length < 38) {
      throw Exception('Current Data is too short (${data.length} bytes)');
    }

    final bd = ByteData.sublistView(Uint8List.fromList(data));

    final tempRaw = bd.getFloat32(30, Endian.little);
    final pressRaw = bd.getFloat32(34, Endian.little);

    double safe(double v) => (v.isNaN || v.isInfinite || v.abs() > 1e6) ? 0.0 : v;

    final temp = safe(tempRaw);
    final press = safe(pressRaw);

    // Applica le regole richieste
    final tempFmt = _fmtCelsius(temp);
    final pressFmt = _fmtMbarInt(press).toDouble();

    return CurrentData(
      temperature: tempFmt,
      pressure: pressFmt,
    );
  }

  @override
  String toString() =>
      'CurrentData(temperature: ${temperature.toStringAsFixed(2)} °C, '
      'pressure: ${pressure.toStringAsFixed(0)} mBar)';
}
