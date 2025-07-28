import 'package:alsos_bluewave_core/models/acquisitions/acquisition_sample.dart';
import 'package:alsos_bluewave_core/models/acquisitions/recovery_data.dart';

class ParsedAcquisition {
  final RecoveryData recovery;
  final List<AcquisitionSample> samples;

  ParsedAcquisition({
    required this.recovery,
    required this.samples,
  });
}