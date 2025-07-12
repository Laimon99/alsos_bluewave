import 'dart:async';

import 'package:alsos_bluewave_core/models/acquisitions.dart';
import 'package:alsos_bluewave_core/models/mission_config.dart';

import '../ble/ble_adapter.dart';
import '../models/system_info.dart';
import '../uuid/bluewave_uuids.dart';
import '../models/current_data.dart'; // aggiungi questo import

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
    int flags = 0x8400,
    int options = 0x0011,
    int checkPeriod = 0,
    int checkTrigger = 0,
    int advRate = 0x0A,
  }) async {
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
      flags: 0x4000, // STOPPED
      epoch: epoch,
      time: 0,
      next: 0xFFFFFFFF,
      stop: epoch,
      options: 0x0011,
      checkPeriod: 0,
      checkTrigger: 0,
      advRate: 0x00,
    );

    await _conn.writeCharacteristic(_missionSetupChar, stopPacket.toBytes());
    print("Mission STOP sent: $stopPacket");
  }

  Future<AcquisitionInfo> downloadAcquisitions() async {
  print("Starting acquisition download...");

  final logs = <List<int>>[];

  // Step 1: Reset cursor
  await _conn.writeCharacteristic(bluewaveLogCursor, [0, 0, 0, 0, 0, 0]);

  // Step 2: Subscribe and receive blocks
  final completer = Completer<void>();
  final subscription = _conn.subscribeCharacteristic(bluewaveLogData).listen(
    (data) {
      if (data.isEmpty) return;
      if (data.length == 4 && data.every((b) => b == 0xFF)) {
        completer.complete(); // end-of-data
        return;
      }
      logs.add(data);
    },
    onError: (e) => completer.completeError(e),
  );

  final timeout = Timer(const Duration(seconds: 30), () {
    if (!completer.isCompleted) completer.complete(); // fallback timeout
  });

  await completer.future;
  await subscription.cancel();
  timeout.cancel();

  // Step 3: Parse blocks
  final parsed = Acquisitions.parseLogBlocks(logs);

  // Step 4: Return summary
  final summary = parsed.samples.map((s) {
    final time = s.timestamp.toLocal().toIso8601String().substring(11, 19);
    return "$time - CH0=${s.ch0}, CH1=${s.ch1}";
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
