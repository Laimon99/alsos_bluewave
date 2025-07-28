// This is a generated file - do not edit.
//
// Generated from BlueWave.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;
import 'package:alsos_bluewave/factory_Calibration/factory_configuration.pbenum.dart';
import 'package:protobuf/protobuf.dart' as $pb;


export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'factory_configuration.pbenum.dart';

class factoryCalibrationPoly extends $pb.GeneratedMessage {
  factory factoryCalibrationPoly({
    $core.Iterable<$core.double>? coefficients,
  }) {
    final result = create();
    if (coefficients != null) result.coefficients.addAll(coefficients);
    return result;
  }

  factoryCalibrationPoly._();

  factory factoryCalibrationPoly.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryCalibrationPoly.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryCalibrationPoly', createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'coefficients', $pb.PbFieldType.KF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPoly clone() => factoryCalibrationPoly()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPoly copyWith(void Function(factoryCalibrationPoly) updates) => super.copyWith((message) => updates(message as factoryCalibrationPoly)) as factoryCalibrationPoly;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPoly create() => factoryCalibrationPoly._();
  @$core.override
  factoryCalibrationPoly createEmptyInstance() => create();
  static $pb.PbList<factoryCalibrationPoly> createRepeated() => $pb.PbList<factoryCalibrationPoly>();
  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPoly getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryCalibrationPoly>(create);
  static factoryCalibrationPoly? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get coefficients => $_getList(0);
}

class factoryCalibrationPolyPT extends $pb.GeneratedMessage {
  factory factoryCalibrationPolyPT({
    $core.double? reference,
    $core.Iterable<$core.double>? coefficients,
    $core.double? rawScale,
    $core.double? rawOffset,
  }) {
    final result = create();
    if (reference != null) result.reference = reference;
    if (coefficients != null) result.coefficients.addAll(coefficients);
    if (rawScale != null) result.rawScale = rawScale;
    if (rawOffset != null) result.rawOffset = rawOffset;
    return result;
  }

  factoryCalibrationPolyPT._();

