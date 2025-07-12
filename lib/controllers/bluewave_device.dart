import 'dart:async';

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

  Future<List<List<int>>> downloadAcquisitions() async {
    print("Starting acquisition download...");

    final logCursorChar = bluewaveLogCursor;
    final logDataChar = bluewaveLogData;

    final logs = <List<int>>[];

    final completer = Completer<void>();
    Timer? globalTimeout;

    final subscription = _conn.subscribeCharacteristic(logDataChar).listen(
      (data) {
        print("Received log block ${data.length} bytes:");
        final hex =
            data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ');
        print("DATA HEX: $hex");

        // Ignore empty packets
        if (data.isEmpty) {
          print("Empty packet skipped");
          return;
        }

        // Check for EOF
        if (data.length == 4 && data.every((b) => b == 0xFF)) {
          print("EOF block received, ending download");
          if (!completer.isCompleted) completer.complete();
          return;
        }

        logs.add(data);
      },
      onError: (e) {
        print("Error during log download: $e");
        if (!completer.isCompleted) completer.complete();
      },
    );

    // Send Log Cursor command (6 bytes all zero)
    final cursor = <int>[0, 0, 0, 0, 0, 0];
    await _conn.writeCharacteristic(logCursorChar, cursor);
    print("Log Cursor set to address 0 with ALL_MEMORY flag");

    // Start global timeout
    globalTimeout = Timer(const Duration(seconds: 30), () {
      print("Global timeout reached, ending download");
      if (!completer.isCompleted) completer.complete();
    });

    // Wait for EOF or timeout
    await completer.future;

    // Cleanup
    await subscription.cancel();
    globalTimeout.cancel();

    print("Acquisition download completed. Total blocks: ${logs.length}");
    return logs;
  }

  Future<Map<String, dynamic>> getFriendlyMissionStatus() async {
    final data = await _conn.readCharacteristic(_missionSetupChar);
    final packet = MissionSetupPacket.fromBytes(data);
    return packet.toUserFriendlyMap();
  }

  List<int> _int32le(int v) =>
      [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];

  Future<void> disconnect() => _conn.disconnect();
}
