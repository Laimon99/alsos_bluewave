import '../models/guid.dart';
import '../ble/ble_connection.dart';
import '../uuid/uuids.dart';

/// Extracts all required GATT characteristics and returns them via callback.
Future<void> resolveGattCharacteristics(
  BleConnection conn, {
  required void Function(Map<String, Guid>) assign,
}) async {
  final svcs = await conn.services();

  Guid? find(String uuid, {String? serviceUuid}) {
    String short(String u) {
      u = u.toLowerCase().replaceAll('-', '');
      return (u.length == 32 && u.startsWith('0000')) ? u.substring(4, 8) : u;
    }

    final target = short(uuid);
    final targetSvc = serviceUuid != null ? short(serviceUuid) : null;

    for (final s in svcs) {
      final sidRaw = (s as dynamic).uuid.toString();
      final sid = short(sidRaw);
      if (targetSvc != null && sid != targetSvc) continue;

      for (final c in (s as dynamic).characteristics as List<dynamic>) {
        final cidRaw = (c as dynamic).uuid.toString();
        final cid = short(cidRaw);
        if (cid == target) return Guid(cidRaw);
      }
    }
    return null;
  }

  final uuidMap = <String, Guid>{
    'sysInfo': find(bluewaveSystemInfo.value)!,
    'manufacturer': find(deviceManufacturerChar.value, serviceUuid: deviceInfoService.value)!,
    'model': find(deviceModelChar.value, serviceUuid: deviceInfoService.value)!,
    'hwRev': find(deviceHwRevChar.value, serviceUuid: deviceInfoService.value)!,
    'mission': find(bluewaveMissionSetup.value)!,
    'current': find(bluewaveCurrentData.value)!,
  };

  assign(uuidMap);
}
