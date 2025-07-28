// guid.dart

/// Lightweight wrapper for a BLE UUID (16, 32 or 128-bit)
class Guid {
  final String value;
  const Guid(this.value);

  /// Returns the short 2-byte identifier if available.
  int? get short =>
      value.length >= 8 ? int.tryParse(value.substring(4, 8), radix: 16) : null;

  @override
  String toString() => value;

  /// Normalized string for comparison.
  String get _clean =>
      value.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();

  /// Returns true if this GUID matches the given full UUID string.
  bool matches(String fullUuid) {
    final cleaned = fullUuid.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();
    return cleaned.startsWith(_clean);
  }

  /// Returns true if this GUID matches the given flutter_blue_plus Guid.
  bool matchesFlutter(dynamic uuid) {
    final cleaned = uuid.toString().replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toLowerCase();
    return cleaned.startsWith(_clean);
  }
}
