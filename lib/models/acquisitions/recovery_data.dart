import 'dart:typed_data';

class RecoveryData {
  final int version;
  final int size;
  final DateTime? acqFirstTime;
  final Duration frequency;
  final int acqFlags;
  final int acqOptions;
  final DateTime epoch;
  final String result;
  final DateTime? acqStop;
  final int acqCheckPeriod;
  final int acqCheckTrigger;
  final Duration advRate;

  RecoveryData({
    required this.version,
    required this.size,
    required this.acqFirstTime,
    required this.frequency,
    required this.acqFlags,
    required this.acqOptions,
    required this.epoch,
    required this.result,
    required this.acqStop,
    required this.acqCheckPeriod,
    required this.acqCheckTrigger,
    required this.advRate,
  });

  static RecoveryData fromBytes(Uint8List raw) {
    final data = ByteData.sublistView(raw);
    final baseEpoch = DateTime.utc(2000, 1, 1);

    final version = data.getUint16(4, Endian.little);
    final size = data.getUint16(6, Endian.little);

    final acqFirstTimeRaw = data.getUint32(8, Endian.little);
    final acqFirstTime = (acqFirstTimeRaw == 0xFFFFFFFF)
        ? null
        : baseEpoch.add(Duration(seconds: acqFirstTimeRaw));

    final acqPeriod = data.getUint32(12, Endian.little);
    final acqFlags = data.getUint16(16, Endian.little);
    final acqOptions = data.getUint16(18, Endian.little);

    final epochRaw = data.getUint32(20, Endian.little);
    final epoch = baseEpoch.add(Duration(seconds: epochRaw));

    final resultRaw = data.getUint32(24, Endian.little);
    final result = switch (resultRaw) {
      0xFFFFFFFF => "NOT FINISHED",
      0x00000000 => "FINISHED",
      _ => "ERROR CODE \${resultRaw.toRadixString(16)}",
    };

    final acqStopRaw = data.getUint32(28, Endian.little);
    final acqStop = (acqStopRaw == 0xFFFFFFFF)
        ? null
        : baseEpoch.add(Duration(seconds: acqStopRaw));

    final checkPeriod = data.getUint16(32, Endian.little);
    final checkTrigger = data.getUint16(34, Endian.little);
    final advRate =
        Duration(milliseconds: data.getUint16(36, Endian.little) * 100);

    return RecoveryData(
      version: version,
      size: size,
      acqFirstTime: acqFirstTime,
      frequency: Duration(seconds: acqPeriod),
      acqFlags: acqFlags,
      acqOptions: acqOptions,
      epoch: epoch,
      result: result,
      acqStop: acqStop,
      acqCheckPeriod: checkPeriod,
      acqCheckTrigger: checkTrigger,
      advRate: advRate,
    );
  }
}
