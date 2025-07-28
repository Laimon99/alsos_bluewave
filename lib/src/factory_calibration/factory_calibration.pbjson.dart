// This is a generated file - do not edit.
//
// Generated from BlueWave.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use mODELDescriptor instead')
const MODEL$json = {
  '1': 'MODEL',
  '2': [
    {'1': 'UNDEFINED', '2': 0},
    {'1': 'BLUEWAVE_T', '2': 1},
    {'1': 'BLUEWAVE_TT', '2': 2},
    {'1': 'BLUEWAVE_P', '2': 3},
    {'1': 'BLUEWAVE_TP', '2': 4},
    {'1': 'BLUEWAVE_TH', '2': 5},
  ],
};

/// Descriptor for `MODEL`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mODELDescriptor = $convert.base64Decode(
    'CgVNT0RFTBINCglVTkRFRklORUQQABIOCgpCTFVFV0FWRV9UEAESDwoLQkxVRVdBVkVfVFQQAh'
    'IOCgpCTFVFV0FWRV9QEAMSDwoLQkxVRVdBVkVfVFAQBBIPCgtCTFVFV0FWRV9USBAF');

@$core.Deprecated('Use factoryCalibrationPolyDescriptor instead')
const factoryCalibrationPoly$json = {
  '1': 'factoryCalibrationPoly',
  '2': [
    {'1': 'coefficients', '3': 1, '4': 3, '5': 2, '10': 'coefficients'},
  ],
};

/// Descriptor for `factoryCalibrationPoly`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryCalibrationPolyDescriptor = $convert.base64Decode(
    'ChZmYWN0b3J5Q2FsaWJyYXRpb25Qb2x5EiIKDGNvZWZmaWNpZW50cxgBIAMoAlIMY29lZmZpY2'
    'llbnRz');

@$core.Deprecated('Use factoryCalibrationPolyPTDescriptor instead')
const factoryCalibrationPolyPT$json = {
  '1': 'factoryCalibrationPolyPT',
  '2': [
    {'1': 'reference', '3': 1, '4': 1, '5': 2, '10': 'reference'},
    {'1': 'coefficients', '3': 2, '4': 3, '5': 2, '10': 'coefficients'},
    {'1': 'rawScale', '3': 14, '4': 1, '5': 2, '9': 0, '10': 'rawScale', '17': true},
    {'1': 'rawOffset', '3': 15, '4': 1, '5': 2, '9': 1, '10': 'rawOffset', '17': true},
  ],
  '8': [
    {'1': '_rawScale'},
    {'1': '_rawOffset'},
  ],
};

/// Descriptor for `factoryCalibrationPolyPT`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryCalibrationPolyPTDescriptor = $convert.base64Decode(
    'ChhmYWN0b3J5Q2FsaWJyYXRpb25Qb2x5UFQSHAoJcmVmZXJlbmNlGAEgASgCUglyZWZlcmVuY2'
    'USIgoMY29lZmZpY2llbnRzGAIgAygCUgxjb2VmZmljaWVudHMSHwoIcmF3U2NhbGUYDiABKAJI'
    'AFIIcmF3U2NhbGWIAQESIQoJcmF3T2Zmc2V0GA8gASgCSAFSCXJhd09mZnNldIgBAUILCglfcm'
    'F3U2NhbGVCDAoKX3Jhd09mZnNldA==');

@$core.Deprecated('Use factoryCalibrationPolyListDescriptor instead')
const factoryCalibrationPolyList$json = {
  '1': 'factoryCalibrationPolyList',
  '2': [
    {'1': 'polyList', '3': 1, '4': 3, '5': 11, '6': '.factoryCalibrationPoly', '10': 'polyList'},
    {'1': 'rawScale', '3': 14, '4': 1, '5': 2, '9': 0, '10': 'rawScale', '17': true},
    {'1': 'rawOffset', '3': 15, '4': 1, '5': 2, '9': 1, '10': 'rawOffset', '17': true},
  ],
  '8': [
    {'1': '_rawScale'},
    {'1': '_rawOffset'},
  ],
};

