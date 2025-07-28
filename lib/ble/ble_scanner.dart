// scanner.dart

import 'dart:async';
import 'package:alsos_bluewave_core/ble/ble_device.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/advertising.dart';

const _blueWaveServicePrefix = '4f4600';
const _scanDuration = Duration(seconds: 8);

/// Handles BLE scan for BlueWave devices.
class BleScanner {
  BleScanner._();
  static final instance = BleScanner._();

  final _controller = StreamController<List<BleDevice>>.broadcast();
  Stream<List<BleDevice>> get results => _controller.stream;

  final Map<String, BleDevice> _foundDevices = {}; // key = MAC / id
  final Map<String, List<int>> _advBuffers = {};   // key = MAC / advertising payload
  bool _scanning = false;
  bool get isScanning => _scanning;

  /// Starts a BLE scan and filters BlueWave devices only.
  Future<void> startScan() async {
    if (_scanning) return;
    if (!await _ensurePermissions()) return;

    _scanning = true;
    _foundDevices.clear();
    _advBuffers.clear();
    _controller.add(const []);

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: _scanDuration);

    final subscription = FlutterBluePlus.scanResults.listen((batch) {
      for (final result in batch) {
        if (!_isBlueWave(result)) continue;

        final id = result.device.remoteId.str;
        final advData = result.advertisementData;
        final payload = _assemblePayload(advData);
        _advBuffers[id] = payload;

        final parsed = parseAdvertisingPayload(payload);
        final advParsed = parsed.containsKey(0xFF)
            ? Advertising.fromBytes(id, parsed[0xFF]!)
            : null;

        final localName = parsed.containsKey(0x09)
            ? String.fromCharCodes(parsed[0x09]!)
            : result.device.platformName;

        final appearance = parsed[0x19]?.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');

        _foundDevices[id] = BleDevice(
          id: id,
          name: result.device.platformName,
          rssi: result.rssi,
          advertising: advParsed,
          localName: localName,
          appearance: appearance,
        );

        _controller.add(_foundDevices.values.toList());
      }
    });

    await Future.delayed(_scanDuration);
    await FlutterBluePlus.stopScan();
    await subscription.cancel();

    _scanning = false;
    _controller.add(_foundDevices.values.toList());
  }

  /// Stops the scan if active.
  Future<void> stopScan() async {
    if (!_scanning) return;
    _scanning = false;
    await FlutterBluePlus.stopScan();
    _controller.add(_foundDevices.values.toList());
  }

  /// Checks all required permissions.
  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  /// Returns true if device name or service UUID matches BlueWave pattern.
  bool _isBlueWave(ScanResult r) {
    final nameMatch = r.device.platformName.toUpperCase().startsWith('BLUEWAVE');
    final serviceMatch = r.advertisementData.serviceUuids.any(
      (u) => u.toString().toLowerCase().startsWith(_blueWaveServicePrefix),
    );
    return nameMatch || serviceMatch;
  }

  /// Reassembles the raw advertising payload for parsing.
  List<int> _assemblePayload(AdvertisementData advData) {
    final fragment = <int>[];

    // Manufacturer specific data
    advData.manufacturerData.forEach((_, value) {
      fragment.add(value.length + 1);
      fragment.add(0xFF);
      fragment.addAll(value);
    });

    // Local name
    if (advData.advName.isNotEmpty) {
      final nameBytes = advData.advName.codeUnits;
      fragment.add(nameBytes.length + 1);
      fragment.add(0x09);
      fragment.addAll(nameBytes);
    }

    // Appearance
    if (advData.appearance != null) {
      fragment.add(3);
      fragment.add(0x19);
      fragment.add(advData.appearance! & 0xFF);
      fragment.add((advData.appearance! >> 8) & 0xFF);
    }

    return fragment;
  }
}