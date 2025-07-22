import 'dart:async';
import 'package:alsos_bluewave_core/factory_Calibration/factory_calibration.pb.dart';
import 'package:alsos_bluewave_core/models/acquisitions.dart';
import 'package:alsos_bluewave_core/models/mission_config.dart';
import '../ble/ble_adapter.dart';
import '../models/system_info.dart';
import '../uuid/bluewave_uuids.dart';
import '../models/current_data.dart';

class BlueWaveDevice {
  final BleAdapter _adapter;
  final String id;

  late BleConnection _conn;
  late Guid _sysInfoChar;
  late Guid _charManufacturer, _charModel, _charHwRev;
  late Guid _missionSetupChar;
  late Guid _currentDataChar;

  BlueWaveDevice._internal(this._adapter, this.id);

  static Future<BlueWaveDevice> call(BleAdapter adapter, String id) async {
    final device = BlueWaveDevice._internal(adapter, id);
    await device.connect();
    return device;
  }

  /*──────────────── connect ────────────────*/
  Future<void> connect() async {
    try {
      _conn = await _adapter.connect(id);
      await _resolveGatt();
    } catch (e) {
      print("Connection failed: $e");
      rethrow; // opzionale: rilancia per gestione a livello superiore
    }
  }

  BleConnection get connection => _conn;

  /*──────────────── GATT discovery ─────────*/
  Future<void> _resolveGatt() async {
    final svcs = await _conn.services();

    Guid? findByExact(String uuid, {String? svcUuid}) {
      String extractShort(String u) {
        u = u.toLowerCase().replaceAll('-', '');
        if (u.length == 32 && u.startsWith('0000')) {
          return u.substring(4, 8);
        }
        return u;
      }

      final target = extractShort(uuid);
      final targetSvc = svcUuid != null ? extractShort(svcUuid) : null;

      for (final s in svcs) {
        final sidRaw = (s as dynamic).uuid.toString();
        final sid = extractShort(sidRaw);
        if (targetSvc != null && sid != targetSvc) continue;

        for (final c in (s as dynamic).characteristics as List<dynamic>) {
          final cidRaw = (c as dynamic).uuid.toString();
          final cid = extractShort(cidRaw);
          if (cid == target) return Guid(cidRaw);
        }
      }
      return null;
    }

    _sysInfoChar = findByExact(bluewaveSystemInfo.value) ??
        (throw StateError('System-Info characteristic not found'));

    _charManufacturer = findByExact(deviceManufacturerChar.value,
            svcUuid: deviceInfoService.value) ??
        (throw StateError('Manufacturer characteristic not found'));

    _charModel =
        findByExact(deviceModelChar.value, svcUuid: deviceInfoService.value) ??
            (throw StateError('Model characteristic not found'));

    _charHwRev =
        findByExact(deviceHwRevChar.value, svcUuid: deviceInfoService.value) ??
            (throw StateError('Hardware Revision characteristic not found'));

    _missionSetupChar = findByExact(bluewaveMissionSetup.value) ??
        (throw StateError('Mission Setup characteristic not found'));

    _currentDataChar = findByExact(bluewaveCurrentData.value) ??
        (throw StateError('Current Data characteristic not found'));
  }

  /*──────────────── API ─────────────────────*/

  Future<SystemInfo> readSystemInfo() async =>
      SystemInfo.fromBytes(await _conn.readCharacteristic(_sysInfoChar));

  Future<Map<String, String>> readDeviceInformation() async {
    final manufacturer = await _conn.readCharacteristic(_charManufacturer);
    final model = await _conn.readCharacteristic(_charModel);
    final hwRev = await _conn.readCharacteristic(_charHwRev);

    return {
      'manufacturer': String.fromCharCodes(manufacturer),
      'model': String.fromCharCodes(model),
      'hwRev': String.fromCharCodes(hwRev),
    };
  }

  /// Legge i dati correnti dal dispositivo e li converte in valori reali
  Future<CurrentData> readCurrentData() async {
    final raw = await _conn.readCharacteristic(_currentDataChar);
    return CurrentData.fromBytes(raw);
  }

  /// Starts a mission with fully customizable parameters.
  Future<void> startMission({
    required Duration delay,
    required Duration frequency,
    required Duration duration,
    int? flags,
    int checkPeriod = 0,
    required int checkTrigger,
    int? advRate,
  }) async {
    // Step 1: Leggi modello
    final info = await readSystemInfo();
    final model = info.model.toUpperCase();

    // Step 2: Decidi options
    int options = 0x0000;
    final hasT = model.contains('T');
    final hasP = model.contains('P');

    if (hasT && hasP) {
      options = 0x00AA; // ✅ CH0_USER + CH1_USER
    } else if (hasT) {
      options = 0x0020; // ✅ CH0_USER only
    } else if (hasP) {
      options = 0x0080; // ✅ CH1_USER only
    } else {
      print(
          "⚠️ Warning: modello sconosciuto '$model', usando default options = 0x0055");
      options = 0x0055;
    }

    final packet = MissionSetupPacket.fromUserInput(
      delay: delay,
      frequency: frequency,
      duration: duration,
      flags: flags,
      options: options,
      checkPeriod: checkPeriod,
      checkTrigger: checkTrigger,
      advRate: advRate,
    );

    await _conn.writeCharacteristic(_missionSetupChar, packet.toBytes());
    print("Mission START sent: $packet");
  }

  Future<void> stopMission() async {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 946684800;

    final stopPacket = MissionSetupPacket(
      start: 0xFFFFFFFF,
      period: 0,
      flags: 0x0000, // STOPPED
      epoch: epoch,
      time: 0,
      next: 0xFFFFFFFF,
      stop: epoch,
      options: 0x0000,
      checkPeriod: 0,
      checkTrigger: 0,
      advRate: 0x0A,
    );

    await _conn.writeCharacteristic(_missionSetupChar, stopPacket.toBytes());
    print("Mission STOP sent: $stopPacket");
  }

  Future<AcquisitionInfo> downloadAcquisitions() async {
    print("Starting acquisition download...");

    final logs = <List<int>>[];

    // Step 1: Reset cursor
    await _conn.writeCharacteristic(bluewaveLogCursor, [0, 0, 0, 0, 0, 0]);

    // Step 2: Read blocks one-by-one
    for (int i = 0; i < 10000; i++) {
      try {
        final data = await _conn.readCharacteristic(bluewaveLogData);

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
    final factoryRaw =
        await _conn.readCharacteristic(bluewaveFactoryConfiguration);
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

        // Prova a leggere il reference da un campo interno noto
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
    final rawFull = await _conn.readCharacteristic(bluewaveUserConfiguration);
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

    // Step 5: Parse acquired samples
    final parsed = Acquisitions.parseLogBlocks(logs, userProto, factoryProto,
        reference: reference);

    // Step 6: Build summary
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
    );
  }

  Future<Map<String, dynamic>> getFriendlyMissionStatus() async {
    final data = await _conn.readCharacteristic(_missionSetupChar);
    final packet = MissionSetupPacket.fromBytes(data);
    return packet.toUserFriendlyMap();
  }

  Future<void> disconnect() => _conn.disconnect();
}
