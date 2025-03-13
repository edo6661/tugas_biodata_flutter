# Sistem Kamera dengan Filter di Aplikasi Flutter Kita

## Apa Sih yang Ada di Projek Ini?

Aplikasi kita ini punya dua fitur utama yang keren:

1. **Biodata** - Tempat kamu bisa simpan dan lihat biodata di Firebase
2. **Kamera Canggih** - Kamera yang bisa langsung pakai filter sebelum jepret foto

Struktur folder projeknya begini:

```
📁lib
 ├── 📁entity
 │   └── biodata.dart
 ├── 📁features
 │   ├── 📁auth
 │   │   └── 📁pages
 │   │       ├── login_page.dart
 │   │       └── register_page.dart
 │   ├── 📁biodata
 │   │   ├── 📁pages
 │   │   │   └── upsert_biodata_page.dart
 │   │   └── 📁widgets
 │   │       └── avatar.dart
 │   ├── 📁camera
 │   │   ├── 📁pages
 │   │   │   ├── camera_result_screen.dart
 │   │   │   └── camera_screen.dart
 │   │   └── 📁widgets
 │   │       ├── caraousel_flow_delegate.dart
 │   │       ├── filter_caraousel.dart
 │   │       ├── filter_item.dart
 │   │       └── filter_selector.dart
 │   └── 📁home
 │       └── 📁pages
 │           └── home_page.dart
 ├── 📁ui
 │   └── 📁utils
 │       └── snackbar.dart
 ├── 📁utils
 │   └── log_service.dart
 ├── firebase_options.dart
 └── main.dart
```

## Cara Pakainya Gimana?

1. Masuk ke layar kamera
2. Geser-geser buat pilih filter yang kamu suka
3. Filter langsung nempel di preview kamera
4. Pencet tombol buat jepret foto
5. Lihat hasilnya di layar hasil
6. Bisa ganti filter lagi atau simpan ke galeri
7. Kalau disimpan, filternya bakal nempel permanen

## Fitur Teknis yang Seru

- Pakai ColorFiltered buat nerapin filter warna langsung ke tampilan kamera
- Animasi carousel yang halus pakai widget Flow dengan CarouselFlowDelegate
- Resource kamera diatur supaya aplikasi nggak crash atau boros baterai
- Proses simpan foto memastikan filter udah nempel permanen sebelum disimpan
- Foto yang udah diambil bisa langsung disimpan di galeri HP

## Gabungan Praktikum 1 dan 2

Setelah jepret foto, carousel filternya masih bisa dipakai buat ganti-ganti filter sebelum kamu simpan fotonya.

## Kenapa Sih Ada void async?

Di Dart/Flutter, void async itu kayak memberitahu program "tunggu sebentar ya, ini ada proses yang butuh waktu". Fungsi ini bikin aplikasi tetap lancar meskipun ada proses yang butuh waktu lama, kayak nyalain kamera.

void artinya fungsi ini nggak ngasih balik nilai apa-apa, sedangkan async memungkinkan kita pakai await di dalamnya. Contohnya gini:

```dart
Future<void> _initializeCamera() async {
  final cameras = await availableCameras(); // Nunggu daftar kamera siap
  _controller = CameraController(cameras.first, ResolutionPreset.high);
  await _controller.initialize(); // Nunggu kamera nyala
}
```

## Apa Itu @immutable dan @override?

### @immutable

Ini kayak label yang bilang "hati-hati, objek ini nggak boleh diubah-ubah setelah dibuat". Semua properti di dalamnya sebaiknya final. Biasanya dipake di widget biar performa lebih oke dan lebih gampang dikelola.

### @override

Ini kita pakai kalau mau timpa metode dari kelas induk. Jadinya kita bisa yakin metode yang kita bikin bener-bener gantiin metode dari superclass-nya, dan nggak salah tulis namanya.
