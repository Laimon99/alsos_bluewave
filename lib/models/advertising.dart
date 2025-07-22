import 'dart:typed_data';

/// Parses the full advertising payload into a map: {type -> payload bytes}
Map<int, List<int>> parseAdvertisingPayload(List<int> raw) {
  final result = <int, List<int>>{};
  int index = 0;

  while (index < raw.length) {
    final length = raw[index];
    if (length == 0 || (index + length >= raw.length)) break;

    final type = raw[index + 1];
    final data = raw.sublist(index + 2, index + 1 + length);

    print("ADV BLOCK - type 0x${type.toRadixString(16).padLeft(2, '0')} "
        "(${_typeDescription(type)}): "
        "${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

    result[type] = data;

    index += 1 + length;
  }

  return result;
}

String _typeDescription(int type) {
  switch (type) {
    case 0x01:
      return "Flags";
    case 0x09:
      return "Complete Local Name";
    case 0x19:
      return "Appearance";
    case 0xFF:
      return "Manufacturer Specific Data";
    default:
      return "Unknown";
  }
}

class Advertising {
  final int flags;
  final int options;
  final DateTime when;
  final double batteryLevel;
  final Map<String, double> measurements;

  Advertising._({
    required this.flags,
    required this.options,
    required this.when,
    required this.batteryLevel,
    required this.measurements,
  });

  static Advertising? fromBytes(List<int> bytes) {
    print(
        ">>> ADV RAW BYTES: ${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}");

    if (bytes.length < 9) {
      print(">>> ADV troppo corto (${bytes.length} bytes)");
      return null;
    }

    final d = ByteData.sublistView(Uint8List.fromList(bytes));

    // Se il pacchetto è 9 byte, prova a leggere a partire da offset 0 (senza manufacturer)
    final flags = d.getUint16(0, Endian.little);
    final options = d.getUint16(2, Endian.little);
    final seconds = d.getUint32(4, Endian.little);
    final battery = d.getUint8(8);
    final when = DateTime.utc(2000).add(Duration(seconds: seconds));
    final batteryLevel = battery / 255.0;

    print(">>> FLAGS: 0x${flags.toRadixString(16)}");
    print(">>> OPTIONS: 0x${options.toRadixString(16)}");
    print(">>> TIME: $seconds → $when");
    print(">>> BATTERY: $battery → ${(batteryLevel * 100).round()}%");

    final channels = _decodeChannels(options);
    print(">>> CHANNELS: $channels");

    final measurements = <String, double>{};
    int offset = 9;

    for (final ch in channels) {
      if (offset + 4 > bytes.length) {
        print(
            ">>> NOT ENOUGH BYTES for $ch: required=${offset + 4}, available=${bytes.length}");
        measurements[ch] =
            double.nan; // inserisce comunque il canale, con valore mancante
        break;
      }
      final value = d.getFloat32(offset, Endian.little);
      print(">>> [$ch] = $value");
      measurements[ch] = value;
      offset += 4;
    }

    final status = _decodeFlags(flags);
    print(">>> STATUS: $status");

    return Advertising._(
      flags: flags,
      options: options,
      when: when,
      batteryLevel: batteryLevel,
      measurements: measurements,
    );
  }

  static String _decodeFlags(int flags) {
    final isStarted = (flags & 0x8000) != 0;
    final isStopped = (flags & 0x4000) != 0;
    final isMemFull = (flags & 0x2000) != 0;
    final isWaitingTrigger = (flags & 0x1000) != 0;

    print(">>> Decoding flags: "
        "STARTED=${isStarted ? 1 : 0} "
        "STOPPED=${isStopped ? 1 : 0} "
        "MEM_FULL=${isMemFull ? 1 : 0} "
        "WAITING_TRIGGER=${isWaitingTrigger ? 1 : 0}");

    if (isMemFull) return 'MEM FULL';
    if (isWaitingTrigger) return 'WAITING TRIGGER';
    if (isStopped) return 'STOPPED';
    if (isStarted) return 'RUNNING';
    return 'IDLE';
  }

  static List<String> _decodeChannels(int opt) {
    final map = {
      0x0010: 'CH0_FACTORY',
      0x0020: 'CH0_USER',
      0x0040: 'CH1_FACTORY',
      0x0080: 'CH1_USER',
      0x0100: 'CH2_FACTORY',
      0x0200: 'CH2_USER',
      0x0400: 'CH3_FACTORY',
      0x0800: 'CH3_USER',
    };
    return map.entries
        .where((e) => (opt & e.key) != 0)
        .map((e) => e.value)
        .toList();
  }

  String get status => _decodeFlags(flags);

  /// User-friendly map for UI
  Map<String, dynamic> toFriendlyMap() {
    final String batteryStr = '${(batteryLevel * 100).round()}%';
    final String timeStr = when.toLocal().toIso8601String().substring(11, 19);
    final String measures = measurements.entries.map((e) {
      final label = _prettyLabel(e.key);
      final value = e.value.isNaN ? '—' : e.value.toStringAsFixed(2);
      return '$label=$value';
    }).join(' | ');

    return {
      'status': status,
      'battery': batteryStr,
      'time': timeStr,
      'measurements': measures,
      'description':
          'Stato: $status | Batteria: $batteryStr | Misura: $timeStr | $measures',
    };
  }

  /// Optional: pretty labels (e.g., convert CH0_FACTORY → Temperatura)
  static String _prettyLabel(String key) {
    switch (key) {
      case 'CH0_FACTORY':
        return 'Temperatura';
      case 'CH1_FACTORY':
        return 'Pressione';
      default:
        return key;
    }
  }
}
