import 'package:alsos_bluewave/alsos_bluewave.dart';
import 'package:alsos_bluewave/src/models/acquisitions/acquisitions_info.dart';

class MissionBlobBuilder {
  final BlueWaveDevice device;
  MissionBlobBuilder(this.device);

  Future<Map<String, dynamic>> build(AcquisitionInfo acquisition) async {
    final status = await device.readDeviceStatus();

    // Cast sicuro: accetta Map<dynamic,dynamic> e la trasforma in Map<String,dynamic>
    final Map<String, dynamic>? sys =
        (status['sys'] as Map?)?.cast<String, dynamic>() ??
        (status['systemInfo'] as Map?)?.cast<String, dynamic>();

    // --- misure ---
    final timestamps = <int>[];
    final measuresMap = <String, Map<String, dynamic>>{}; // forma "vecchia"
    for (final s in acquisition.parsed.samples) {
      final ts = (s.timestamp.millisecondsSinceEpoch ~/ 1000) - 946684800;
      timestamps.add(ts);

      _addMeasure(measuresMap, "TEMPERATURE", "CALIBRATED", "°C",   s.temperatureC);
      _addMeasure(measuresMap, "PRESSURE",    "CALIBRATED", "mbar", s.pressuremBar);
    }

    final filteredMeasures = measuresMap.values.where((m) {
      final values = (m["Values"] as List<num>? ) ?? const <num>[];
      return values.any((v) => v != 0);
    }).toList();

    final measures = <Map<String, dynamic>>[
      {"type": "TIMESTAMP", "mode": "UTC", "unit": "s", "Values": timestamps},
      ...filteredMeasures,
    ];

    // --- dispositivi ---
    String _kindFromModels() {
      final candidates = <String>[
        (sys?['model'] ?? '').toString(),
        (status['model'] ?? '').toString(),
        (sys?['modelKey'] ?? '').toString(),
      ].map((s) => s.toUpperCase());

      final s = candidates.firstWhere((e) => e.isNotEmpty, orElse: () => '');
      if (s.contains('TP')) return 'TP';
      if (s.contains('TT')) return 'TT';
      if (s.contains('TRH')) return 'TRH';
      if (s.contains(RegExp(r'\bP\b')) || s.endsWith('-P')) return 'P';
      return 'T';
    }

    final kind = _kindFromModels();
    final deviceModel =
        status['model']?.toString().isNotEmpty == true
            ? status['model']
            : (sys?['model'] ?? sys?['modelKey'] ?? 'BlueWave');

    final devices = [
      {
        "brand": status['manufacturer'] ?? 'BlueWave',
        "model": deviceModel,
        "serial": sys?['serial'] ?? sys?['mac'] ?? '',
        "type": "LOGGER",
        "version": sys?['versionString'] ?? sys?['firmware'] ?? '',
        "sensors": () {
          final list = <Map<String, dynamic>>[];
          final desc = acquisition.userConfiguration.description ?? '';

          // CH0 per T / TP / TT
          if (kind == 'T' || kind.startsWith('TP') || kind.startsWith('TT')) {
            list.add(_sensorEntry(sys, kind, desc, channel: '0'));
          }
          // CH1 per P / TP / TT
          if (kind == 'P' || kind.startsWith('TP') || kind.startsWith('TT')) {
            list.add(_sensorEntry(sys, kind, desc, channel: '1'));
          }
          return list;
        }(),
      }
    ];

    return {
      "devices": devices,
      "channels": [
        {"measures": measures},
      ],
    };
  }

  Map<String, dynamic> _sensorEntry(
    Map<String, dynamic>? sys,
    String modelKey,
    String description, {
    required String channel,
  }) {
    return {
      "brand": "BlueWave",
      "model": modelKey, // es. "TP"
      "serial": sys?['serial'] ?? sys?['mac'] ?? '',
      "version": sys?['versionString'] ?? sys?['firmware'] ?? '',
      "channel": channel,
      "description": description,
    };
  }

  // ===== forma "vecchia": chiave unica + Values =====
  void _addMeasure(
    Map<String, Map<String, dynamic>> map,
    String type,
    String mode,
    String unit,
    num? value,
  ) {
    if (value == null || value.isNaN || value.isInfinite) return;

    num formatted = value;
    final u = unit.toLowerCase();

    if (unit == "°C") {
      final v = value.toDouble();
      final truncated3 = (v * 1000).truncateToDouble() / 1000.0;   // taglio al 3°
      formatted = double.parse(truncated3.toStringAsFixed(2));     // arrotondo a 2
    } else if (u == "mbar") {
      final v = value.toDouble();
      final truncated1 = (v * 10).truncateToDouble() / 10.0;       // taglio al 1°
      formatted = truncated1.round();                              // intero
    }

    final key = "$type|$mode|$unit";
    map.putIfAbsent(key, () => {
      "type": type,
      "mode": mode,
      "unit": unit,
      "Values": <num>[],
    });
    (map[key]!["Values"] as List<num>).add(formatted);
  }
}
