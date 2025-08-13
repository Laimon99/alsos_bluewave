import 'package:alsos_bluewave/src/models/mission/mission_fields.dart';

final Map<String, Set<MissionSupport>> modelCapabilities = {
  // BlueWave T: single‑temperature device.
  'T': <MissionSupport>{
    MissionSupport.start,
    MissionSupport.period,
    MissionSupport.status,
    MissionSupport.config,
    MissionSupport.configTrigger,
    MissionSupport.epoch,
    MissionSupport.time,
    MissionSupport.next,
    MissionSupport.stop,
    MissionSupport.checkPeriod,
    MissionSupport.advertisingRate,
    MissionSupport.waitRelease,
    MissionSupport.radioOn,
    MissionSupport.noRecord,
    MissionSupport.startAbove,
    MissionSupport.startBelow,
    MissionSupport.startOnChannel,
    MissionSupport.recordCH0,
    // Channel 1 and higher are not available on T
    MissionSupport.advertiseCH0factory,
    MissionSupport.advertiseCH0user,
  },
  // BlueWave TT: dual‑temperature device.
  'TT': <MissionSupport>{
    MissionSupport.start,
    MissionSupport.period,
    MissionSupport.status,
    MissionSupport.config,
    MissionSupport.configTrigger,
    MissionSupport.epoch,
    MissionSupport.time,
    MissionSupport.next,
    MissionSupport.stop,
    MissionSupport.checkPeriod,
    MissionSupport.advertisingRate,
    MissionSupport.waitRelease,
    MissionSupport.radioOn,
    MissionSupport.noRecord,
    MissionSupport.startAbove,
    MissionSupport.startBelow,
    MissionSupport.startOnChannel,
    // Channel 0 capabilities
    MissionSupport.recordCH0,
    MissionSupport.advertiseCH0factory,
    MissionSupport.advertiseCH0user,
    // Channel 1 capabilities
    MissionSupport.recordCH1,
    MissionSupport.advertiseCH1factory,
    MissionSupport.advertiseCH1user,
  },
  // BlueWave TP: temperature + pressure device (also used by BlueWave P).
  // In Carlo's code, P inherits missionCapabilities() from TP.
  'TP': <MissionSupport>{
    MissionSupport.start,
    MissionSupport.period,
    MissionSupport.status,
    MissionSupport.config,
    MissionSupport.configTrigger,
    MissionSupport.epoch,
    MissionSupport.time,
    MissionSupport.next,
    MissionSupport.stop,
    MissionSupport.checkPeriod,
    MissionSupport.advertisingRate,
    MissionSupport.waitRelease,
    MissionSupport.radioOn,
    MissionSupport.noRecord,
    MissionSupport.startAbove,
    MissionSupport.startBelow,
    MissionSupport.startOnChannel,
    // Temperature channel
    MissionSupport.recordCH0,
    MissionSupport.advertiseCH0factory,
    MissionSupport.advertiseCH0user,
    // Pressure channel
    MissionSupport.recordCH1,
    MissionSupport.advertiseCH1factory,
    MissionSupport.advertiseCH1user,
  },
  // Alias: treat model "P" the same as "TP" (pressure only with calibration).
  'P': <MissionSupport>{
    MissionSupport.start,
    MissionSupport.period,
    MissionSupport.status,
    MissionSupport.config,
    MissionSupport.configTrigger,
    MissionSupport.epoch,
    MissionSupport.time,
    MissionSupport.next,
    MissionSupport.stop,
    MissionSupport.checkPeriod,
    MissionSupport.advertisingRate,
    MissionSupport.waitRelease,
    MissionSupport.radioOn,
    MissionSupport.noRecord,
    MissionSupport.startAbove,
    MissionSupport.startBelow,
    MissionSupport.startOnChannel,
    MissionSupport.recordCH0,
    MissionSupport.advertiseCH0factory,
    MissionSupport.advertiseCH0user,
    MissionSupport.recordCH1,
    MissionSupport.advertiseCH1factory,
    MissionSupport.advertiseCH1user,
  },
};

Set<MissionSupport> getCapabilitiesForModel(String model) {
  return modelCapabilities[model] ?? {};
}

