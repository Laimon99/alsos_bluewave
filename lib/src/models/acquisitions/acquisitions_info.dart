import 'package:alsos_bluewave/src/models/acquisitions/parsed_acquisitions.dart';
import 'package:alsos_bluewave/src/models/acquisitions/recovery_data.dart';

class AcquisitionInfo {
  final List<String> summary;
  final String? status;
  final Duration? frequency;
  final DateTime? startTime;
  final RecoveryData recovery;
  final ParsedAcquisition parsed;
  final dynamic userConfiguration;

  AcquisitionInfo({
    required this.summary,
    required this.recovery,
    this.status,
    this.frequency,
    this.startTime,
    required this.parsed,
    required this.userConfiguration,
  });
}