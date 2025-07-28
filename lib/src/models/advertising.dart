// advertising.dart

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

  /// Builds an Advertising object from raw bytes (starting after type 0xFF).
  static Advertising? fromBytes(String id, List<int> bytes) {
    if (bytes.length < 9) return null;

    final d = ByteData.sublistView(Uint8List.fromList(bytes));
    final flags = d.getUint16(0, Endian.little);
    final options = d.getUint16(2, Endian.little);
    final seconds = d.getUint32(4, Endian.little);
    final battery = d.getUint8(8);

    final when = DateTime.utc(2000).add(Duration(seconds: seconds));
    final batteryLevel = battery / 255.0;

    final measurements = <String, double>{};
    final channels = _decodeChannels(options);
    int offset = 9;

    for (final ch in channels) {
      if (offset + 4 > bytes.length) {
        measurements[ch] = double.nan;
        break;
      }
      final value = d.getFloat32(offset, Endian.little);
      measurements[ch] = value;
      offset += 4;
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
    if ((flags & 0x2000) != 0) return 'MEM FULL';
    if ((flags & 0x1000) != 0) return 'WAITING TRIGGER';
    if ((flags & 0x4000) != 0) return 'STOPPED';
    if ((flags & 0x8000) != 0) return 'RUNNING';
    return 'IDLE';
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
    return map.entries.where((e) => (opt & e.key) != 0).map((e) => e.value).toList();
  }

  /// Status string.
  String get status => _decodeFlags(flags);

  /// Converts to user-friendly summary.
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

  /// Manufacturer from MAC address prefix.
  String get manufacturer {
    final parts = id.split(':');
    if (parts.length < 3) return '(unknown)';
    final oui = parts.sublist(0, 3).join(':').toLowerCase();
    return switch (oui) {
      'd0:14:11' => 'Tecnosoft',
      _ => oui,
    };
  }
}