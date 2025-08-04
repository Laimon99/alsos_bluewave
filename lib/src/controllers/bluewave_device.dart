import 'dart:async';
import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:alsos_bluewave/src/factory_calibration/factory_calibration.pb.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisitions.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisitions_info.dart';
import 'package:alsos_bluewave/src/models/acquisitions/calib_factory.dart';
import 'package:alsos_bluewave/src/models/guid.dart';
import 'package:alsos_bluewave/src/models/mission_blob.dart';
import 'package:alsos_bluewave/src/models/mission_config.dart';
import 'package:alsos_bluewave/src/utils/extract_from_raw.dart';
import 'package:alsos_bluewave/src/utils/get_discovery.dart';
import 'package:alsos_bluewave/src/uuid/uuids.dart';
import '../models/system_info.dart';
import '../models/current_data.dart';

/// High-level controller for interacting with a BlueWave BLE device.
/// Handles GATT discovery, mission management, data download and parsing.
class BlueWaveDevice {
  final String id;

  late final BleConnection _conn;
  late Guid _sysInfoChar;
  late Guid _charManufacturer, _charModel, _charHwRev;
  late Guid _missionSetupChar;
  late Guid _currentDataChar;

  BlueWaveDevice._internal(this.id);

  // BLE scan wrapper
  static Future<void> startScan() => BleScanner.instance.startScan();
  static Future<void> stopScan() => BleScanner.instance.stopScan();

  /// Returns a stream of discovered devices as simple maps.
  static Stream<List<Map<String, dynamic>>> get scanResults =>
      BleScanner.instance.results.map((devices) {
        return devices.map((d) {
          final f = d.advertising?.toFriendlyMap();
          return {
            'id': d.id,
            'name': d.name,
            'manufacturer': d.advertising?.manufacturer,
            'status': f?['status'],
            'measurements': f?['measurements'],
          };
        }).toList();
      });

  /// Connects to a BlueWave device using its ID only.
  /// Automatically uses BleAdapter.instance internally.
  static Future<BlueWaveDevice> connect(String id) async {
    final adapter = BleAdapter.instance;
    final device = BlueWaveDevice._internal(id);

    try {
      // Establish BLE connection
      device._conn = await adapter.connect(id);

      // Resolve characteristics and assign them
      await resolveGattCharacteristics(device._conn, assign: (uuidMap) {
        device._sysInfoChar = uuidMap['sysInfo']!;
        device._charManufacturer = uuidMap['manufacturer']!;
        device._charModel = uuidMap['model']!;
        device._charHwRev = uuidMap['hwRev']!;
        device._missionSetupChar = uuidMap['mission']!;
        device._currentDataChar = uuidMap['current']!;
      });
    } catch (e) {
      print("Connection failed: $e");
      rethrow;
    }

    return device;
  }

  /// Disconnects the device.
  Future<void> disconnect() => _conn.disconnect();

  /// Disconnects a list of BlueWaveDevice instances.
  static Future<void> disconnectAll(List<BlueWaveDevice> devices) async {
    for (final d in devices) {
      try {
        await d.disconnect();
      } catch (_) {}
    }
  }

  /// Reads system metadata.
  Future<SystemInfo> readSystemInfo() async {
    final data = await _conn.read(_sysInfoChar);
    return SystemInfo.fromBytes(data);
  }

  /// Reads manufacturer, model and hardware revision.
  Future<Map<String, String>> readDeviceInformation() async {
    final manufacturer = await _conn.read(_charManufacturer);
    final model = await _conn.read(_charModel);
    final hwRev = await _conn.read(_charHwRev);
    return {
      'manufacturer': String.fromCharCodes(manufacturer),
      'model': String.fromCharCodes(model),
      'hwRev': String.fromCharCodes(hwRev),
    };
  }

  /// Reads current measurement values from the device.
  Future<CurrentData> readCurrentData() async {
    final raw = await _conn.read(_currentDataChar);
    return CurrentData.fromBytes(raw);
  }

  /// Starts a logging mission on the device.
  Future<void> startMission({
    required Duration delay,
    required Duration frequency,
    required Duration duration,
    int flags = 0x8000,
    int checkPeriod = 0,
    required int checkTrigger,
    int? advRate,
    required bool enableCh0,
    required bool enableCh1,
  }) async {
    final packet = MissionSetupPacket.fromUserInput(
      delay: delay,
      frequency: frequency,
      duration: duration,
      flags: flags,
      enableCh0: enableCh0,
      enableCh1: enableCh1,
      checkPeriod: checkPeriod,
      checkTrigger: checkTrigger,
      advRate: advRate,
    );
    await _conn.write(_missionSetupChar, packet.toBytes());
    print("Mission START sent: $packet");
  }