/// Descriptor for `factoryCalibrationPolyList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryCalibrationPolyListDescriptor = $convert.base64Decode(
    'ChpmYWN0b3J5Q2FsaWJyYXRpb25Qb2x5TGlzdBIzCghwb2x5TGlzdBgBIAMoCzIXLmZhY3Rvcn'
    'lDYWxpYnJhdGlvblBvbHlSCHBvbHlMaXN0Eh8KCHJhd1NjYWxlGA4gASgCSABSCHJhd1NjYWxl'
    'iAEBEiEKCXJhd09mZnNldBgPIAEoAkgBUglyYXdPZmZzZXSIAQFCCwoJX3Jhd1NjYWxlQgwKCl'
    '9yYXdPZmZzZXQ=');

@$core.Deprecated('Use factoryConfigurationTDescriptor instead')
const factoryConfigurationT$json = {
  '1': 'factoryConfigurationT',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 14, '6': '.MODEL', '10': 'model'},
    {'1': 'variant', '3': 6, '4': 1, '5': 9, '10': 'variant'},
    {'1': 'serial', '3': 2, '4': 1, '5': 7, '10': 'serial'},
    {'1': 'HiMAC', '3': 3, '4': 1, '5': 7, '10': 'HiMAC'},
    {'1': 'calibrationDate', '3': 4, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 5, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.factoryCalibrationPolyPT', '10': 'calibrationCh1'},
  ],
};

/// Descriptor for `factoryConfigurationT`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryConfigurationTDescriptor = $convert.base64Decode(
    'ChVmYWN0b3J5Q29uZmlndXJhdGlvblQSHAoFbW9kZWwYASABKA4yBi5NT0RFTFIFbW9kZWwSGA'
    'oHdmFyaWFudBgGIAEoCVIHdmFyaWFudBIWCgZzZXJpYWwYAiABKAdSBnNlcmlhbBIUCgVIaU1B'
    'QxgDIAEoB1IFSGlNQUMSKAoPY2FsaWJyYXRpb25EYXRlGAQgASgHUg9jYWxpYnJhdGlvbkRhdG'
    'USJgoOZXhwaXJhdGlvbkRhdGUYBSABKAdSDmV4cGlyYXRpb25EYXRlEkEKDmNhbGlicmF0aW9u'
    'Q2gxGBAgASgLMhkuZmFjdG9yeUNhbGlicmF0aW9uUG9seVBUUg5jYWxpYnJhdGlvbkNoMQ==');

@$core.Deprecated('Use factoryConfigurationTTDescriptor instead')
const factoryConfigurationTT$json = {
  '1': 'factoryConfigurationTT',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 14, '6': '.MODEL', '10': 'model'},
    {'1': 'variant', '3': 6, '4': 1, '5': 9, '10': 'variant'},
    {'1': 'serial', '3': 2, '4': 1, '5': 7, '10': 'serial'},
    {'1': 'HiMAC', '3': 3, '4': 1, '5': 7, '10': 'HiMAC'},
    {'1': 'calibrationDate', '3': 4, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 5, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.factoryCalibrationPolyPT', '10': 'calibrationCh1'},
    {'1': 'calibrationCh2', '3': 17, '4': 1, '5': 11, '6': '.factoryCalibrationPolyPT', '10': 'calibrationCh2'},
  ],
};