  factory factoryCalibrationPolyPT.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryCalibrationPolyPT.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryCalibrationPolyPT', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'reference', $pb.PbFieldType.OF)
    ..p<$core.double>(2, _omitFieldNames ? '' : 'coefficients', $pb.PbFieldType.KF)
    ..a<$core.double>(14, _omitFieldNames ? '' : 'rawScale', $pb.PbFieldType.OF, protoName: 'rawScale')
    ..a<$core.double>(15, _omitFieldNames ? '' : 'rawOffset', $pb.PbFieldType.OF, protoName: 'rawOffset')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPolyPT clone() => factoryCalibrationPolyPT()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPolyPT copyWith(void Function(factoryCalibrationPolyPT) updates) => super.copyWith((message) => updates(message as factoryCalibrationPolyPT)) as factoryCalibrationPolyPT;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPolyPT create() => factoryCalibrationPolyPT._();
  @$core.override
  factoryCalibrationPolyPT createEmptyInstance() => create();
  static $pb.PbList<factoryCalibrationPolyPT> createRepeated() => $pb.PbList<factoryCalibrationPolyPT>();
  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPolyPT getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryCalibrationPolyPT>(create);
  static factoryCalibrationPolyPT? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get reference => $_getN(0);
  @$pb.TagNumber(1)
  set reference($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReference() => $_has(0);
  @$pb.TagNumber(1)
  void clearReference() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get coefficients => $_getList(1);

  @$pb.TagNumber(14)
  $core.double get rawScale => $_getN(2);
  @$pb.TagNumber(14)
  set rawScale($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(14)
  $core.bool hasRawScale() => $_has(2);
  @$pb.TagNumber(14)
  void clearRawScale() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get rawOffset => $_getN(3);
  @$pb.TagNumber(15)
  set rawOffset($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(15)
  $core.bool hasRawOffset() => $_has(3);
  @$pb.TagNumber(15)
  void clearRawOffset() => $_clearField(15);
}

class factoryCalibrationPolyList extends $pb.GeneratedMessage {
  factory factoryCalibrationPolyList({
    $core.Iterable<factoryCalibrationPoly>? polyList,
    $core.double? rawScale,
    $core.double? rawOffset,
  }) {
    final result = create();
    if (polyList != null) result.polyList.addAll(polyList);
    if (rawScale != null) result.rawScale = rawScale;
    if (rawOffset != null) result.rawOffset = rawOffset;
    return result;
  }

  factoryCalibrationPolyList._();

  factory factoryCalibrationPolyList.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryCalibrationPolyList.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryCalibrationPolyList', createEmptyInstance: create)
    ..pc<factoryCalibrationPoly>(1, _omitFieldNames ? '' : 'polyList', $pb.PbFieldType.PM, protoName: 'polyList', subBuilder: factoryCalibrationPoly.create)
    ..a<$core.double>(14, _omitFieldNames ? '' : 'rawScale', $pb.PbFieldType.OF, protoName: 'rawScale')
    ..a<$core.double>(15, _omitFieldNames ? '' : 'rawOffset', $pb.PbFieldType.OF, protoName: 'rawOffset')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPolyList clone() => factoryCalibrationPolyList()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryCalibrationPolyList copyWith(void Function(factoryCalibrationPolyList) updates) => super.copyWith((message) => updates(message as factoryCalibrationPolyList)) as factoryCalibrationPolyList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPolyList create() => factoryCalibrationPolyList._();
  @$core.override
  factoryCalibrationPolyList createEmptyInstance() => create();
  static $pb.PbList<factoryCalibrationPolyList> createRepeated() => $pb.PbList<factoryCalibrationPolyList>();
  @$core.pragma('dart2js:noInline')
  static factoryCalibrationPolyList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryCalibrationPolyList>(create);
  static factoryCalibrationPolyList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<factoryCalibrationPoly> get polyList => $_getList(0);

  @$pb.TagNumber(14)
  $core.double get rawScale => $_getN(1);
  @$pb.TagNumber(14)
  set rawScale($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(14)
  $core.bool hasRawScale() => $_has(1);
  @$pb.TagNumber(14)
  void clearRawScale() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get rawOffset => $_getN(2);
  @$pb.TagNumber(15)
  set rawOffset($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(15)
  $core.bool hasRawOffset() => $_has(2);
  @$pb.TagNumber(15)
  void clearRawOffset() => $_clearField(15);
}

class factoryConfigurationT extends $pb.GeneratedMessage {
  factory factoryConfigurationT({
    MODEL? model,
    $core.int? serial,
    $core.int? hiMAC,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    $core.String? variant,
    factoryCalibrationPolyPT? calibrationCh1,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (hiMAC != null) result.hiMAC = hiMAC;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (variant != null) result.variant = variant;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    return result;
  }

  factoryConfigurationT._();

  factory factoryConfigurationT.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryConfigurationT.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryConfigurationT', createEmptyInstance: create)
    ..e<MODEL>(1, _omitFieldNames ? '' : 'model', $pb.PbFieldType.OE, defaultOrMaker: MODEL.UNDEFINED, valueOf: MODEL.valueOf, enumValues: MODEL.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'serial', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'HiMAC', $pb.PbFieldType.OF3, protoName: 'HiMAC')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOS(6, _omitFieldNames ? '' : 'variant')
    ..aOM<factoryCalibrationPolyPT>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: factoryCalibrationPolyPT.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationT clone() => factoryConfigurationT()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationT copyWith(void Function(factoryConfigurationT) updates) => super.copyWith((message) => updates(message as factoryConfigurationT)) as factoryConfigurationT;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryConfigurationT create() => factoryConfigurationT._();
  @$core.override
  factoryConfigurationT createEmptyInstance() => create();
  static $pb.PbList<factoryConfigurationT> createRepeated() => $pb.PbList<factoryConfigurationT>();
  @$core.pragma('dart2js:noInline')
  static factoryConfigurationT getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryConfigurationT>(create);
  static factoryConfigurationT? _defaultInstance;

  @$pb.TagNumber(1)
  MODEL get model => $_getN(0);
  @$pb.TagNumber(1)
  set model(MODEL value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serial => $_getIZ(1);
  @$pb.TagNumber(2)
  set serial($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  /// (xxxxx is decimal for last two bytes of MAC
  @$pb.TagNumber(3)
  $core.int get hiMAC => $_getIZ(2);
  @$pb.TagNumber(3)
  set hiMAC($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHiMAC() => $_has(2);
  @$pb.TagNumber(3)
  void clearHiMAC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get calibrationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set calibrationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCalibrationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCalibrationDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expirationDate => $_getIZ(4);
  @$pb.TagNumber(5)
  set expirationDate($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpirationDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpirationDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get variant => $_getSZ(5);
  @$pb.TagNumber(6)
  set variant($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVariant() => $_has(5);
  @$pb.TagNumber(6)
  void clearVariant() => $_clearField(6);

  @$pb.TagNumber(16)
  factoryCalibrationPolyPT get calibrationCh1 => $_getN(6);
  @$pb.TagNumber(16)
  set calibrationCh1(factoryCalibrationPolyPT value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(6);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  factoryCalibrationPolyPT ensureCalibrationCh1() => $_ensure(6);
}

class factoryConfigurationTT extends $pb.GeneratedMessage {
  factory factoryConfigurationTT({
    MODEL? model,
    $core.int? serial,
    $core.int? hiMAC,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    $core.String? variant,
    factoryCalibrationPolyPT? calibrationCh1,
    factoryCalibrationPolyPT? calibrationCh2,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (hiMAC != null) result.hiMAC = hiMAC;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (variant != null) result.variant = variant;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    if (calibrationCh2 != null) result.calibrationCh2 = calibrationCh2;
    return result;
  }

  factoryConfigurationTT._();

  factory factoryConfigurationTT.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryConfigurationTT.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryConfigurationTT', createEmptyInstance: create)
    ..e<MODEL>(1, _omitFieldNames ? '' : 'model', $pb.PbFieldType.OE, defaultOrMaker: MODEL.UNDEFINED, valueOf: MODEL.valueOf, enumValues: MODEL.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'serial', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'HiMAC', $pb.PbFieldType.OF3, protoName: 'HiMAC')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOS(6, _omitFieldNames ? '' : 'variant')
    ..aOM<factoryCalibrationPolyPT>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: factoryCalibrationPolyPT.create)
    ..aOM<factoryCalibrationPolyPT>(17, _omitFieldNames ? '' : 'calibrationCh2', protoName: 'calibrationCh2', subBuilder: factoryCalibrationPolyPT.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTT clone() => factoryConfigurationTT()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTT copyWith(void Function(factoryConfigurationTT) updates) => super.copyWith((message) => updates(message as factoryConfigurationTT)) as factoryConfigurationTT;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTT create() => factoryConfigurationTT._();
  @$core.override
  factoryConfigurationTT createEmptyInstance() => create();
  static $pb.PbList<factoryConfigurationTT> createRepeated() => $pb.PbList<factoryConfigurationTT>();
  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTT getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryConfigurationTT>(create);
  static factoryConfigurationTT? _defaultInstance;

  @$pb.TagNumber(1)
  MODEL get model => $_getN(0);
  @$pb.TagNumber(1)
  set model(MODEL value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serial => $_getIZ(1);
  @$pb.TagNumber(2)
  set serial($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  /// (xxxxx is decimal for last two bytes of MAC
  @$pb.TagNumber(3)
  $core.int get hiMAC => $_getIZ(2);
  @$pb.TagNumber(3)
  set hiMAC($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHiMAC() => $_has(2);
  @$pb.TagNumber(3)
  void clearHiMAC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get calibrationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set calibrationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCalibrationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCalibrationDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expirationDate => $_getIZ(4);
  @$pb.TagNumber(5)
  set expirationDate($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpirationDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpirationDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get variant => $_getSZ(5);
  @$pb.TagNumber(6)
  set variant($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVariant() => $_has(5);
  @$pb.TagNumber(6)
  void clearVariant() => $_clearField(6);

  @$pb.TagNumber(16)
  factoryCalibrationPolyPT get calibrationCh1 => $_getN(6);
  @$pb.TagNumber(16)
  set calibrationCh1(factoryCalibrationPolyPT value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(6);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  factoryCalibrationPolyPT ensureCalibrationCh1() => $_ensure(6);

  @$pb.TagNumber(17)
  factoryCalibrationPolyPT get calibrationCh2 => $_getN(7);
  @$pb.TagNumber(17)
  set calibrationCh2(factoryCalibrationPolyPT value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCalibrationCh2() => $_has(7);
  @$pb.TagNumber(17)
  void clearCalibrationCh2() => $_clearField(17);
  @$pb.TagNumber(17)
  factoryCalibrationPolyPT ensureCalibrationCh2() => $_ensure(7);
}

class factoryConfigurationTP extends $pb.GeneratedMessage {
  factory factoryConfigurationTP({
    MODEL? model,
    $core.int? serial,
    $core.int? hiMAC,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    $core.String? variant,
    factoryCalibrationPolyPT? calibrationCh1,
    factoryCalibrationPolyList? calibrationCh2,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (hiMAC != null) result.hiMAC = hiMAC;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (variant != null) result.variant = variant;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    if (calibrationCh2 != null) result.calibrationCh2 = calibrationCh2;
    return result;
  }

  factoryConfigurationTP._();

  factory factoryConfigurationTP.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryConfigurationTP.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryConfigurationTP', createEmptyInstance: create)
    ..e<MODEL>(1, _omitFieldNames ? '' : 'model', $pb.PbFieldType.OE, defaultOrMaker: MODEL.UNDEFINED, valueOf: MODEL.valueOf, enumValues: MODEL.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'serial', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'HiMAC', $pb.PbFieldType.OF3, protoName: 'HiMAC')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOS(6, _omitFieldNames ? '' : 'variant')
    ..aOM<factoryCalibrationPolyPT>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: factoryCalibrationPolyPT.create)
    ..aOM<factoryCalibrationPolyList>(17, _omitFieldNames ? '' : 'calibrationCh2', protoName: 'calibrationCh2', subBuilder: factoryCalibrationPolyList.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTP clone() => factoryConfigurationTP()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTP copyWith(void Function(factoryConfigurationTP) updates) => super.copyWith((message) => updates(message as factoryConfigurationTP)) as factoryConfigurationTP;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTP create() => factoryConfigurationTP._();
  @$core.override
  factoryConfigurationTP createEmptyInstance() => create();
  static $pb.PbList<factoryConfigurationTP> createRepeated() => $pb.PbList<factoryConfigurationTP>();
  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTP getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryConfigurationTP>(create);
  static factoryConfigurationTP? _defaultInstance;

  @$pb.TagNumber(1)
  MODEL get model => $_getN(0);
  @$pb.TagNumber(1)
  set model(MODEL value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serial => $_getIZ(1);
  @$pb.TagNumber(2)
  set serial($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  /// (xxxxx is decimal for last two bytes of MAC
  @$pb.TagNumber(3)
  $core.int get hiMAC => $_getIZ(2);
  @$pb.TagNumber(3)
  set hiMAC($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHiMAC() => $_has(2);
  @$pb.TagNumber(3)
  void clearHiMAC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get calibrationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set calibrationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCalibrationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCalibrationDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expirationDate => $_getIZ(4);
  @$pb.TagNumber(5)
  set expirationDate($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpirationDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpirationDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get variant => $_getSZ(5);
  @$pb.TagNumber(6)
  set variant($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVariant() => $_has(5);
  @$pb.TagNumber(6)
  void clearVariant() => $_clearField(6);

  @$pb.TagNumber(16)
  factoryCalibrationPolyPT get calibrationCh1 => $_getN(6);
  @$pb.TagNumber(16)
  set calibrationCh1(factoryCalibrationPolyPT value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(6);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  factoryCalibrationPolyPT ensureCalibrationCh1() => $_ensure(6);

  @$pb.TagNumber(17)
  factoryCalibrationPolyList get calibrationCh2 => $_getN(7);
  @$pb.TagNumber(17)
  set calibrationCh2(factoryCalibrationPolyList value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCalibrationCh2() => $_has(7);
  @$pb.TagNumber(17)
  void clearCalibrationCh2() => $_clearField(17);
  @$pb.TagNumber(17)
  factoryCalibrationPolyList ensureCalibrationCh2() => $_ensure(7);
}

class factoryConfigurationTH extends $pb.GeneratedMessage {
  factory factoryConfigurationTH({
    MODEL? model,
    $core.int? serial,
    $core.int? hiMAC,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    $core.String? variant,
    factoryCalibrationPolyPT? calibrationCh1,
  }) {
    final result = create();
    if (model != null) result.model = model;
    if (serial != null) result.serial = serial;
    if (hiMAC != null) result.hiMAC = hiMAC;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (variant != null) result.variant = variant;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    return result;
  }

  factoryConfigurationTH._();

  factory factoryConfigurationTH.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory factoryConfigurationTH.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'factoryConfigurationTH', createEmptyInstance: create)
    ..e<MODEL>(1, _omitFieldNames ? '' : 'model', $pb.PbFieldType.OE, defaultOrMaker: MODEL.UNDEFINED, valueOf: MODEL.valueOf, enumValues: MODEL.values)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'serial', $pb.PbFieldType.OF3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'HiMAC', $pb.PbFieldType.OF3, protoName: 'HiMAC')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOS(6, _omitFieldNames ? '' : 'variant')
    ..aOM<factoryCalibrationPolyPT>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: factoryCalibrationPolyPT.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTH clone() => factoryConfigurationTH()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  factoryConfigurationTH copyWith(void Function(factoryConfigurationTH) updates) => super.copyWith((message) => updates(message as factoryConfigurationTH)) as factoryConfigurationTH;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTH create() => factoryConfigurationTH._();
  @$core.override
  factoryConfigurationTH createEmptyInstance() => create();
  static $pb.PbList<factoryConfigurationTH> createRepeated() => $pb.PbList<factoryConfigurationTH>();
  @$core.pragma('dart2js:noInline')
  static factoryConfigurationTH getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<factoryConfigurationTH>(create);
  static factoryConfigurationTH? _defaultInstance;

  @$pb.TagNumber(1)
  MODEL get model => $_getN(0);
  @$pb.TagNumber(1)
  set model(MODEL value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasModel() => $_has(0);
  @$pb.TagNumber(1)
  void clearModel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get serial => $_getIZ(1);
  @$pb.TagNumber(2)
  set serial($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSerial() => $_has(1);
  @$pb.TagNumber(2)
  void clearSerial() => $_clearField(2);

  /// (xxxxx is decimal for last two bytes of MAC
  @$pb.TagNumber(3)
  $core.int get hiMAC => $_getIZ(2);
  @$pb.TagNumber(3)
  set hiMAC($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHiMAC() => $_has(2);
  @$pb.TagNumber(3)
  void clearHiMAC() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get calibrationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set calibrationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCalibrationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCalibrationDate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get expirationDate => $_getIZ(4);
  @$pb.TagNumber(5)
  set expirationDate($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpirationDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpirationDate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get variant => $_getSZ(5);
  @$pb.TagNumber(6)
  set variant($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVariant() => $_has(5);
  @$pb.TagNumber(6)
  void clearVariant() => $_clearField(6);

  @$pb.TagNumber(16)
  factoryCalibrationPolyPT get calibrationCh1 => $_getN(6);
  @$pb.TagNumber(16)
  set calibrationCh1(factoryCalibrationPolyPT value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(6);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  factoryCalibrationPolyPT ensureCalibrationCh1() => $_ensure(6);
}

class userCalibrationPolyRange extends $pb.GeneratedMessage {
  factory userCalibrationPolyRange({
    $core.double? partialStart,
    $core.double? fullStart,
    $core.double? fullStop,
    $core.double? partialStop,
    $core.Iterable<$core.double>? coefficients,
  }) {
    final result = create();
    if (partialStart != null) result.partialStart = partialStart;
    if (fullStart != null) result.fullStart = fullStart;
    if (fullStop != null) result.fullStop = fullStop;
    if (partialStop != null) result.partialStop = partialStop;
    if (coefficients != null) result.coefficients.addAll(coefficients);
    return result;
  }

  userCalibrationPolyRange._();

  factory userCalibrationPolyRange.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory userCalibrationPolyRange.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'userCalibrationPolyRange', createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'partialStart', $pb.PbFieldType.OF, protoName: 'partialStart')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'fullStart', $pb.PbFieldType.OF, protoName: 'fullStart')
    ..a<$core.double>(3, _omitFieldNames ? '' : 'fullStop', $pb.PbFieldType.OF, protoName: 'fullStop')
    ..a<$core.double>(4, _omitFieldNames ? '' : 'partialStop', $pb.PbFieldType.OF, protoName: 'partialStop')
    ..p<$core.double>(5, _omitFieldNames ? '' : 'coefficients', $pb.PbFieldType.KF)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userCalibrationPolyRange clone() => userCalibrationPolyRange()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userCalibrationPolyRange copyWith(void Function(userCalibrationPolyRange) updates) => super.copyWith((message) => updates(message as userCalibrationPolyRange)) as userCalibrationPolyRange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static userCalibrationPolyRange create() => userCalibrationPolyRange._();
  @$core.override
  userCalibrationPolyRange createEmptyInstance() => create();
  static $pb.PbList<userCalibrationPolyRange> createRepeated() => $pb.PbList<userCalibrationPolyRange>();
  @$core.pragma('dart2js:noInline')
  static userCalibrationPolyRange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<userCalibrationPolyRange>(create);
  static userCalibrationPolyRange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get partialStart => $_getN(0);
  @$pb.TagNumber(1)
  set partialStart($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPartialStart() => $_has(0);
  @$pb.TagNumber(1)
  void clearPartialStart() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get fullStart => $_getN(1);
  @$pb.TagNumber(2)
  set fullStart($core.double value) => $_setFloat(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFullStart() => $_has(1);
  @$pb.TagNumber(2)
  void clearFullStart() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get fullStop => $_getN(2);
  @$pb.TagNumber(3)
  set fullStop($core.double value) => $_setFloat(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFullStop() => $_has(2);
  @$pb.TagNumber(3)
  void clearFullStop() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get partialStop => $_getN(3);
  @$pb.TagNumber(4)
  set partialStop($core.double value) => $_setFloat(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPartialStop() => $_has(3);
  @$pb.TagNumber(4)
  void clearPartialStop() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get coefficients => $_getList(4);
}

class userConfigurationT extends $pb.GeneratedMessage {
  factory userConfigurationT({
    $core.int? options,
    $core.String? description,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    userCalibrationPolyRange? calibrationCh1,
  }) {
    final result = create();
    if (options != null) result.options = options;
    if (description != null) result.description = description;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    return result;
  }

  userConfigurationT._();

  factory userConfigurationT.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory userConfigurationT.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'userConfigurationT', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'options', $pb.PbFieldType.OF3)
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOM<userCalibrationPolyRange>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: userCalibrationPolyRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationT clone() => userConfigurationT()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationT copyWith(void Function(userConfigurationT) updates) => super.copyWith((message) => updates(message as userConfigurationT)) as userConfigurationT;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static userConfigurationT create() => userConfigurationT._();
  @$core.override
  userConfigurationT createEmptyInstance() => create();
  static $pb.PbList<userConfigurationT> createRepeated() => $pb.PbList<userConfigurationT>();
  @$core.pragma('dart2js:noInline')
  static userConfigurationT getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<userConfigurationT>(create);
  static userConfigurationT? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get options => $_getIZ(0);
  @$pb.TagNumber(1)
  set options($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptions() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptions() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get calibrationDate => $_getIZ(2);
  @$pb.TagNumber(3)
  set calibrationDate($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCalibrationDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearCalibrationDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expirationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set expirationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpirationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpirationDate() => $_clearField(4);

  @$pb.TagNumber(16)
  userCalibrationPolyRange get calibrationCh1 => $_getN(4);
  @$pb.TagNumber(16)
  set calibrationCh1(userCalibrationPolyRange value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(4);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  userCalibrationPolyRange ensureCalibrationCh1() => $_ensure(4);
}

class userConfigurationTT extends $pb.GeneratedMessage {
  factory userConfigurationTT({
    $core.int? options,
    $core.String? description,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    userCalibrationPolyRange? calibrationCh1,
    userCalibrationPolyRange? calibrationCh2,
  }) {
    final result = create();
    if (options != null) result.options = options;
    if (description != null) result.description = description;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    if (calibrationCh2 != null) result.calibrationCh2 = calibrationCh2;
    return result;
  }

  userConfigurationTT._();

  factory userConfigurationTT.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory userConfigurationTT.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'userConfigurationTT', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'options', $pb.PbFieldType.OF3)
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOM<userCalibrationPolyRange>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: userCalibrationPolyRange.create)
    ..aOM<userCalibrationPolyRange>(17, _omitFieldNames ? '' : 'calibrationCh2', protoName: 'calibrationCh2', subBuilder: userCalibrationPolyRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTT clone() => userConfigurationTT()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTT copyWith(void Function(userConfigurationTT) updates) => super.copyWith((message) => updates(message as userConfigurationTT)) as userConfigurationTT;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static userConfigurationTT create() => userConfigurationTT._();
  @$core.override
  userConfigurationTT createEmptyInstance() => create();
  static $pb.PbList<userConfigurationTT> createRepeated() => $pb.PbList<userConfigurationTT>();
  @$core.pragma('dart2js:noInline')
  static userConfigurationTT getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<userConfigurationTT>(create);
  static userConfigurationTT? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get options => $_getIZ(0);
  @$pb.TagNumber(1)
  set options($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptions() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptions() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get calibrationDate => $_getIZ(2);
  @$pb.TagNumber(3)
  set calibrationDate($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCalibrationDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearCalibrationDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expirationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set expirationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpirationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpirationDate() => $_clearField(4);

  @$pb.TagNumber(16)
  userCalibrationPolyRange get calibrationCh1 => $_getN(4);
  @$pb.TagNumber(16)
  set calibrationCh1(userCalibrationPolyRange value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(4);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  userCalibrationPolyRange ensureCalibrationCh1() => $_ensure(4);

  @$pb.TagNumber(17)
  userCalibrationPolyRange get calibrationCh2 => $_getN(5);
  @$pb.TagNumber(17)
  set calibrationCh2(userCalibrationPolyRange value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCalibrationCh2() => $_has(5);
  @$pb.TagNumber(17)
  void clearCalibrationCh2() => $_clearField(17);
  @$pb.TagNumber(17)
  userCalibrationPolyRange ensureCalibrationCh2() => $_ensure(5);
}

class userConfigurationTP extends $pb.GeneratedMessage {
  factory userConfigurationTP({
    $core.int? options,
    $core.String? description,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    userCalibrationPolyRange? calibrationCh1,
  }) {
    final result = create();
    if (options != null) result.options = options;
    if (description != null) result.description = description;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    return result;
  }

  userConfigurationTP._();

  factory userConfigurationTP.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory userConfigurationTP.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'userConfigurationTP', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'options', $pb.PbFieldType.OF3)
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOM<userCalibrationPolyRange>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: userCalibrationPolyRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTP clone() => userConfigurationTP()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTP copyWith(void Function(userConfigurationTP) updates) => super.copyWith((message) => updates(message as userConfigurationTP)) as userConfigurationTP;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static userConfigurationTP create() => userConfigurationTP._();
  @$core.override
  userConfigurationTP createEmptyInstance() => create();
  static $pb.PbList<userConfigurationTP> createRepeated() => $pb.PbList<userConfigurationTP>();
  @$core.pragma('dart2js:noInline')
  static userConfigurationTP getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<userConfigurationTP>(create);
  static userConfigurationTP? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get options => $_getIZ(0);
  @$pb.TagNumber(1)
  set options($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptions() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptions() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get calibrationDate => $_getIZ(2);
  @$pb.TagNumber(3)
  set calibrationDate($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCalibrationDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearCalibrationDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expirationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set expirationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpirationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpirationDate() => $_clearField(4);

  @$pb.TagNumber(16)
  userCalibrationPolyRange get calibrationCh1 => $_getN(4);
  @$pb.TagNumber(16)
  set calibrationCh1(userCalibrationPolyRange value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(4);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  userCalibrationPolyRange ensureCalibrationCh1() => $_ensure(4);
}

class userConfigurationTH extends $pb.GeneratedMessage {
  factory userConfigurationTH({
    $core.int? options,
    $core.String? description,
    $core.int? calibrationDate,
    $core.int? expirationDate,
    userCalibrationPolyRange? calibrationCh1,
    userCalibrationPolyRange? calibrationCh2,
  }) {
    final result = create();
    if (options != null) result.options = options;
    if (description != null) result.description = description;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (expirationDate != null) result.expirationDate = expirationDate;
    if (calibrationCh1 != null) result.calibrationCh1 = calibrationCh1;
    if (calibrationCh2 != null) result.calibrationCh2 = calibrationCh2;
    return result;
  }

  userConfigurationTH._();

  factory userConfigurationTH.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(data, registry);
  factory userConfigurationTH.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'userConfigurationTH', createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'options', $pb.PbFieldType.OF3)
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'calibrationDate', $pb.PbFieldType.OF3, protoName: 'calibrationDate')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'expirationDate', $pb.PbFieldType.OF3, protoName: 'expirationDate')
    ..aOM<userCalibrationPolyRange>(16, _omitFieldNames ? '' : 'calibrationCh1', protoName: 'calibrationCh1', subBuilder: userCalibrationPolyRange.create)
    ..aOM<userCalibrationPolyRange>(17, _omitFieldNames ? '' : 'calibrationCh2', protoName: 'calibrationCh2', subBuilder: userCalibrationPolyRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTH clone() => userConfigurationTH()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  userConfigurationTH copyWith(void Function(userConfigurationTH) updates) => super.copyWith((message) => updates(message as userConfigurationTH)) as userConfigurationTH;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static userConfigurationTH create() => userConfigurationTH._();
  @$core.override
  userConfigurationTH createEmptyInstance() => create();
  static $pb.PbList<userConfigurationTH> createRepeated() => $pb.PbList<userConfigurationTH>();
  @$core.pragma('dart2js:noInline')
  static userConfigurationTH getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<userConfigurationTH>(create);
  static userConfigurationTH? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get options => $_getIZ(0);
  @$pb.TagNumber(1)
  set options($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOptions() => $_has(0);
  @$pb.TagNumber(1)
  void clearOptions() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get calibrationDate => $_getIZ(2);
  @$pb.TagNumber(3)
  set calibrationDate($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCalibrationDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearCalibrationDate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get expirationDate => $_getIZ(3);
  @$pb.TagNumber(4)
  set expirationDate($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasExpirationDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpirationDate() => $_clearField(4);

  @$pb.TagNumber(16)
  userCalibrationPolyRange get calibrationCh1 => $_getN(4);
  @$pb.TagNumber(16)
  set calibrationCh1(userCalibrationPolyRange value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCalibrationCh1() => $_has(4);
  @$pb.TagNumber(16)
  void clearCalibrationCh1() => $_clearField(16);
  @$pb.TagNumber(16)
  userCalibrationPolyRange ensureCalibrationCh1() => $_ensure(4);

  @$pb.TagNumber(17)
  userCalibrationPolyRange get calibrationCh2 => $_getN(5);
  @$pb.TagNumber(17)
  set calibrationCh2(userCalibrationPolyRange value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCalibrationCh2() => $_has(5);
  @$pb.TagNumber(17)
  void clearCalibrationCh2() => $_clearField(17);
  @$pb.TagNumber(17)
  userCalibrationPolyRange ensureCalibrationCh2() => $_ensure(5);
}


const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');