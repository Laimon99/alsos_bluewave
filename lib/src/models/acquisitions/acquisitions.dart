import 'dart:typed_data';
import 'package:alsos_bluewave/src/models/acquisitions/acquisition_sample.dart';
import 'package:alsos_bluewave/src/models/acquisitions/parsed_acquisitions.dart';
import 'package:alsos_bluewave/src/models/acquisitions/recovery_data.dart';

class Acquisitions {
  static ParsedAcquisition parseLogBlocks(
    List<List<int>> blocks,
    dynamic userProto,
    dynamic factoryProto, {
    required double reference,
    required Map<String, dynamic> calibrators,
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

    final calibT = calibrators['T'] ?? calibrators['T1'];
    final calibP = calibrators['P'];

    for (int b = 0; b < blocks.length; b++) {
      final block = blocks[b];

      if (block.length == 4 && block.every((b) => b == 0xFF)) break;
      if (block.length <= 4) continue;

      final isFirst = b == 0;
      final payload =
          isFirst ? block.sublist(recovery.size + 4) : block.sublist(4);

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

        final tempC = calibT != null ? calibT.user(ch0) : null;
        final press =
            (calibP != null && tempC != null) ? calibP.user(ch1, tempC) : null;

        print("🌡️ T = ${tempC?.toStringAsFixed(2) ?? '---'} °C");
        print("🧪 P = ${press?.toStringAsFixed(2) ?? '---'} Bar");

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