// 📁 lib/models/bluewave_calib_factory.dart
import 'package:alsos_bluewave_core/models/acquisitions/calibrations.dart';
import 'package:alsos_bluewave_core/factory_Calibration/factory_calibration.pb.dart';

Map<String, dynamic> buildTCalibrators(
  factoryConfigurationT factory,
  userConfigurationT? user,
) {
  return {
    'T': BlueWaveTcalib(factory.calibrationCh1, user?.calibrationCh1),
  };
}

Map<String, dynamic> buildTTCalibrators(
  factoryConfigurationTT factory,
  userConfigurationTT? user,
) {
  return {
    'T1': BlueWaveTcalib(factory.calibrationCh1, user?.calibrationCh1),
    'T2': BlueWaveTcalib(factory.calibrationCh2, user?.calibrationCh2),
  };
}

Map<String, dynamic> buildTPCalibrators(
  factoryConfigurationTP factory,
  userConfigurationTP? user,
) {
  return {
    'T': BlueWaveTcalib(factory.calibrationCh1, user?.calibrationCh1),
    'P': BlueWavePcalib(factory.calibrationCh2),
  };
}

Map<String, dynamic> buildBlueWaveCalibrators(
  dynamic factory,
  dynamic user,
) {
  if (factory is factoryConfigurationT && (user == null || user is userConfigurationT)) {
    return buildTCalibrators(factory, user);
  } else if (factory is factoryConfigurationTT && (user == null || user is userConfigurationTT)) {
    return buildTTCalibrators(factory, user);
  } else if (factory is factoryConfigurationTP && (user == null || user is userConfigurationTP)) {
    return buildTPCalibrators(factory, user);
  } else {
    throw Exception('❌ Unsupported calibration model');
  }
}