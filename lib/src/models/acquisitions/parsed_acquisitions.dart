import 'package:alsos_bluewave/src/models/acquisitions/acquisition_sample.dart';
import 'package:alsos_bluewave/src/models/acquisitions/recovery_data.dart';

class ParsedAcquisition {
  final RecoveryData recovery;
  final List<AcquisitionSample> samples;

  ParsedAcquisition({
    required this.recovery,
    required this.samples,
  });
}