/// Descriptor for `factoryConfigurationTT`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryConfigurationTTDescriptor = $convert.base64Decode(
    'ChZmYWN0b3J5Q29uZmlndXJhdGlvblRUEhwKBW1vZGVsGAEgASgOMgYuTU9ERUxSBW1vZGVsEh'
    'gKB3ZhcmlhbnQYBiABKAlSB3ZhcmlhbnQSFgoGc2VyaWFsGAIgASgHUgZzZXJpYWwSFAoFSGlN'
    'QUMYAyABKAdSBUhpTUFDEigKD2NhbGlicmF0aW9uRGF0ZRgEIAEoB1IPY2FsaWJyYXRpb25EYX'
    'RlEiYKDmV4cGlyYXRpb25EYXRlGAUgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg5jYWxpYnJhdGlv'
    'bkNoMRgQIAEoCzIZLmZhY3RvcnlDYWxpYnJhdGlvblBvbHlQVFIOY2FsaWJyYXRpb25DaDESQQ'
    'oOY2FsaWJyYXRpb25DaDIYESABKAsyGS5mYWN0b3J5Q2FsaWJyYXRpb25Qb2x5UFRSDmNhbGli'
    'cmF0aW9uQ2gy');

@$core.Deprecated('Use factoryConfigurationTPDescriptor instead')
const factoryConfigurationTP$json = {
  '1': 'factoryConfigurationTP',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 14, '6': '.MODEL', '10': 'model'},
    {'1': 'variant', '3': 6, '4': 1, '5': 9, '10': 'variant'},
    {'1': 'serial', '3': 2, '4': 1, '5': 7, '10': 'serial'},
    {'1': 'HiMAC', '3': 3, '4': 1, '5': 7, '10': 'HiMAC'},
    {'1': 'calibrationDate', '3': 4, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 5, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.factoryCalibrationPolyPT', '10': 'calibrationCh1'},
    {'1': 'calibrationCh2', '3': 17, '4': 1, '5': 11, '6': '.factoryCalibrationPolyList', '10': 'calibrationCh2'},
  ],
};

/// Descriptor for `factoryConfigurationTP`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryConfigurationTPDescriptor = $convert.base64Decode(
    'ChZmYWN0b3J5Q29uZmlndXJhdGlvblRQEhwKBW1vZGVsGAEgASgOMgYuTU9ERUxSBW1vZGVsEh'
    'gKB3ZhcmlhbnQYBiABKAlSB3ZhcmlhbnQSFgoGc2VyaWFsGAIgASgHUgZzZXJpYWwSFAoFSGlN'
    'QUMYAyABKAdSBUhpTUFDEigKD2NhbGlicmF0aW9uRGF0ZRgEIAEoB1IPY2FsaWJyYXRpb25EYX'
    'RlEiYKDmV4cGlyYXRpb25EYXRlGAUgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg5jYWxpYnJhdGlv'
    'bkNoMRgQIAEoCzIZLmZhY3RvcnlDYWxpYnJhdGlvblBvbHlQVFIOY2FsaWJyYXRpb25DaDESQw'
    'oOY2FsaWJyYXRpb25DaDIYESABKAsyGy5mYWN0b3J5Q2FsaWJyYXRpb25Qb2x5TGlzdFIOY2Fs'
    'aWJyYXRpb25DaDI=');

@$core.Deprecated('Use factoryConfigurationTHDescriptor instead')
const factoryConfigurationTH$json = {
  '1': 'factoryConfigurationTH',
  '2': [
    {'1': 'model', '3': 1, '4': 1, '5': 14, '6': '.MODEL', '10': 'model'},
    {'1': 'variant', '3': 6, '4': 1, '5': 9, '10': 'variant'},
    {'1': 'serial', '3': 2, '4': 1, '5': 7, '10': 'serial'},
    {'1': 'HiMAC', '3': 3, '4': 1, '5': 7, '10': 'HiMAC'},
    {'1': 'calibrationDate', '3': 4, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 5, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.factoryCalibrationPolyPT', '10': 'calibrationCh1'},
  ],
};

/// Descriptor for `factoryConfigurationTH`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List factoryConfigurationTHDescriptor = $convert.base64Decode(
    'ChZmYWN0b3J5Q29uZmlndXJhdGlvblRIEhwKBW1vZGVsGAEgASgOMgYuTU9ERUxSBW1vZGVsEh'
    'gKB3ZhcmlhbnQYBiABKAlSB3ZhcmlhbnQSFgoGc2VyaWFsGAIgASgHUgZzZXJpYWwSFAoFSGlN'
    'QUMYAyABKAdSBUhpTUFDEigKD2NhbGlicmF0aW9uRGF0ZRgEIAEoB1IPY2FsaWJyYXRpb25EYX'
    'RlEiYKDmV4cGlyYXRpb25EYXRlGAUgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg5jYWxpYnJhdGlv'
    'bkNoMRgQIAEoCzIZLmZhY3RvcnlDYWxpYnJhdGlvblBvbHlQVFIOY2FsaWJyYXRpb25DaDE=');