Future<Map<String, Map<String, dynamic>>> getMissionConfigMap(
  List<String> models,
) async {
  // Helper: choose the longest matching key ('TP' before 'T', 'TT' before 'T', etc.)
  String _matchModelKey(String modelName) {
    final upper = modelName.toUpperCase();
    final keysByLenDesc = modelCapabilities.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final key in keysByLenDesc) {
      if (upper.contains(key.toUpperCase())) {
        return key;
      }
    }
    return '';
  }

  // 1) Build per-model capability sets
  final List<Set<MissionSupport>> perModelCaps = [];
  for (final name in models) {
    final key = _matchModelKey(name);
    print(
        '[MissionCaps] match("$name") -> "${key.isEmpty ? 'UNMATCHED' : key}"');
    if (key.isNotEmpty) {
      perModelCaps.add(getCapabilitiesForModel(key));
    }
  }

  if (perModelCaps.isEmpty) {
    print('[MissionCaps] No model matched. Returning empty config.');
    return {};
  }

  // 2) UNION of capabilities across provided models
  Set<MissionSupport> caps = <MissionSupport>{};
  for (final set in perModelCaps) {
    caps = caps.union(set);
  }
  print(
      '[MissionCaps] Combined caps via UNION (models=${models.length}, sets=${perModelCaps.length}) -> size=${caps.length}');

  // 3) Determine internal fields enabled by the combined capabilities
  final Set<MissionField> internalFields = {};
  missionFieldCapabilities.forEach((field, requiredCaps) {
    if (requiredCaps.any(caps.contains)) {
      internalFields.add(field);
    }
  });

  // 4) Build a public map keyed by a stable string id
  final Map<String, Map<String, dynamic>> out = {};
  for (final field in internalFields) {
    final meta = _missionFieldMeta[field];
    if (meta != null) {
      final id = meta['id'] as String;
      out[id] = {
        'label': meta['label'],
        'channel': meta['channel'],
        'category': meta['category'],
      };
    }
  }

  final keys = out.keys.toList()..sort();
  print('[MissionCaps] PUBLIC KEYS: $keys');

  return out;
}

/// Internal: metadata for each MissionField mapped to a JSON-like map.
/// Keep these 'id' keys stable — apps may persist them.
const Map<MissionField, Map<String, dynamic>> _missionFieldMeta = {
  // Timing
  MissionField.delay: {
    'id': 'delay',
    'label': 'Start delay (seconds)',
    'channel': null,
    'category': 'timing',
  },
  MissionField.frequency: {
    'id': 'frequency',
    'label': 'Acquisition period',
    'channel': null,
    'category': 'timing',
  },
  MissionField.duration: {
    'id': 'duration',
    'label': 'Mission duration',
    'channel': null,
    'category': 'timing',
  },
  MissionField.checkPeriod: {
    'id': 'checkPeriod',
    'label': 'Trigger check period',
    'channel': null,
    'category': 'timing',
  },

  // Advertising
  MissionField.advRate: {
    'id': 'advRate',
    'label': 'Advertising rate (0.1s units)',
    'channel': null,
    'category': 'advertising',
  },

  // Channel 0
  MissionField.enableCh0Raw: {
    'id': 'enableCh0Raw',
    'label': 'Record CH0 raw',
    'channel': 0,
    'category': 'channel',
  },
  MissionField.enableCh0Factory: {
    'id': 'enableCh0Factory',
    'label': 'Advertise CH0 (factory)',
    'channel': 0,
    'category': 'channel',
  },
  MissionField.enableCh0User: {
    'id': 'enableCh0User',
    'label': 'Advertise CH0 (user)',
    'channel': 0,
    'category': 'channel',
  },

  // Channel 1
  MissionField.enableCh1Raw: {
    'id': 'enableCh1Raw',
    'label': 'Record CH1 raw',
    'channel': 1,
    'category': 'channel',
  },
  MissionField.enableCh1Factory: {
    'id': 'enableCh1Factory',
    'label': 'Advertise CH1 (factory)',
    'channel': 1,
    'category': 'channel',
  },
  MissionField.enableCh1User: {
    'id': 'enableCh1User',
    'label': 'Advertise CH1 (user)',
    'channel': 1,
    'category': 'channel',
  },

  // Channel 2
  MissionField.enableCh2Raw: {
    'id': 'enableCh2Raw',
    'label': 'Record CH2 raw',
    'channel': 2,
    'category': 'channel',
  },
  MissionField.enableCh2Factory: {
    'id': 'enableCh2Factory',
    'label': 'Advertise CH2 (factory)',
    'channel': 2,
    'category': 'channel',
  },
  MissionField.enableCh2User: {
    'id': 'enableCh2User',
    'label': 'Advertise CH2 (user)',
    'channel': 2,
    'category': 'channel',
  },

  // Channel 3
  MissionField.enableCh3Raw: {
    'id': 'enableCh3Raw',
    'label': 'Record CH3 raw',
    'channel': 3,
    'category': 'channel',
  },
  MissionField.enableCh3Factory: {
    'id': 'enableCh3Factory',
    'label': 'Advertise CH3 (factory)',
    'channel': 3,
    'category': 'channel',
  },
  MissionField.enableCh3User: {
    'id': 'enableCh3User',
    'label': 'Advertise CH3 (user)',
    'channel': 3,
    'category': 'channel',
  },

  // Triggers
  MissionField.startAbove: {
    'id': 'startAbove',
    'label': 'Start on threshold above',
    'channel': null,
    'category': 'trigger',
  },
  MissionField.startBelow: {
    'id': 'startBelow',
    'label': 'Start on threshold below',
    'channel': null,
    'category': 'trigger',
  },
  MissionField.startOnChannel: {
    'id': 'startOnChannel',
    'label': 'Start on channel',
    'channel': null,
    'category': 'trigger',
  },
};
