import 'package:alsos_bluewave/src/factory_calibration/factory_calibration.pb.dart';


class BlueWaveTcalib {
  List<double> poly = [double.nan];
  double reference = double.nan;
  double partialStart = double.nan;
  double fullStart = double.nan;
  double fullStop = double.nan;
  double partialStop = double.nan;
  List<double> uPoly = [double.nan];

  BlueWaveTcalib(
    factoryCalibrationPolyPT factory,
    userCalibrationPolyRange? user,
  ) {
    poly = factory.coefficients.toList();
    reference = factory.reference;
    if (user != null) {
      partialStart = user.partialStart;
      fullStart = user.fullStart;
      fullStop = user.fullStop;
      partialStop = user.partialStop;
      uPoly = user.coefficients;
    }
  }

  static const int infP = 65534;
  static const int infM = 0;
  static const int nan = 1;
  static const double adFsr = 8388607.0;

  double evalPoly(double x, List<double> coeffs) {
    double v = 0.0;
    for (double c in coeffs) {
      v *= x;
      v += c;
    }
    return v;
  }

  double factory(int raw) {
    double x = raw.toDouble() / (adFsr / 16) * reference;
    switch (raw) {
      case infP:
        x = double.infinity;
      case infM:
        x = -double.infinity;
      case nan:
        x = double.nan;
    }
    double v = 0.0;
    for (double c in poly) {
      v *= x;
      v += c;
    }
    return v;
  }

  double user(int raw) {
    double value = factory(raw);
    double correction = 0;
    if (value >= fullStart && value <= fullStop) {
      correction = evalPoly(value, uPoly);
    } else if (value > partialStart && value <= fullStart) {
      correction = evalPoly(value, uPoly);
      correction *= (value - partialStart) / (fullStart - partialStart);
    } else if (value >= fullStop && value < partialStop) {
      correction = evalPoly(value, uPoly);
      correction *= (partialStop - value) / (partialStop - partialStart);
    }
    return value + correction;
  }
}

class BlueWavePcalib {
  List<List<double>>? poly = [];
  List<double>? poly2 = [];

  static const double adFsr = 8388607.0;
  static const double refRes = 3600;
  static const double gain = 32;
  static const int wheatstoneOffset = 2000;

  BlueWavePcalib(dynamic factory) {
    poly = List.generate(
      factory.polyList.length,
      (i) => factory.polyList[i].coefficients.toList(),
    );
    poly2 = List.generate(poly!.length, (_) => 0.0);
  }

  double evalPoly(double x, List<double> coeffs) {
    double v = 0.0;
    for (double c in coeffs) {
      v *= x;
      v += c;
    }
    return v;
  }

  double factory(int raw, double t) {
    double f = (refRes * 128.0 / (adFsr * gain)) * (raw - wheatstoneOffset);

    if (poly != null) {
      for (int i = 0; i < poly2!.length; i++) {
        poly2![i] = evalPoly(t, poly![i]);
      }
      return evalPoly(f, poly2!);
    } else {
      return double.nan;
    }
  }

  double user(int raw, double t) {
    return factory(raw, t);
  }
}