@$core.Deprecated('Use userCalibrationPolyRangeDescriptor instead')
const userCalibrationPolyRange$json = {
  '1': 'userCalibrationPolyRange',
  '2': [
    {'1': 'partialStart', '3': 1, '4': 1, '5': 2, '10': 'partialStart'},
    {'1': 'fullStart', '3': 2, '4': 1, '5': 2, '10': 'fullStart'},
    {'1': 'fullStop', '3': 3, '4': 1, '5': 2, '10': 'fullStop'},
    {'1': 'partialStop', '3': 4, '4': 1, '5': 2, '10': 'partialStop'},
    {'1': 'coefficients', '3': 5, '4': 3, '5': 2, '10': 'coefficients'},
  ],
};

/// Descriptor for `userCalibrationPolyRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userCalibrationPolyRangeDescriptor = $convert.base64Decode(
    'Chh1c2VyQ2FsaWJyYXRpb25Qb2x5UmFuZ2USIgoMcGFydGlhbFN0YXJ0GAEgASgCUgxwYXJ0aW'
    'FsU3RhcnQSHAoJZnVsbFN0YXJ0GAIgASgCUglmdWxsU3RhcnQSGgoIZnVsbFN0b3AYAyABKAJS'
    'CGZ1bGxTdG9wEiAKC3BhcnRpYWxTdG9wGAQgASgCUgtwYXJ0aWFsU3RvcBIiCgxjb2VmZmljaW'
    'VudHMYBSADKAJSDGNvZWZmaWNpZW50cw==');

@$core.Deprecated('Use userConfigurationTDescriptor instead')
const userConfigurationT$json = {
  '1': 'userConfigurationT',
  '2': [
    {'1': 'options', '3': 1, '4': 1, '5': 7, '10': 'options'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'calibrationDate', '3': 3, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationzDate', '3': 4, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh1'},
  ],
};

/// Descriptor for `userConfigurationT`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConfigurationTDescriptor = $convert.base64Decode(
    'ChJ1c2VyQ29uZmlndXJhdGlvblQSGAoHb3B0aW9ucxgBIAEoB1IHb3B0aW9ucxIgCgtkZXNjcm'
    'lwdGlvbhgCIAEoCVILZGVzY3JpcHRpb24SKAoPY2FsaWJyYXRpb25EYXRlGAMgASgHUg9jYWxp'
    'YnJhdGlvbkRhdGUSJgoOZXhwaXJhdGlvbkRhdGUYBCABKAdSDmV4cGlyYXRpb25EYXRlEkEKDm'
    'NhbGlicmF0aW9uQ2gxGBAgASgLMhkudXNlckNhbGlicmF0aW9uUG9seVJhbmdlUg5jYWxpYnJh'
    'dGlvbkNoMQ==');

