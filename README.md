# alsos_bluewave

Libreria Pure Dart per il parsing, la serializzazione e i comandi BLE dei data-logger **BlueWave** di Tecnosoft, parte dell’architettura **Alsos**.

## 🚀 Features

- Parse dei pacchetti **System Info** (60 byte)  
- Dispatcher `BlueWavePacket.parse()` per riconoscere il tipo di pacchetto  
- Esempio Flutter che dimostra:
  - **Scan** dei dispositivi BlueWave  
  - **Read** delle caratteristiche  
  - **Start mission** su più dispositivi  

---

## 📦 Installing

Aggiungi nelle dependencies del progetto Flutter:

```yaml
dependencies:
  alsos_bluewave: ^0.2.0   # ultimo tag pubblicato
````

---

## 🧩 Dipendenze e licenze

La libreria si basa sulle seguenti dipendenze:

```yaml
dependencies:
  collection: ^1.19.1
  flutter_blue_plus: ^1.35.5
  permission_handler: ^12.0.1
```

| Pacchetto            | Licenza                                                                            | Uso commerciale |
| -------------------- | ---------------------------------------------------------------------------------- | --------------- |
| `collection`         | BSD‑3‑Clause                                                                       | ✅ Consentito    |
| `flutter_blue_plus`  | BSD‑3‑Clause ([RPMGlobal][1], [Stack Overflow][2], [Gitee][3], [Dart packages][4]) | ✅ Consentito    |
| `permission_handler` | MIT                                                                                | ✅ Consentito    |

Tutte le librerie sono **compatibili con uso commerciale**, purché vengano rispettati i termini di licenza (es. inclusione dell’avviso copyright).

---

## ⚠️ Important Note on `BlueWaveDevice`

La classe `BlueWaveDevice` è **async**. Deve essere creata utilizzando `await` sulla factory `call()`:

```dart
final device = await BlueWaveDevice.call(adapter, deviceId);
```

✅ Questo garantisce che la connessione BLE venga stabilita prima di usare i metodi.

🔴 **Non** creare l'oggetto con `BlueWaveDevice(adapter, id)` diretto, perché non inizializza la connessione.

---

### 💡 Esempio in un `StatefulWidget`

```dart
@override
void initState() {
  super.initState();
  _initialize();
}

Future<void> _initialize() async {
  try {
    _dev = await BlueWaveDevice.call(
      BleAdapterDefault.instance, 
      widget.device.id
    );
    // ora puoi usare _dev.readSystemInfo(), _dev.startMission(), ecc.
  } catch (e) {
    print("Connection failed: $e");
    // gestisci l'errore, per esempio mostrando un messaggio o chiudendo la pagina
  }
}
```

---

## 📚 Documentation

Per dettagli su UUID, pacchetti e architettura Alsos, consulta la documentazione interna Tecnosoft.

---

## 📝 License

MIT License. © Tecnosoft – progetto Alsos BlueWave.
Le dipendenze esterne sono rilasciate sotto licenze BSD‑3‑Clause e MIT, compatibili con uso commerciale.
