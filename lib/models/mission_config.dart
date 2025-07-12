import 'dart:typed_data';
import 'packet.dart';

class MissionSetupPacket extends Packet {
  // Raw fields
  final int start, period, flags, epoch, time, next, stop;
  final int options, checkPeriod, checkTrigger, advRate;

  // Derived user-friendly fields
  final Duration? delay, frequency, duration;
  final DateTime? missionStartTime,
      currentDeviceTime,
      nextAcquisitionTime,
      stopTime;
  final String? status;
  final List<String>? decodedOptions;

  MissionSetupPacket({
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

  @override
  PacketType get type => PacketType.missionSetup;

  static MissionSetupPacket fromBytes(List<int> bytes) {
    final d = ByteData.sublistView(Uint8List.fromList(bytes));
    return MissionSetupPacket(
      start: d.getUint32(0, Endian.little),
      period: d.getUint32(4, Endian.little),
      flags: d.getUint16(8, Endian.little),
      epoch: d.getUint32(10, Endian.little),
      time: d.getUint32(14, Endian.little),
      next: d.getUint32(18, Endian.little),
      stop: d.getUint32(22, Endian.little),
      options: d.getUint16(26, Endian.little),
      checkPeriod: d.getUint16(28, Endian.little),
      checkTrigger: d.getUint16(30, Endian.little),
      advRate: d.getUint8(32),
    );
  }

  @override
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
    return buffer.buffer.asUint8List();
  }

  Map<String, dynamic> toUserFriendlyMap() {
    final baseEpoch = DateTime.utc(2000, 1, 1);
    final missionStartTime = baseEpoch.add(Duration(seconds: epoch));
    final currentDeviceTime = missionStartTime.add(Duration(seconds: time));
    final nextAcq = next == 0xFFFFFFFF
        ? null
        : missionStartTime.add(Duration(seconds: next));
    final stopDt = stop == 0xFFFFFFFF
        ? null
        : missionStartTime.add(Duration(seconds: stop));
    final duration =
        stop == 0xFFFFFFFF ? null : Duration(seconds: stop - start);

    return {
      'delay': Duration(seconds: start),
      'frequency': Duration(seconds: period),
      'duration': duration,
      'missionStartTime': missionStartTime,
      'currentDeviceTime': currentDeviceTime,
      'nextAcquisitionTime': nextAcq,
      'stopTime': stopDt,
      'status': _decodeFlags(flags),
      'decodedOptions': _decodeOptions(options),
      'checkPeriodSeconds': checkPeriod,
      'checkTriggerRaw': checkTrigger,
      'advRate': Duration(milliseconds: advRate * 100),
    };
  }

  static MissionSetupPacket fromUserInput({
    required Duration delay,
    required Duration frequency,
    required Duration duration,
    int flags = 0x8400,
    int options = 0x0011,
    int checkPeriod = 0,
    int checkTrigger = 0,
    int advRate = 0x0A,
  }) {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 946684800;
    final start = delay.inSeconds;
    final period = frequency.inSeconds;
    final stop = start + duration.inSeconds;

    return MissionSetupPacket(
      start: start,
      period: period,
      flags: flags,
      epoch: epoch,
      time: 0,
      next: 0,
      stop: stop,
      options: options,
      checkPeriod: checkPeriod,
      checkTrigger: checkTrigger,
      advRate: advRate,
    );
  }

  @override
  String toString() {
    return 'MissionSetupPacket(start=$start, period=$period, stop=$stop, epoch=$epoch, status=$status)';
  }

  static String _decodeFlags(int flags) {
    final isStarted = (flags & 0x8000) != 0;
    final isStopped = (flags & 0x4000) != 0;
    final isMemFull = (flags & 0x2000) != 0;
    final isWaitingTrigger = (flags & 0x1000) != 0;

    if (isMemFull) return 'MEM FULL';
    if (isWaitingTrigger) return 'WAITING TRIGGER';
    if (isStopped) return 'STOPPED'; // 🟢 priorità assoluta
    if (isStarted) return 'RUNNING';

    return 'IDLE';
  }

  static List<String> _decodeOptions(int opt) {
    final result = <String>[];
    if ((opt & 0x0001) != 0) result.add('CH0_RAW');
    if ((opt & 0x0002) != 0) result.add('CH1_RAW');
    if ((opt & 0x0004) != 0) result.add('CH2_RAW');
    if ((opt & 0x0008) != 0) result.add('CH3_RAW');
    if ((opt & 0x0010) != 0) result.add('CH0_FACTORY');
    if ((opt & 0x0020) != 0) result.add('CH0_USER');
    if ((opt & 0x0040) != 0) result.add('CH1_FACTORY');
    if ((opt & 0x0080) != 0) result.add('CH1_USER');
    if ((opt & 0x0100) != 0) result.add('CH2_FACTORY');
    if ((opt & 0x0200) != 0) result.add('CH2_USER');
    if ((opt & 0x0400) != 0) result.add('CH3_FACTORY');
    if ((opt & 0x0800) != 0) result.add('CH3_USER');
    return result;
  }
}
