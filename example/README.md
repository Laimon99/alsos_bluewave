# BlueWave Example App

This is a Flutter example demonstrating the usage of the `alsos_bluewave` library to connect to Tecnosoft BlueWave data loggers.

---

## 📋 Requirements

- A physical Android or iOS device with Bluetooth enabled  
- Permissions for Bluetooth and location (Android ≥ 12 requires `BLUETOOTH_CONNECT`)  
- The `alsos_bluewave` package must be present in the parent directory (`../`)

---

## 🚀 How to Compile and Run

From this `example/` folder, follow these steps:

### 1. (Optional) If platform folders (`android/`, `ios/`, etc.) are missing:

```bash
flutter create .
```

This will generate the required files for building the app on your device.

### 2. Install dependencies and run the app:

```bash
flutter pub get
flutter run
```

Make sure that a physical device is connected and visible via:

```bash
flutter devices
```

If necessary, select the target device with:

```bash
flutter run -d <device_id>
```

---

## 🛠️ Notes

* This app scans for BlueWave loggers via Bluetooth, connects, and shows how to start a mission.
* On Android, ensure these permissions are present in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```

* On Android 12+, permissions must also be requested at runtime using `permission_handler`.

---

## ℹ️ Support

For further details, see the main library documentation in [../README.md](../README.md)
