import 'dart:async';
import 'dart:io' show Platform;
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/advertising.dart';
import 'ble_device.dart';

const _blueWaveServicePrefix = '4f4600';
const _scanDuration = Duration(seconds: 8);

/// Handles BLE scan for BlueWave devices.
class BleScanner {
  BleScanner._();
  static final BleScanner instance = BleScanner._();

  final _controller = StreamController<List<BleDevice>>.broadcast();
  Stream<List<BleDevice>> get results => _controller.stream;

  final Map<String, BleDevice> _foundDevices = {};
  final Map<String, List<int>> _advBuffers = {};
  bool _scanning = false;
  bool get isScanning => _scanning;

  final CentralManager _manager = CentralManager();

  Future<void> startScan() async {
    if (_scanning) return;

    if (!await _ensurePermissions()) {
      print('❌ Missing required permissions. Scan aborted.');
      return;
    }

    _scanning = true;
    _foundDevices.clear();
    _advBuffers.clear();
    _controller.add(const []);

    print('📡 Scanning for BlueWave devices…');

    final subscription = _manager.discovered.listen((event) {
      if (!_isBlueWave(event)) return;

      final peripheral = event.peripheral;
      final uuid = peripheral.uuid.toString();
      final advData = event.advertisement;
      final rssi = event.rssi;

      print('🔍 Discovered: ${advData.name} $uuid');
      print('✅ BlueWave match: $uuid');

      final payload = _assemblePayload(advData);
      print(
          '📦 Raw payload (${uuid.substring(0, 8)}): ${payload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');

      final parsed = parseAdvertisingPayload(payload);
      print('🧩 Parsed AD structure:');
      parsed.forEach((type, data) {
        print(
            '  • Type 0x${type.toRadixString(16)} (${_adTypeName(type)}): ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      });

      final ffData = parsed[0xFF];
      Advertising? advParsed;

      if (ffData != null && ffData.length >= 9) {
        advParsed = Advertising.fromBytes(uuid, ffData);
        print(
            '✅ Interpreted Advertising: ${advParsed?.toFriendlyMap()['description'] ?? "(parse failed)"}');
      } else {
        print('⚠️ No valid 0xFF payload, using minimal Advertising');
        advParsed = Advertising.minimal(uuid);
      }

      _advBuffers[uuid] = payload;

      final localName = parsed.containsKey(0x09)
          ? String.fromCharCodes(parsed[0x09]!)
          : advData.name ?? 'Unknown';

      final appearance = parsed[0x19]
          ?.map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join(' ');

      _foundDevices[uuid] = BleDevice(
        id: uuid,
        name: advData.name ?? 'Unknown',
        rssi: rssi,
        advertising: advParsed,
        localName: localName,
        appearance: appearance,
      );

      _controller.add(_foundDevices.values.toList());
    });

    await _manager.startDiscovery();
    await Future.delayed(_scanDuration);
    await _manager.stopDiscovery();
    await subscription.cancel();

    _scanning = false;
    _controller.add(_foundDevices.values.toList());
  }

  Future<void> stopScan() async {
    if (!_scanning) return;
    _scanning = false;
    await _manager.stopDiscovery();
    _controller.add(_foundDevices.values.toList());
  }

  Future<bool> _ensurePermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 31) {
      final statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ].request();
      final allGranted = statuses.values.every((s) => s.isGranted);
      if (!allGranted) {
        print('❌ Missing BLE permissions: $statuses');
      }
      return allGranted;
    }

    final locationStatus = await Permission.locationWhenInUse.request();
    if (!locationStatus.isGranted) {
      print('⚠️ Location permission not granted.');
      return false;
    }

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final allGranted = statuses.values.every((s) => s.isGranted);
    if (!allGranted) {
      print('❌ Missing BLE permissions: $statuses');
    }
    return allGranted;
  }

  bool _isBlueWave(DiscoveredEventArgs event) {
    final name = event.advertisement.name ?? '';
    final nameMatch = name.toUpperCase().startsWith('BLUEWAVE');
    final serviceMatch = event.advertisement.serviceUUIDs.any(
      (u) => u.toString().toLowerCase().startsWith(_blueWaveServicePrefix),
    );
    return nameMatch || serviceMatch;
  }

  List<int> _assemblePayload(Advertisement advData) {
    final fragment = <int>[];

    print('📥 manufacturerSpecificData:');
    for (final m in advData.manufacturerSpecificData) {
      final idHex = m.id.toRadixString(16).padLeft(4, '0');
      final dataHex =
          m.data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      print('🧬 Manufacturer data (id=0x$idHex): $dataHex');

      // Build the advertising field
      final value = m.data;
      fragment.add(
          value.length + 3); // length of data + 1 (type) + 2 (manufacturer id)
      fragment.add(0xFF); // type = 0xFF (Manufacturer Specific)
      fragment.add(m.id & 0xFF); // manufacturer id low byte
      fragment.add((m.id >> 8) & 0xFF); // manufacturer id high byte
      fragment.addAll(value); // actual payload
    }

    if ((advData.name ?? '').isNotEmpty) {
      final nameBytes = advData.name!.codeUnits;
      fragment.add(nameBytes.length + 1);
      fragment.add(0x09);
      fragment.addAll(nameBytes);
    }

    return fragment;
  }

  String _adTypeName(int type) {
    return {
          0x01: 'Flags',
          0x02: 'Incomplete 16-bit UUIDs',
          0x03: 'Complete 16-bit UUIDs',
          0x06: 'Incomplete 128-bit UUIDs',
          0x07: 'Complete 128-bit UUIDs',
          0x08: 'Shortened Name',
          0x09: 'Complete Name',
          0x19: 'Appearance',
          0xFF: 'Manufacturer Specific',
        }[type] ??
        'Unknown';
  }
}
