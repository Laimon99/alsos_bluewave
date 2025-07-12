import 'dart:typed_data';
import 'packet.dart';

class SystemInfo implements Packet {
  final String model;
  final String firmware;
  final DateTime epoch;
  final Duration uptime;
  final int flashSize;
  final int e2romSize;
  final int totalAcq;
  final int batteryMv;
  final String mac;
  final String description;
  final int batteryTotal; // Coulomb
  final int batteryUsed; // Coulomb
  final String resetReason; // Human readable reset reason
  final int resetCount;

  const SystemInfo({
    required this.model,
    required this.firmware,
    required this.epoch,
    required this.uptime,
    required this.flashSize,
    required this.e2romSize,
    required this.totalAcq,
    required this.batteryMv,
    required this.mac,
    required this.description,
    required this.batteryTotal,
    required this.batteryUsed,
    required this.resetReason,
    required this.resetCount,
  });

  @override
  List<int> toBytes() => throw UnimplementedError('SystemInfo is read-only');

  factory SystemInfo.fromBytes(List<int> bytes) {
    final d = ByteData.sublistView(Uint8List.fromList(bytes));

    int u16(int o) => d.getUint16(o, Endian.little);
    int u32(int o) => d.getUint32(o, Endian.little);

    String decodeFirmware(int v) =>
        '${(v >> 8).toString().padLeft(2, '0')}.${(v & 0xFF).toString().padLeft(2, '0')}';

    String decodeResetReason(int v) {
      if (v & 0x0001 != 0) return 'Power on reset';
      if (v & 0x0002 != 0) return 'Brown-out on AVDD power';
      if (v & 0x0004 != 0) return 'Brown-out on DVDD power';
      if (v & 0x0008 != 0) return 'Brown-out on DEC power';
      if (v & 0x0010 != 0) return 'Pin reset';
      if (v & 0x0080 != 0) return 'Lockup reset';
      if (v & 0x0100 != 0) return 'System reset request';
      if (v & 0x0200 != 0) return 'Watchdog reset';
      if (v & 0x0400 != 0) return 'System EM4';
      return 'Unknown(0x${v.toRadixString(16)})';
    }

    final modelCode = u16(0);
    final versionRaw = u16(2);
    final epochSec = u32(4);
    final timeTicks = u32(8);

    final macBytes = bytes.sublist(26, 32).reversed.toList();
    final macStr = macBytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');

    final descRaw = bytes.sublist(32, 48);
    final descStr = String.fromCharCodes(descRaw).split('\u0000').first.trim();

    return SystemInfo(
      model: _decodeModel(modelCode),
      firmware: decodeFirmware(versionRaw),
      epoch: DateTime.utc(2000).add(Duration(seconds: epochSec)),
      uptime: Duration(seconds: timeTicks),
      flashSize: u32(12),
      e2romSize: u32(16),
      totalAcq: u32(20),
      batteryMv: u16(24),
      mac: macStr,
      description: descStr,
      batteryTotal: u16(48),
      batteryUsed: u16(50),
      resetReason: decodeResetReason(u16(52)),
      resetCount: u32(56),
    );
  }

  static String _decodeModel(int code) {
    switch (code & 0xFF) {
      case 0x0A:
        return 'BlueWave-T';
      case 0x0B:
        return 'BlueWave-TT';
      case 0x0C:
        return 'BlueWave-P';
      case 0x0D:
        return 'BlueWave-TP';
      case 0x0E:
        return 'BlueWave-TRH';
      default:
        return 'Unknown(0x${code.toRadixString(16)})';
    }
  }

  @override
  bool operator ==(Object o) =>
      o is SystemInfo &&
      model == o.model &&
      firmware == o.firmware &&
      epoch == o.epoch &&
      uptime == o.uptime &&
      flashSize == o.flashSize &&
      e2romSize == o.e2romSize &&
      totalAcq == o.totalAcq &&
      batteryMv == o.batteryMv &&
      mac == o.mac &&
      description == o.description &&
      batteryTotal == o.batteryTotal &&
      batteryUsed == o.batteryUsed &&
      resetReason == o.resetReason &&
      resetCount == o.resetCount;

  @override
  int get hashCode => Object.hash(
        model,
        firmware,
        epoch,
        uptime,
        flashSize,
        e2romSize,
        totalAcq,
        batteryMv,
        mac,
        description,
        batteryTotal,
        batteryUsed,
        resetReason,
        resetCount,
      );

  @override
  // TODO: implement type
  PacketType get type => throw UnimplementedError();
}
