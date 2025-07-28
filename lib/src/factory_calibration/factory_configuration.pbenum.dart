import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class MODEL extends $pb.ProtobufEnum {
  static const MODEL UNDEFINED = MODEL._(0, _omitEnumNames ? '' : 'UNDEFINED');
  static const MODEL BLUEWAVE_T = MODEL._(1, _omitEnumNames ? '' : 'BLUEWAVE_T');
  static const MODEL BLUEWAVE_TT = MODEL._(2, _omitEnumNames ? '' : 'BLUEWAVE_TT');
  static const MODEL BLUEWAVE_P = MODEL._(3, _omitEnumNames ? '' : 'BLUEWAVE_P');
  static const MODEL BLUEWAVE_TP = MODEL._(4, _omitEnumNames ? '' : 'BLUEWAVE_TP');
  static const MODEL BLUEWAVE_TH = MODEL._(5, _omitEnumNames ? '' : 'BLUEWAVE_TH');

  static const $core.List<MODEL> values = <MODEL> [
    UNDEFINED,
    BLUEWAVE_T,
    BLUEWAVE_TT,
    BLUEWAVE_P,
    BLUEWAVE_TP,
    BLUEWAVE_TH,
  ];

  static final $core.List<MODEL?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MODEL? valueOf($core.int value) =>  value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MODEL._(super.value, super.name);
}


const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');