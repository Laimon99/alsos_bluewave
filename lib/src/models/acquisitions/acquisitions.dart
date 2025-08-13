import 'dart:typed_data';
import 'package:alsos_bluewave/src/factory_calibration/factory_calibration.pb.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisition_sample.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisitions_info.dart';
import 'package:alsos_bluewave/src/models/acquisitions/parsed_acquisitions.dart';
import 'package:alsos_bluewave/src/models/acquisitions/recovery_data.dart';
import 'package:alsos_bluewave/src/models/acquisitions/calib_factory.dart';
import 'package:alsos_bluewave/src/utils/extract_from_raw.dart';

class Acquisitions {
  /// Keeps existing parse method (unchanged).
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
              "⚠️ Ignored sample #$sampleIndex → ch0=$ch0, ch1=$ch1 (null values)");
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

  
  static Future<AcquisitionInfo> downloadAcquisitions({
    required List<List<int>> logs,
    required List<int> factoryRaw,
    required List<int> userRaw,
  }) async {
    if (logs.isEmpty) {
      throw Exception("No logs: empty mission or not started.");
    }

    // 1) Extract and decode factory calibration
    print("📜 Factory raw (${factoryRaw.length} bytes):");
    final factoryData = extractFromRaw(factoryRaw) ??
        (throw Exception("⚠️ Invalid factory config (extraction failed)"));

    print("📜 Factory data (${factoryData.length} bytes):");
    print(factoryData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

    final fallbackFactoryParsers = [
      factoryConfigurationTP.fromBuffer,
      factoryConfigurationTT.fromBuffer,
      factoryConfigurationTH.fromBuffer,
      factoryConfigurationT.fromBuffer,
    ];

    double? reference;
    dynamic factoryProto;

    for (final parser in fallbackFactoryParsers) {
      try {
        print("🧪 Trying factory with ${parser.runtimeType}");
        factoryProto = parser(factoryData);

        final ch1 = (factoryProto as dynamic).calibrationCh1;
        reference = ch1.reference as double;

        print("✅ Factory decoded with ${parser.runtimeType}");
        print("🏭 Factory reference: $reference");
        break;
      } catch (e) {
        print("❌ ${parser.runtimeType} failed: $e");
      }
    }

    if (reference == null) {
      throw Exception("❌ No factory parser could decode calibration.");
    }

    // 2) Extract and decode user calibration
    print("📜 RawFull user config (${userRaw.length} bytes):");
    final calibRaw = extractFromRaw(userRaw) ??
        (throw Exception("⚠️ Invalid user calibration (extraction failed)"));

    print("📜 Raw user config (${calibRaw.length} bytes):");
    print(calibRaw.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

    try {
      final str = String.fromCharCodes(calibRaw);
      print("🔤 ASCII attempt: $str");
    } catch (_) {
      print("🔤 ASCII attempt failed");
    }

    final fallbackUserParsers = [
      userConfigurationTP.fromBuffer,
      userConfigurationTT.fromBuffer,
      userConfigurationTH.fromBuffer,
      userConfigurationT.fromBuffer,
    ];

    dynamic userProto;
    for (final parser in fallbackUserParsers) {
      try {
        print("🧪 Trying user with ${parser.runtimeType}");
        userProto = parser(calibRaw);
        print("✅ User decoded with ${parser.runtimeType}");
        print(userProto.toProto3Json());
        break;
      } catch (e) {
        print("❌ ${parser.runtimeType} failed: $e");
      }
    }

    if (userProto == null) {
      throw Exception("❌ No user parser could decode calibration.");
    }

    // 3) Build calibrators
    final calibrators = buildBlueWaveCalibrators(factoryProto, userProto);

    // 4) Parse log blocks
    final parsed = Acquisitions.parseLogBlocks(
      logs,
      userProto,
      factoryProto,
      reference: reference,
      calibrators: calibrators,
    );

    // 5) Build summary
    final summary = parsed.samples.map((s) {
      final time = s.timestamp.toLocal().toIso8601String().substring(11, 19);
      final temp = s.temperatureC?.toStringAsFixed(2) ?? '---';
      final press = s.pressuremBar?.toStringAsFixed(2) ?? '---';
      return "$time - T=$temp °C, P=$press mBar";
    }).toList();

    return AcquisitionInfo(
      summary: summary,
      status: parsed.recovery.result,
      frequency: parsed.recovery.frequency,
      startTime: parsed.recovery.acqFirstTime,
      recovery: parsed.recovery,
      parsed: parsed,
      userConfiguration: userProto,
    );
  }
}