  /// Stops the current mission.
  Future<void> stopMission() async {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 946684800;
    final stopPacket = MissionSetupPacket(
      start: 0xFFFFFFFF,
      period: 0,
      flags: 0,
      epoch: epoch,
      time: 0,
      next: 0xFFFFFFFF,
      stop: epoch,
      options: 0,
      checkPeriod: 0,
      checkTrigger: 0,
      advRate: 0x0A,
    );
    await _conn.write(_missionSetupChar, stopPacket.toBytes());
    print("Mission STOP sent: $stopPacket");
  }

  Future<AcquisitionInfo> downloadAcquisitions() async {
    print("Starting acquisition download...");

    final logs = <List<int>>[];

    // Step 1: Reset cursor
    await _conn.write(bluewaveLogCursor, [0, 0, 0, 0, 0, 0]);

    // Step 2: Read blocks one-by-one
    for (int i = 0; i < 10000; i++) {
      try {
        final data = await _conn.read(bluewaveLogData);

        if (data.isEmpty) {
          print("⚠️ Pacchetto vuoto ignorato");
          continue;
        }

        if (data.every((b) => b == 0xFF)) {
          print("✅ Fine dati (pacchetto = solo 0xFF)");
          break;
        }

        logs.add(data);
      } catch (e) {
        print("❌ Errore durante lettura pacchetto $i: $e");
        break;
      }

      await Future.delayed(const Duration(milliseconds: 20));
    }

    if (logs.isEmpty) {
      throw Exception("Nessun dato acquisito: missione vuota o non avviata.");
    }

    // Step 3: Read and decode factory calibration
    final factoryRaw = await _conn.read(bluewaveFactoryConfiguration);
    print("📜 Factory raw (${factoryRaw.length} bytes):");

    final factoryData = extractFromRaw(factoryRaw) ??
        (throw Exception("⚠️ Factory config non valida (estrazione fallita)"));

    print("📜 Factory data (${factoryData.length} bytes):");
    print(
        factoryData.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

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
        print("🧪 Tentativo factory con ${parser.runtimeType}");
        factoryProto = parser(factoryData);

        final ch1 = (factoryProto as dynamic).calibrationCh1;
        reference = ch1.reference as double;

        print("✅ Decoding riuscito con ${parser.runtimeType}");
        print("🏭 Factory reference: $reference");
        break;
      } catch (e) {
        print("❌ ${parser.runtimeType} fallito: $e");
      }
    }

    if (reference == null) {
      throw Exception(
          "❌ Nessun parser ha decodificato la calibrazione factory.");
    }

    // Step 4: Parse user calibration
    final rawFull = await _conn.read(bluewaveUserConfiguration);
    print("📜 RawFull user config (${rawFull.length} bytes):");

    final calibRaw = extractFromRaw(rawFull) ??
        (throw Exception(
            "⚠️ User calibration data non valido (estrazione fallita)"));

    print("📜 Raw user config (${calibRaw.length} bytes):");
    print(calibRaw.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

    try {
      final str = String.fromCharCodes(calibRaw);
      print("🔤 Interpretazione ASCII: $str");
    } catch (_) {
      print("🔤 Interpretazione ASCII non riuscita");
    }

    final fallbackParsers = [
      userConfigurationTP.fromBuffer,
      userConfigurationTT.fromBuffer,
      userConfigurationTH.fromBuffer,
      userConfigurationT.fromBuffer,
    ];

    dynamic userProto;
    for (final parser in fallbackParsers) {
      try {
        print("🧪 Tentativo con ${parser.runtimeType}");
        userProto = parser(calibRaw);
        print("✅ Decoding riuscito con ${parser.runtimeType}");
        print(userProto.toProto3Json());
        break;
      } catch (e) {
        print("❌ ${parser.runtimeType} fallito: $e");
      }
    }

    if (userProto == null) {
      throw Exception(
          "❌ Nessun parser ha decodificato la calibrazione utente.");
    }

    // Step 5: Build calibrators
    final calibrators = buildBlueWaveCalibrators(factoryProto, userProto);

    // Step 6: Parse acquired samples
    final parsed = Acquisitions.parseLogBlocks(
      logs,
      userProto,
      factoryProto,
      reference: reference,
      calibrators: calibrators,
    );

    // Step 7: Build summary
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

  Future<Map<String, dynamic>> toMissionBlob() {
    return MissionBlobBuilder(this).build();
  }

  //-----------------------------------------------------------------------------------------------------------------------------//
}
