// lib/uuid/bluewave_uuids.dart

import '../ble/ble_adapter.dart';

/// Primary BlueWave custom services
const Guid bluewaveService1 = Guid('4f460001-6357-4391-af80-a7adcca8026d');
const Guid bluewaveService2 = Guid('1d14d6ee-fd63-4fa1-bfa4-8f47b42119f0');

/// Characteristics under bluewaveService1

const Guid bluewaveFactoryConfiguration = Guid('4f460002-6357-4391-af80-a7adcca8026d');
const Guid bluewaveUserConfiguration = Guid('4f460003-6357-4391-af80-a7adcca8026d');
const Guid bluewaveMissionSetup = Guid('4f460004-6357-4391-af80-a7adcca8026d');
const Guid bluewaveLogCursor = Guid('4f460005-6357-4391-af80-a7adcca8026d');
const Guid bluewaveLogData = Guid('4f460006-6357-4391-af80-a7adcca8026d');
const Guid bluewaveCurrentData = Guid('4f460007-6357-4391-af80-a7adcca8026d');
const Guid bluewaveSystemInfo = Guid('4f460008-6357-4391-af80-a7adcca8026d');
const Guid bluewaveCommand = Guid('4f460009-6357-4391-af80-a7adcca8026d');

/// Characteristic under bluewaveService2

const Guid bluewaveFirmwareUpgrade = Guid('f7bf3564-fb6d-4e53-88a4-5e37e0326063');

/// Standard GATT services

const Guid genericAttributeService = Guid('00001801-0000-1000-8000-00805f9b34fb');
const Guid genericAccessService = Guid('00001800-0000-1000-8000-00805f9b34fb');
const Guid deviceInfoService = Guid('0000180A-0000-1000-8000-00805F9B34FB');

/// Characteristics for Generic Attribute Service

const Guid serviceChangedChar = Guid('00002A05-0000-1000-8000-00805f9b34fb');
const Guid databaseHashChar = Guid('00002B2A-0000-1000-8000-00805f9b34fb');
const Guid clientSupportedFeaturesChar = Guid('00002B29-0000-1000-8000-00805f9b34fb');

/// Characteristics for Generic Access Service

const Guid deviceNameChar = Guid('00002A00-0000-1000-8000-00805f9b34fb');
const Guid appearanceChar = Guid('00002A01-0000-1000-8000-00805f9b34fb');

/// Characteristics for Device Information Service

const Guid deviceManufacturerChar = Guid('00002A29-0000-1000-8000-00805F9B34FB');
const Guid deviceModelChar = Guid('00002A24-0000-1000-8000-00805F9B34FB');
const Guid deviceHwRevChar = Guid('00002A27-0000-1000-8000-00805F9B34FB');
const Guid deviceFwRevChar = Guid('00002A26-0000-1000-8000-00805F9B34FB');
const Guid deviceSwRevChar = Guid('00002A28-0000-1000-8000-00805F9B34FB');
const Guid systemIdChar = Guid('00002A23-0000-1000-8000-00805F9B34FB');
