// 📁 lib/models/blob_builder.dart
import 'package:alsos_bluewave/src/models/system_info.dart';
import 'package:alsos_bluewave/src/controllers/bluewave_device.dart';

/// Utility class to build a Mission BLOB from a connected BlueWaveDevice.
class MissionBlobBuilder {
  final BlueWaveDevice device;

  MissionBlobBuilder(this.device);

  /// Generates the Mission BLOB in structured Map format.
  Future<Map<String, dynamic>> build() async {
    final sys = await device.readSystemInfo();
    final info = await device.readDeviceInformation();
    final acquisition = await device.downloadAcquisitions();

    final model = info['model'].toString().toUpperCase();
    final config = acquisition.userConfiguration;

    final sensors = <Map<String, dynamic>>[];
    if (model.startsWith('TP') || model.startsWith('TT') || model.startsWith('T-')) {
      sensors.add(_sensorEntry(sys, model, config.description, channel: '0'));
    }
    if (model.startsWith('TP') || model.startsWith('TT') || model.startsWith('P-')) {
      sensors.add(_sensorEntry(sys, model, config.description, channel: '1'));
    }

    final devices = [
      {
        "brand": info['manufacturer'],
        "model": info['model'],
        "serial": sys.serial,
        "certificate": "",
        "type": "LOGGER",
        "description": info['hwRev'],
        "version": sys.versionString,
        "sensors": sensors,
      }
    ];

    final timestamps = <int>[];
    final measuresMap = <String, Map<String, dynamic>>{};

    for (final sample in acquisition.parsed.samples) {
      final ts = (sample.timestamp.millisecondsSinceEpoch ~/ 1000) - 946684800;
      timestamps.add(ts);
      _addMeasure(measuresMap, "TEMPERATURE", "CALIBRATED", "°C", sample.temperatureC);
      _addMeasure(measuresMap, "PRESSURE", "CALIBRATED", "mBar", sample.pressuremBar);
    }

    final filteredMeasures = measuresMap.values.where((m) {
      final values = m["Values"] as List<num>;
      return values.any((v) => v != 0);
    }).toList();

    final measures = <Map<String, dynamic>>[
      {
        "type": "TIMESTAMP",
        "mode": "UTC",
        "unit": "s",
        "Values": timestamps,
      },
      ...filteredMeasures,
    ];

    return {
      "devices": devices,
      "channels": [
        {"measures": measures},
      ],
    };
  }

  Map<String, dynamic> _sensorEntry(SystemInfo sys, String model, String description, {required String channel}) {
    return {
      "brand": "BlueWave",
      "model": model,
      "serial": sys.serial,
      "certificate": "",
      "version": sys.versionString,
      "channel": channel,
      "description": description,
    };
  }

  void _addMeasure(Map<String, Map<String, dynamic>> map, String type, String mode, String unit, num? value) {
    if (value == null || value.isNaN || value.isInfinite) return;
    final key = "$type|$mode|$unit";
    map.putIfAbsent(key, () => {
      "type": type,
      "mode": mode,
      "unit": unit,
      "Values": <num>[],
    });
    map[key]!["Values"].add(value);
  }
}