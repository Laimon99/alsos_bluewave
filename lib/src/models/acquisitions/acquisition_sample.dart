class AcquisitionSample {
  final DateTime timestamp;
  final int ch0;
  final int ch1;
  final double? temperatureC;
  final double? pressuremBar;

  AcquisitionSample({
    required this.timestamp,
    required this.ch0,
    required this.ch1,
    this.temperatureC,
    this.pressuremBar,
  });

  @override
  String toString() =>
      '[$timestamp] CH0=$ch0, CH1=$ch1, T=\${temperatureC?.toStringAsFixed(2)}°C, P=\${pressuremBar?.toStringAsFixed(2)} mBar';
}