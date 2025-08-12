import 'dart:typed_data';

/// Parses the BLE advertising payload into a map of type -> payload.
Map<int, List<int>> parseAdvertisingPayload(List<int> raw) {
  final result = <int, List<int>>{};
  int index = 0;

  while (index < raw.length) {
    final length = raw[index];
    if (length == 0 || (index + length >= raw.length)) break;

    final type = raw[index + 1];
    final data = raw.sublist(index + 2, index + 1 + length);
    result[type] = data;
    index += 1 + length;
  }

  return result;
}

/// Represents the parsed BlueWave advertising payload.
class Advertising {
  final int flags;
  final int options;
  final DateTime when;
  final double batteryLevel;
  final Map<String, double> measurements;
  final String id;

  Advertising._({
    required this.id,
    required this.flags,
    required this.options,
    required this.when,
    required this.batteryLevel,
    required this.measurements,
  });

  /// Creates a fallback Advertising with no data (for devices without 0xFF field).
  factory Advertising.minimal(String id) {
    return Advertising._(
      id: id,
      flags: 0,
      options: 0,
      when: DateTime.now(),
      batteryLevel: double.nan,
      measurements: {},
    );
  }

  /// Builds an Advertising object from raw bytes (starting after type 0xFF).
  static Advertising? fromBytes(String id, List<int> bytes) {
    final raw = Uint8List.fromList(bytes);
    if (raw.length < 11)
      return null; // min length: 2 (prefix) + 2 (flags) + 2 (opts) + 4 (ts) + 1 (battery)

    final d = ByteData.sublistView(raw);

// Skip the first 2 bytes (manufacturer header)
    const headerOffset = 2;
    final flags = d.getUint16(headerOffset, Endian.little);
    final options = d.getUint16(headerOffset + 2, Endian.little);
    final seconds = d.getUint32(headerOffset + 4, Endian.little);
    final when = DateTime.utc(2000).add(Duration(seconds: seconds));

    double batteryLevel = double.nan;
    final measurements = <String, double>{};

    int offset = headerOffset + 8;
    if (raw.length > offset) {
      batteryLevel = d.getUint8(offset) / 255.0;
      offset += 1;

      final channels = _decodeChannels(options);
      for (final ch in channels) {
        if (offset + 4 > raw.length) {
          measurements[ch] = double.nan;
          break;
        }
        final value = d.getFloat32(offset, Endian.little);
        measurements[ch] = value;
        offset += 4;
      }
    }

    return Advertising._(
      id: id,
      flags: flags,
      options: options,
      when: when,
      batteryLevel: batteryLevel,
      measurements: measurements,
    );
  }

  /// Returns a textual status string based on flags.
  static String _decodeFlags(int flags) {
    final status = flags & 0xE000;
    final isStarted = (status & 0x8000) != 0;
    final isStopped = (status & 0x4000) != 0;
    final isMemFull = (status & 0x2000) != 0;
    final isWaiting = (status & 0x1000) != 0;

    print(
        '🔎 Flags raw bytes: 0x${flags.toRadixString(16).padLeft(4, '0').toUpperCase()}');

    if (isStopped) return 'STOPPED';
    if (isWaiting) return 'WAITING TRIGGER';
    if (isStarted) return 'RUNNING';
    if (isMemFull) return 'MEM FULL';
    return 'STOPPED';
  }

  /// Maps option bits to channel labels.
  static List<String> _decodeChannels(int opt) {
    const map = {
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

  /// Status string.
  String get status => _decodeFlags(flags);

  /// Converts to user-friendly summary.
  Map<String, dynamic> toFriendlyMap() {
    final String batteryStr =
        batteryLevel.isNaN ? '—' : '${(batteryLevel * 100).round()}%';
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

  /// Pretty labels for channels (can be customized).
  static String _prettyLabel(String key) {
    switch (key) {
      case 'CH0_FACTORY':
      case 'CH0_USER':
        return 'Temperature';
      case 'CH1_FACTORY':
      case 'CH1_USER':
        return 'Pressure';
      default:
        return key;
    }
  }

  /// Manufacturer from UUID suffix.
  String get manufacturer {
    final macPart = id.substring(id.length - 12).toLowerCase();
    final oui =
        '${macPart.substring(0, 2)}:${macPart.substring(2, 4)}:${macPart.substring(4, 6)}';
    return switch (oui) {
      'd0:14:11' => 'Tecnosoft',
      _ => 'Unknown ($oui)',
    };
  }
}
