# alsos\_bluewave

Pure Dart library for parsing, serializing and managing BLE commands for **BlueWave** data loggers by Tecnosoft, as part of the **Alsos** architecture.

> ℹ️ To compile and run the example, see [example/README.md](./example/README.md)

---

## 🚀 Features

* Parses **System Info** packets (60 bytes)
* Parses real-time advertising packets into user-friendly maps
* Parses acquisition logs and factory/user calibration
* Includes a Flutter example showcasing:

  * **Scanning** for BlueWave devices
  * **Reading** BLE characteristics
  * **Starting missions** on multiple devices
  * **Real-time preview**
  * **Downloading and decoding data** as Mission BLOB

---

## 📦 Installing

To use this library in a Flutter project, add the following to your `pubspec.yaml`:

```yaml
dependencies:
  alsos_bluewave: ^0.2.0   # latest published tag
```

---

## 📁 Project Structure

```
alsos_bluewave/
├── lib/                   # Dart library source code
├── example/               # Flutter integration example
│   ├── lib/               # Entry point of the example app
│   ├── android/ios/...    # Platform-specific files (auto-generated)
│   └── README.md          # Instructions to compile and run the example
├── pubspec.yaml           # Library package definition
└── README.md              # Main documentation (this file)
```

This library is designed to be included as a **Git submodule** in the main `alsos/` repository.

---

## 🧩 Dependencies & Licenses

This library relies on the following dependencies:

```yaml
dependencies:
  collection: ^1.19.1
  flutter_blue_plus: ^1.35.5
  permission_handler: ^12.0.1
```

| Package              | License                                                                            | Commercial Use |
| -------------------- | ---------------------------------------------------------------------------------- | -------------- |
| `collection`         | BSD‑3‑Clause                                                                       | ✅ Allowed      |
| `flutter_blue_plus`  | BSD‑3‑Clause ([RPMGlobal][1], [Stack Overflow][2], [Gitee][3], [Dart packages][4]) | ✅ Allowed      |
| `permission_handler` | MIT                                                                                | ✅ Allowed      |

All dependencies are **compatible with commercial use**, subject to license compliance.

---

## 🧰 How to compile and run the example

The `example/` folder contains a Flutter demo.

```bash
cd example
flutter pub get
flutter run
```

Ensure a physical Android/iOS device is connected. The app scans for BlueWave devices and allows mission configuration, start, live monitoring, and data download.

---

## 📊 API Reference (BlueWaveDevice)

### Static methods

#### `startScan()`

Starts BLE scan.

```dart
BlueWaveDevice.startScan();
```

#### `stopScan()`

Stops BLE scan.

```dart
BlueWaveDevice.stopScan();
```

#### `scanResults`

Returns a stream of devices as `List<Map<String, dynamic>>`, including id, name, manufacturer, status, and real-time values.

```dart
StreamBuilder(
  stream: BlueWaveDevice.scanResults,
  builder: (_, snap) => ...
)
```

#### `connect(String id)`

Connects to a device by ID.

```dart
final device = await BlueWaveDevice.connect(id);
```

#### `disconnectAll(List<BlueWaveDevice>)`

Disconnects all connected devices.

```dart
await BlueWaveDevice.disconnectAll(devices);
```

### Instance methods

#### `disconnect()`

Disconnects the device.

```dart
await device.disconnect();
```

#### `readSystemInfo()`

Returns metadata like model, version, MAC, memory, battery.

```dart
final info = await device.readSystemInfo();
```

#### `readDeviceInformation()`

Reads manufacturer, model, and hardware revision.

```dart
final data = await device.readDeviceInformation();
```

#### `readCurrentData()`

Returns latest measurement values (raw/factory/user).

```dart
final current = await device.readCurrentData();
```

#### `startMission(...)`

Starts a new mission with parameters like delay, frequency, duration, flags, and channel selection.

```dart
await device.startMission(
  delay: Duration(seconds: 0),
  frequency: Duration(seconds: 10),
  duration: Duration(minutes: 5),
  flags: 0x8000,
  checkTrigger: 0,
  enableCh0: true,
  enableCh1: true,
);
```

#### `stopMission()`

Sends a special MissionSetupPacket to stop the device.

```dart
await device.stopMission();
```

#### `downloadAcquisitions()`

Downloads, decodes and calibrates logged data.
Returns an `AcquisitionInfo` object with summary, samples, configs and recovery info.

```dart
final info = await device.downloadAcquisitions();
print(info.summary);
```

#### `toMissionBlob()`

Returns a Map compatible with the expected Mission BLOB JSON format.

```dart
final blob = await device.toMissionBlob();
```

---

## 📓 Documentation

For protocol details (UUIDs, packet formats, mission structure), refer to Tecnosoft’s internal documentation:

* *BlueWave Technical Reference*
* *DISK Protocol*
* *Data Distribution Infrastructure*

---

## 🔗 Useful Links

* [flutter\_blue\_plus](https://pub.dev/packages/flutter_blue_plus)
* [permission\_handler](https://pub.dev/packages/permission_handler)
* [Main Alsos repository](https://github.com/tecnosoft/alsos)

---

## 🌐 License

External dependencies are released under BSD‑3–Clause and MIT licenses.
