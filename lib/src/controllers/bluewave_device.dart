import 'dart:async';
import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisitions.dart';
import 'package:alsos_bluewave/src/models/guid.dart';
import 'package:alsos_bluewave/src/models/mission/mission_capabilities.dart';
import 'package:alsos_bluewave/src/models/mission_blob.dart';
import 'package:alsos_bluewave/src/models/mission/mission_config.dart';
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

  // in BlueWaveDevice.readDeviceStatus()

  Future<Map<String, dynamic>> readDeviceStatus() async {
    Map<String, dynamic>? sysMap;
    try {
      final sysData = await _conn.read(_sysInfoChar);
      final sys = SystemInfo.fromBytes(sysData);
      sysMap = sys.toMap();
    } catch (e, st) {
      print('[sysinfo] read/parse failed: $e\n$st');
      sysMap = null;
    }

    Future<String> _readAscii(Guid ch) async {
      try {
        final v = await _conn.read(ch);
        return String.fromCharCodes(v).trim();
      } catch (_) {
        return '';
      }
    }

    final manufacturer = await _readAscii(_charManufacturer);
    final model = await _readAscii(_charModel);
    final hwRev = await _readAscii(_charHwRev);

    return {
      'systemInfo': sysMap,
      'sys': sysMap,
      'manufacturer': manufacturer,
      'model': model,
      'hwRev': hwRev,
    };
  }

  Future<Map<String, dynamic>> readCurrentData() async {
    final raw = await _conn.read(_currentDataChar);
    final cd = CurrentData.fromBytes(raw);
    return <String, dynamic>{
      'temperature': cd.temperature,
      'pressure': cd.pressure,
    };
  }

  static Future<Map<String, Map<String, dynamic>>> getMissionConfig(
    List<String> models,
  ) async {
    // Clean input
    final clean =
        models.where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toList();

    print('[BlueWaveDevice] MODELS(raw): $models');
    print('[BlueWaveDevice] MODELS(clean): $clean');

    final map = await getMissionConfigMap(clean);

    final keys = map.keys.toList()..sort();
    print('[BlueWaveDevice] CONFIG ∪ KEYS: $keys');

    return map;
  }

  Future<void> startMission({
    required Duration delay,
    required Duration frequency,
    required Duration duration,
    int flags = 0x8000,
    int checkPeriod = 0,
    required int checkTrigger,
    int? advRate,
    bool ch0Raw = false,
    bool ch0Factory = false,
    bool ch0User = false,
    bool ch1Raw = false,
    bool ch1Factory = false,
    bool ch1User = false,
    // NEW
    String? modelHint,
  }) async {
    // Helper: longest-match ('TT'/'TP' before 'T')
    String _matchModelKey(String? text) {
      final upper = (text ?? '').toUpperCase();
      if (upper.isEmpty) return '';
      final keysByLenDesc = modelCapabilities.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      for (final key in keysByLenDesc) {
        if (upper.contains(key.toUpperCase())) return key;
      }
      return '';
    }

    // 1) Read status from device
    final status = await readDeviceStatus();
    final modelStr = (status['model'] ?? '').toString();
    final hwRevStr = (status['hwRev'] ?? '').toString();

    // 2) Resolve model key using (model) -> (hint) -> (hwRev)
    String resolvedKey = '';
    if (modelCapabilities.containsKey(modelStr)) {
      resolvedKey = modelStr;
    } else {
      resolvedKey = _matchModelKey(modelStr);
      if (resolvedKey.isEmpty) resolvedKey = _matchModelKey(modelHint);
      if (resolvedKey.isEmpty) resolvedKey = _matchModelKey(hwRevStr);
    }

    print('[BlueWaveDevice/startMission] Model characteristic: $modelStr');
    print('[BlueWaveDevice/startMission] Model hint: ${modelHint ?? '-'}');
    print(
        '[BlueWaveDevice/startMission] HW rev: ${hwRevStr.isEmpty ? '-' : hwRevStr}');
    print(
        '[BlueWaveDevice/startMission] Resolved model key: ${resolvedKey.isEmpty ? 'UNRESOLVED' : resolvedKey}');

    // 3) Get capability map: prefer the resolved key, else fall back to hint/model string
    final List<String> lookup = resolvedKey.isNotEmpty
        ? [resolvedKey] // "T","TP","TT","P"
        : [modelHint ?? modelStr];

    final cfg = await getMissionConfig(lookup);
    final supported = cfg.keys.toList()..sort();
    print('[BlueWaveDevice/startMission] Supported fields: $supported');

    bool supports(String id) => cfg.containsKey(id);

    // 4) Gate fields
    final useCh0Raw = supports('enableCh0Raw') && ch0Raw;
    final useCh0Factory = supports('enableCh0Factory') && ch0Factory;
    final useCh0User = supports('enableCh0User') && ch0User;
    final useCh1Raw = supports('enableCh1Raw') && ch1Raw;
    final useCh1Factory = supports('enableCh1Factory') && ch1Factory;
    final useCh1User = supports('enableCh1User') && ch1User;

    final effectiveAdvRate = supports('advRate') ? advRate : null;
    final effectiveCheckPeriod = supports('checkPeriod') ? checkPeriod : 0;

    int safeFlags = flags;
    if (!supports('startAbove')) safeFlags &= ~0x0100;
    if (!supports('startBelow')) safeFlags &= ~0x0080;
    if (!supports('startOnChannel')) safeFlags &= ~0x0003;

    final triggerSupported = supports('startAbove') ||
        supports('startBelow') ||
        supports('startOnChannel');
    final effectiveCheckTrigger = triggerSupported ? checkTrigger : 0;

    print('[BlueWaveDevice/startMission] Input params: '
        'delay=${delay.inSeconds}s, period=${frequency.inSeconds}s, duration=${duration.inSeconds}s, '
        'flags=0x${flags.toRadixString(16).toUpperCase()}, '
        'checkPeriod=$checkPeriod, checkTrigger=$checkTrigger, advRate=${advRate ?? 'null'}, '
        'ch0Raw=$ch0Raw, ch0Factory=$ch0Factory, ch0User=$ch0User, '
        'ch1Raw=$ch1Raw, ch1Factory=$ch1Factory, ch1User=$ch1User');

    print('[BlueWaveDevice/startMission] Effective params: '
        'advRate=${effectiveAdvRate ?? 'null'}, checkPeriod=$effectiveCheckPeriod, checkTrigger=$effectiveCheckTrigger, '
        'ch0Raw=$useCh0Raw, ch0Factory=$useCh0Factory, ch0User=$useCh0User, '
        'ch1Raw=$useCh1Raw, ch1Factory=$useCh1Factory, ch1User=$useCh1User');

    print(
        '[BlueWaveDevice/startMission] Flags before=0x${flags.toRadixString(16).toUpperCase()}, '
        'after=0x${safeFlags.toRadixString(16).toUpperCase()}');

    // 5) Build & send
    final packet = MissionSetupPacket.fromUserInput(
      delay: delay,
      frequency: frequency,
      duration: duration,
      flags: safeFlags,
      checkPeriod: effectiveCheckPeriod,
      checkTrigger: effectiveCheckTrigger,
      advRate: effectiveAdvRate,
      ch0Raw: useCh0Raw,
      ch0Factory: useCh0Factory,
      ch0User: useCh0User,
      ch1Raw: useCh1Raw,
      ch1Factory: useCh1Factory,
      ch1User: useCh1User,
    );

    await _conn.write(_missionSetupChar, packet.toBytes());
    print('[BlueWaveDevice/startMission] Mission START sent');
  }

  /// Starts a logging mission on the device.
  //Future<void> startMission({
  //  required Duration delay,
  //  required Duration frequency,
  //  required Duration duration,
  //  int flags = 0x8000,
  //  int checkPeriod = 0,
  //  required int checkTrigger,
  //  int? advRate,
  //  required bool enableCh0,
  //  required bool enableCh1,
  //}) async {
  //  final packet = MissionSetupPacket.fromUserInput(
  //    delay: delay,
  //    frequency: frequency,
  //    duration: duration,
  //    flags: flags,
  //    enableCh0: enableCh0,
  //    enableCh1: enableCh1,
  //    checkPeriod: checkPeriod,
  //    checkTrigger: checkTrigger,
  //    advRate: advRate,
  //  );
  //  await _conn.write(_missionSetupChar, packet.toBytes());
  //  print("Mission START sent: $packet");
  //}

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

  Future<Map<String, dynamic>> getMissionBlob() async {
    // 1) Read logs over BLE
    print("Starting acquisition download...");

    final logs = <List<int>>[];

    // Reset cursor
    await _conn.write(bluewaveLogCursor, [0, 0, 0, 0, 0, 0]);

    // Read blocks
    for (int i = 0; i < 10000; i++) {
      try {
        final data = await _conn.read(bluewaveLogData);

        if (data.isEmpty) {
          print("⚠️ Empty packet ignored");
          continue;
        }

        if (data.every((b) => b == 0xFF)) {
          print("✅ End of data (all 0xFF)");
          break;
        }

        logs.add(data);
      } catch (e) {
        print("❌ Error while reading packet $i: $e");
        break;
      }

      await Future.delayed(const Duration(milliseconds: 20));
    }

    if (logs.isEmpty) {
      throw Exception("No data acquired: empty mission or not started.");
    }

    // 2) Read calibration blobs over BLE
    final factoryRaw = await _conn.read(bluewaveFactoryConfiguration);
    final userRaw = await _conn.read(bluewaveUserConfiguration);

    final info = await Acquisitions.downloadAcquisitions(
      logs: logs,
      factoryRaw: factoryRaw,
      userRaw: userRaw,
    );

    // 4) Build Mission BLOB
    return MissionBlobBuilder(this).build(info);
  }
}
