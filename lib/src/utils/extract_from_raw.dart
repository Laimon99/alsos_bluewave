List<int>? extractFromRaw(List<int> raw) {
  if (raw.length < 8) return null;

  final tag = raw[2] + (raw[3] << 8);
  final length = raw[6] + (raw[7] << 8);

  if (length > 504) return null;

  if (tag != 0xBEBA && tag != 0xFECA) return null;

  return raw.sublist(8, 8 + length);
}