import 'dart:typed_data';

/// Enum for identifying packet categories.
enum PacketType {
  missionSetup,
  systemInfo,
  advertising,
  currentData,
  acquisitions,
  unknown,
}

/// Base class for all binary packets.
abstract class Packet {
  /// Type of the packet (used for runtime introspection).
  PacketType get type;

  /// Serializes the packet to bytes.
  List<int> toBytes();

  /// Human-readable debug.
  @override
  String toString();

  /// Registry of packet type -> fromBytes functions.
  static final Map<Type, Packet Function(Uint8List)> _registry = {};

  /// Registers a packet type with its parser function.
  static void register<T extends Packet>(Packet Function(Uint8List) parser) {
    _registry[T] = parser;
  }

  /// Parses raw bytes into a specific packet type.
  static T? fromBytes<T extends Packet>(Uint8List bytes) {
    final parser = _registry[T];
    if (parser == null) return null;
    return parser(bytes) as T;
  }
}
