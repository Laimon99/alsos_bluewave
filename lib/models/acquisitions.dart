import 'dart:typed_data';
import 'package:alsos_bluewave_core/models/calibrations.dart';
import 'package:alsos_bluewave_core/factory_Calibration/factory_calibration.pb.dart';

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

class ParsedAcquisition {
  final RecoveryData recovery;
  final List<AcquisitionSample> samples;

  ParsedAcquisition({
    required this.recovery,
    required this.samples,
  });
}

class Acquisitions {
  static ParsedAcquisition parseLogBlocks(
    List<List<int>> blocks,
    dynamic userProto,
    dynamic factoryProto, {
    required double reference,
  }) {
    if (blocks.isEmpty) {
      throw Exception("No data blocks provided");
    }

    final first = Uint8List.fromList(blocks.first);
    final recovery = RecoveryData.fromBytes(first);

    final allSamples = <AcquisitionSample>[];

    DateTime? startTime = recovery.acqFirstTime;
    if (startTime == null) {
      print("⚠️ acqFirstTime is null, cannot assign timestamps to samples.");
      return ParsedAcquisition(recovery: recovery, samples: []);
    }

    int sampleIndex = 0;

    final calibT =
        BlueWaveTcalib(factoryProto.calibrationCh1, userProto.calibrationCh1);
    final calibP = BlueWavePcalib(factoryProto.calibrationCh2);

    for (int b = 0; b < blocks.length; b++) {
      final block = blocks[b];

      if (block.length == 4 && block.every((b) => b == 0xFF)) break;
      if (block.length <= 4) continue;

      final isFirst = b == 0;
      final payload =
          isFirst ? block.sublist(recovery.size + 4) : block.sublist(4);

      print(
          "🔧 Factory T calib coeffs: ${factoryProto.calibrationCh1.coefficients}");
      print(
          "🔧 Factory P calib coeffs: ${factoryProto.calibrationCh2.polyList.map((p) => p.coefficients)}");

      for (int i = 0; i + 3 < payload.length; i += 4) {
        final ch0 = payload[i] + (payload[i + 1] << 8); // little-endian
        final ch1 = payload[i + 2] + (payload[i + 3] << 8); // little-endian

        if (ch0 == 0xFFFF && ch1 == 0xFFFF) {
          print(
              "⚠️ Ignorato sample #$sampleIndex → ch0=$ch0, ch1=$ch1 (valori nulli)");
          sampleIndex++;
          continue;
        }

        final timestamp = startTime.add(recovery.frequency * sampleIndex);
        print("✅ Sample #$sampleIndex | ch0=$ch0 | ch1=$ch1");

        final tempC = calibT.user(ch0);
        final press = calibP.user(ch1, tempC);

        print("🌡️ T = ${tempC.toStringAsFixed(2)} °C");
        print("🧪 P = ${press.toStringAsFixed(2)} Bar");

        allSamples.add(
          AcquisitionSample(
            timestamp: timestamp,
            ch0: ch0,
            ch1: ch1,
            temperatureC: tempC,
            pressuremBar: press,
          ),
        );
        sampleIndex++;
      }
    }

    return ParsedAcquisition(recovery: recovery, samples: allSamples);
  }
}

class AcquisitionInfo {
  final List<String> summary;
  final String? status;
  final Duration? frequency;
  final DateTime? startTime;
  final RecoveryData recovery;

  AcquisitionInfo({
    required this.summary,
    required this.recovery,
    this.status,
    this.frequency,
    this.startTime,
  });
}

List<int>? extractFromRaw(List<int> raw) {
  if (raw.length < 8) return null;

  final tag = raw[2] + (raw[3] << 8);
  final length = raw[6] + (raw[7] << 8);

  if (length > 504) return null;

  if (tag != 0xBEBA && tag != 0xFECA) return null;

  return raw.sublist(8, 8 + length);
}