@$core.Deprecated('Use userConfigurationTTDescriptor instead')
const userConfigurationTT$json = {
  '1': 'userConfigurationTT',
  '2': [
    {'1': 'options', '3': 1, '4': 1, '5': 7, '10': 'options'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'calibrationDate', '3': 3, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 4, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh1'},
    {'1': 'calibrationCh2', '3': 17, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh2'},
  ],
};

/// Descriptor for `userConfigurationTT`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConfigurationTTDescriptor = $convert.base64Decode(
    'ChN1c2VyQ29uZmlndXJhdGlvblRUEhgKB29wdGlvbnMYASABKAdSB29wdGlvbnMSIAoLZGVzY3'
    'JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW9uEigKD2NhbGlicmF0aW9uRGF0ZRgDIAEoB1IPY2Fs'
    'aWJyYXRpb25EYXRlEiYKDmV4cGlyYXRpb25EYXRlGAQgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg'
    '5jYWxpYnJhdGlvbkNoMRgQIAEoCzIZLnVzZXJDYWxpYnJhdGlvblBvbHlSYW5nZVIOY2FsaWJy'
    'YXRpb25DaDESQQoOY2FsaWJyYXRpb25DaDIYESABKAsyGS51c2VyQ2FsaWJyYXRpb25Qb2x5Um'
    'FuZ2VSDmNhbGlicmF0aW9uQ2gy');

@$core.Deprecated('Use userConfigurationTPDescriptor instead')
const userConfigurationTP$json = {
  '1': 'userConfigurationTP',
  '2': [
    {'1': 'options', '3': 1, '4': 1, '5': 7, '10': 'options'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'calibrationDate', '3': 3, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 4, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh1'},
  ],
};

/// Descriptor for `userConfigurationTP`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConfigurationTPDescriptor = $convert.base64Decode(
    'ChN1c2VyQ29uZmlndXJhdGlvblRQEhgKB29wdGlvbnMYASABKAdSB29wdGlvbnMSIAoLZGVzY3'
    'JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW9uEigKD2NhbGlicmF0aW9uRGF0ZRgDIAEoB1IPY2Fs'
    'aWJyYXRpb25EYXRlEiYKDmV4cGlyYXRpb25EYXRlGAQgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg'
    '5jYWxpYnJhdGlvbkNoMRgQIAEoCzIZLnVzZXJDYWxpYnJhdGlvblBvbHlSYW5nZVIOY2FsaWJy'
    'YXRpb25DaDE=');

@$core.Deprecated('Use userConfigurationTHDescriptor instead')
const userConfigurationTH$json = {
  '1': 'userConfigurationTH',
  '2': [
    {'1': 'options', '3': 1, '4': 1, '5': 7, '10': 'options'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'calibrationDate', '3': 3, '4': 1, '5': 7, '10': 'calibrationDate'},
    {'1': 'expirationDate', '3': 4, '4': 1, '5': 7, '10': 'expirationDate'},
    {'1': 'calibrationCh1', '3': 16, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh1'},
    {'1': 'calibrationCh2', '3': 17, '4': 1, '5': 11, '6': '.userCalibrationPolyRange', '10': 'calibrationCh2'},
  ],
};

/// Descriptor for `userConfigurationTH`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userConfigurationTHDescriptor = $convert.base64Decode(
    'ChN1c2VyQ29uZmlndXJhdGlvblRIEhgKB29wdGlvbnMYASABKAdSB29wdGlvbnMSIAoLZGVzY3'
    'JpcHRpb24YAiABKAlSC2Rlc2NyaXB0aW9uEigKD2NhbGlicmF0aW9uRGF0ZRgDIAEoB1IPY2Fs'
    'aWJyYXRpb25EYXRlEiYKDmV4cGlyYXRpb25EYXRlGAQgASgHUg5leHBpcmF0aW9uRGF0ZRJBCg'
    '5jYWxpYnJhdGlvbkNoMRgQIAEoCzIZLnVzZXJDYWxpYnJhdGlvblBvbHlSYW5nZVIOY2FsaWJy'
    'YXRpb25DaDESQQoOY2FsaWJyYXRpb25DaDIYESABKAsyGS51c2VyQ2FsaWJyYXRpb25Qb2x5Um'
    'FuZ2VSDmNhbGlicmF0aW9uQ2gy');
