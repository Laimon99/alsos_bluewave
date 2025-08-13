import 'dart:typed_data';

/// Represents the low-level data structure for configuring or reading
/// a mission on a BlueWave device.
class MissionSetupPacket {
  // Raw fields as stored/transmitted (33 bytes total)
  final int start, period, flags, epoch, time, next, stop;
  final int options, checkPeriod, checkTrigger, advRate;

  // Optional decoded user-friendly fields
  final Duration? delay, frequency, duration;
  final DateTime? missionStartTime,
      currentDeviceTime,
      nextAcquisitionTime,
      stopTime;
  final String? status;
  final List<String>? decodedOptions;

  const MissionSetupPacket({
    required this.start,
    required this.period,
    required this.flags,
    required this.epoch,
    required this.time,
    required this.next,
    required this.stop,
    required this.options,
    required this.checkPeriod,
    required this.checkTrigger,
    required this.advRate,
    this.delay,
    this.frequency,
    this.duration,
    this.missionStartTime,
    this.currentDeviceTime,
    this.nextAcquisitionTime,
    this.stopTime,
    this.status,
    this.decodedOptions,
  });

  /// Encodes this packet into 33 bytes.
  Uint8List toBytes() {
    final buffer = ByteData(33);

    buffer.setUint32(0, start, Endian.little);
    buffer.setUint32(4, period, Endian.little);
    buffer.setUint16(8, flags, Endian.little);
    buffer.setUint32(10, epoch, Endian.little);
    buffer.setUint32(14, time, Endian.little);
    buffer.setUint32(18, next, Endian.little);
    buffer.setUint32(22, stop, Endian.little);
    buffer.setUint16(26, options, Endian.little);
    buffer.setUint16(28, checkPeriod, Endian.little);
    buffer.setUint16(30, checkTrigger, Endian.little);
    buffer.setUint8(32, advRate);

    final bytes = buffer.buffer.asUint8List();

    // Debug log
    print("MissionSetupPacket.toBytes() output:");
    for (int i = 0; i < bytes.length; i++) {
      final hex = bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase();
      print("Byte ${i.toString().padLeft(2)}: 0x$hex");
    }

    return bytes;
  }

  /// Creates a MissionSetupPacket from high-level user inputs.
  static MissionSetupPacket fromUserInput({
    required Duration delay,
    required Duration frequency,
    required Duration duration,
    int? flags,
    // nuovi parametri dettagliati sui canali
    bool ch0Raw = false,
    bool ch0Factory = false,
    bool ch0User = false,
    bool ch1Raw = false,
    bool ch1Factory = false,
    bool ch1User = false,
    // parametri già esistenti
    required int checkPeriod,
    required int checkTrigger,
    int? advRate,
  }) {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 946684800;
    final start = delay.inSeconds;
    final period = frequency.inSeconds;
    final stop =
        duration.inSeconds == 0 ? 0xFFFFFFFF : start + duration.inSeconds;

    int options = 0x0000;
    if (ch0Raw) options |= 0x0001; // CH0_RAW
    if (ch1Raw) options |= 0x0002; // CH1_RAW
    if (ch0Factory) options |= 0x0010;
    if (ch0User) options |= 0x0020;
    if (ch1Factory) options |= 0x0040;
    if (ch1User) options |= 0x0080;

    return MissionSetupPacket(
      start: start,
      period: period,
      flags: flags ?? 0x0000,
      epoch: epoch,
      time: 0,
      next: 0,
      stop: stop,
      options: options,
      checkPeriod: checkPeriod,
      checkTrigger: checkTrigger,
      advRate: advRate ?? 0x0A,
    );
  }

  @override
  String toString() {
    return 'MissionSetupPacket(start=$start, period=$period, stop=$stop, epoch=$epoch, status=$status)';
  }

//EXTRA FUNCTION

//  /// Decodes a raw 33-byte packet into a MissionSetupPacket.
//  static MissionSetupPacket fromBytes(List<int> bytes) {
//    final d = ByteData.sublistView(Uint8List.fromList(bytes));
//    return MissionSetupPacket(
//      start: d.getUint32(0, Endian.little),
//      period: d.getUint32(4, Endian.little),
//      flags: d.getUint16(8, Endian.little),
//      epoch: d.getUint32(10, Endian.little),
//      time: d.getUint32(14, Endian.little),
//      next: d.getUint32(18, Endian.little),
//      stop: d.getUint32(22, Endian.little),
//      options: d.getUint16(26, Endian.little),
//      checkPeriod: d.getUint16(28, Endian.little),
//      checkTrigger: d.getUint16(30, Endian.little),
//      advRate: d.getUint8(32),
//    );
//  }
//
//  /// Converts raw fields into a readable map of user-friendly values.
//  Map<String, dynamic> toUserFriendlyMap() {
//    final baseEpoch = DateTime.utc(2000, 1, 1);
//    final missionStartTime = baseEpoch.add(Duration(seconds: epoch));
//    final currentDeviceTime = missionStartTime.add(Duration(seconds: time));
//    final nextAcq = next == 0xFFFFFFFF ? null : missionStartTime.add(Duration(seconds: next));
//    final stopDt = stop == 0xFFFFFFFF ? null : missionStartTime.add(Duration(seconds: stop));
//    final duration = stop == 0xFFFFFFFF ? null : Duration(seconds: stop - start);
//
//    return {
//      'delay': Duration(seconds: start),
//      'frequency': Duration(seconds: period),
//      'duration': duration,
//      'missionStartTime': missionStartTime,
//      'currentDeviceTime': currentDeviceTime,
//      'nextAcquisitionTime': nextAcq,
//      'stopTime': stopDt,
//      'status': _decodeFlags(flags),
//      'decodedOptions': _decodeOptions(options),
//      'checkPeriodSeconds': checkPeriod,
//      'checkTriggerRaw': checkTrigger,
//      'advRate': Duration(milliseconds: advRate * 100),
//    };
//  }
//
//  /// Decodes the flags field to a readable mission status.
//  static String _decodeFlags(int flags) {
//    final isStarted = (flags & 0x8000) != 0;
//    final isStopped = (flags & 0x4000) != 0;
//    final isMemFull = (flags & 0x2000) != 0;
//    final isWaitingTrigger = (flags & 0x1000) != 0;
//
//    if (isMemFull) return 'MEM FULL';
//    if (isWaitingTrigger) return 'WAITING TRIGGER';
//    if (isStopped) return 'STOPPED';
//    if (isStarted) return 'RUNNING';
//    return 'IDLE';
//  }
//
//  /// Converts the bitfield in `options` to a list of enabled channel modes.
//  static List<String> _decodeOptions(int opt) {
//    final result = <String>[];
//    if ((opt & 0x0001) != 0) result.add('CH0_RAW');
//    if ((opt & 0x0002) != 0) result.add('CH1_RAW');
//    if ((opt & 0x0004) != 0) result.add('CH2_RAW');
//    if ((opt & 0x0008) != 0) result.add('CH3_RAW');
//    if ((opt & 0x0010) != 0) result.add('CH0_FACTORY');
//    if ((opt & 0x0020) != 0) result.add('CH0_USER');
//    if ((opt & 0x0040) != 0) result.add('CH1_FACTORY');
//    if ((opt & 0x0080) != 0) result.add('CH1_USER');
//    if ((opt & 0x0100) != 0) result.add('CH2_FACTORY');
//    if ((opt & 0x0200) != 0) result.add('CH2_USER');
//    if ((opt & 0x0400) != 0) result.add('CH3_FACTORY');
//    if ((opt & 0x0800) != 0) result.add('CH3_USER');
//    return result;
//  }
}
