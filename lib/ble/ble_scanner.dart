import 'dart:async';
import 'package:alsos_bluewave_core/models/advertising.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:alsos_bluewave_core/ble/ble_adapter.dart';

const _blueWaveService = '4f4600';
const _scanTime = Duration(seconds: 8);

class BleScanner {
  BleScanner._();
  static final instance = BleScanner._();

  final _ctrl = StreamController<List<BleDevice>>.broadcast();
  Stream<List<BleDevice>> get results => _ctrl.stream;

  final Map<String, BleDevice> _found = {}; // key = MAC / id
  final Map<String, List<int>> _advBuffers =
      {}; // key = MAC / raw advertising bytes
  bool _scanning = false;
  bool get isScanning => _scanning;

  /*──────────────────────────── scan ────────────────────────────*/
  Future<void> startScan() async {
    if (_scanning) return;
    if (!await _ensurePermissions()) return;

    _scanning = true;
    _found.clear();
    _advBuffers.clear();
    _ctrl.add(const []);

    await FlutterBluePlus.stopScan();
    await FlutterBluePlus.startScan(timeout: _scanTime);

    final sub = FlutterBluePlus.scanResults.listen((batch) {
      for (final r in batch) {
        final okName =
            r.device.platformName.toUpperCase().startsWith('BLUEWAVE');
        final okService = r.advertisementData.serviceUuids.any(
            (u) => u.toString().toLowerCase().startsWith(_blueWaveService));
        if (!(okName || okService)) continue;

        final id = r.device.remoteId.str;
        final advData = r.advertisementData;

        final fragment = <int>[];

        // Manufacturer specific data
        advData.manufacturerData.forEach((key, value) {
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
          final a = advData.appearance!;
          fragment.add(3);
          fragment.add(0x19);
          fragment.add(a & 0xFF);
          fragment.add((a >> 8) & 0xFF);
        }

        _advBuffers[id] = fragment;

        // Parse all accumulated data
        final parsed = parseAdvertisingPayload(_advBuffers[id]!);
        final advParsed = parsed.containsKey(0xFF)
            ? Advertising.fromBytes(id, parsed[0xFF]!)
            : null;

        print("FLAGS\n");
        print(advParsed?.flags);

        final localName = parsed.containsKey(0x09)
            ? String.fromCharCodes(parsed[0x09]!)
            : r.device.platformName;

        final appearance = parsed[0x19] != null
            ? parsed[0x19]!
                .map((b) => b.toRadixString(16).padLeft(2, '0'))
                .join(' ')
            : null;

        _found[id] = BleDevice(
          id: id,
          name: r.device.platformName,
          rssi: r.rssi,
          advertising: advParsed,
          localName: localName,
          appearance: appearance,
        );

        _ctrl.add(_found.values.toList());
      }
    });

    await Future.delayed(_scanTime);
    await FlutterBluePlus.stopScan();
    await sub.cancel();

    _scanning = false;
    _ctrl.add(_found.values.toList());
  }

  Future<void> stopScan() async {
    if (!_scanning) return;
    _scanning = false;
    await FlutterBluePlus.stopScan();
    _ctrl.add(_found.values.toList());
  }

  /*──────────────────── permissions helper ─────────────────────*/
  Future<bool> _ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }
}
