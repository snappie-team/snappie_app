# Panduan Menjalankan (Run) & Membangun (Build) Snappie App

Dokumen ini berisi panduan lengkap untuk mempersiapkan environment, menjalankan (debug), dan melakukan build APK/AAB untuk **Snappie App** pada perangkat Android.

---

## 1. Prasyarat Sistem & Tooling

Pastikan perangkat dan sistem operasi Anda telah memenuhi konfigurasi berikut:

- **OS:** Windows 10/11 64-bit
- **Flutter SDK:** Version 3.47.x (Stable Channel) / Dart 3.13.x
- **Java Development Kit (JDK):** **JDK 17 LTS** (Rekomendasi: Eclipse Adoptium Temurin 17).
  - Lokasi default pada sistem ini: `C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot`
- **Android SDK & Build Tools:**
  - Android SDK Platform: **API 36** (`android-36`)
  - Android SDK Build-Tools: **36.1.0**
  - Android NDK: **27.0.12077973** (dibutuhkan untuk kompilasi modul native C++ Isar Database)
- **Editor:** Visual Studio Code atau Android Studio dengan plugin Flutter & Dart aktif.

---

## 2. Setup Awal & Konfigurasi Environment

### A. Environment Variable `PUB_CACHE` (Khusus Windows)
Jika cache Pub Anda mengarah ke drive eksternal yang tidak terpasang (misal `E:\`), arahkan kembali ke lokasi default pengguna:

**Melalui PowerShell (Session Ini):**
```powershell
$env:PUB_CACHE="C:\Users\$env:USERNAME\AppData\Local\Pub\Cache"
```

**Secara Permanen di Windows:**
1. Buka Windows Search > ketik **Edit environment variables for your account**.
2. Cari variabel `PUB_CACHE`.
3. Set nilainya menjadi: `C:\Users\<username>\AppData\Local\Pub\Cache`.

### B. Konfigurasi JDK di Flutter
Pastikan Flutter mendeteksi JDK 17 yang valid:
```bash
flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot"
```
Verifikasi status toolchain dengan:
```bash
flutter doctor -v
```

### C. File Konfigurasi `.env`
Pastikan file `.env` berada di root proyek (sejajar dengan `pubspec.yaml`). Jika belum ada, salin dari `.env.example`:

```bash
cp .env.example .env
```
Pastikan variabel inti terisi sesuai kebutuhan:
```dotenv
ENVIRONMENT=development
LOCAL_BASE_URL=http://localhost:3000
HOST_BASE_URL=https://api.snappie.com
API_VERSION=/api/v1
REGISTRATION_API_KEY=your_key_here

# Cloudinary (Untuk unggah foto misi, ulasan, & avatar)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

### D. File Firebase `google-services.json`
Pastikan file `google-services.json` yang diperoleh dari Firebase Console telah diletakkan di:
```text
android/app/google-services.json
```

---

## 3. Instalasi Dependensi & Kode Generator

Sebelum menjalankan atau mem-build aplikasi pertama kali (atau setelah pull pembaruan repo), jalankan perintah berikut:

### 1. Ambil Dependensi Paket
```bash
flutter pub get
```

### 2. Jalankan Code Generator (Isar Database & JSON Serialization)
Jika terdapat perubahan pada model `@collection` atau `@JsonSerializable`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Generate Kunci Lokalisasi (Easy Localization)
Jika terdapat penambahan teks baru di `assets/translations/{id,en}.json`:
```bash
dart run easy_localization:generate -S assets/translations -O lib/app/core/localization -o locale_keys.g.dart -f keys
```

---

## 4. Menjalankan Aplikasi (Run / Debug)

### A. Periksa Perangkat Terhubung
Hubungkan HP Android (pastikan USB Debugging aktif) atau buka Android Emulator, lalu periksa:
```bash
flutter devices
```
*Contoh output:*
```text
Found 1 connected device:
  24095PCADG (mobile) • AMOJBIW4EA7XUCZL • android-arm64 • Android 16 (API 36)
```

### B. Menjalankan Aplikasi
Cukup jalankan perintah standar:
```bash
# Menjalankan di perangkat default / terhubung
flutter run

# Atau secara eksplisit dengan mode debug:
flutter run --debug

# Menjalankan pada perangkat spesifik:
flutter run -d <DEVICE_ID>
```

### C. Tombol Interaktif saat Run
- `r` : Hot Reload (memperbarui perubahan UI tanpa restart state)
- `R` : Hot Restart (restart aplikasi dari awal)
- `h` : Tampilkan bantuan tombol
- `q` : Hentikan sesi run

---

## 5. Membangun APK (Build APK)

### A. Build Release APK (Direkomendasikan untuk Uji Coba Pengguna / Sideloading)
APK ini sudah dioptimasi dan dikompresi (ukuran ~86 MB):
```bash
flutter build apk --release
```
**Lokasi output:**
```text
build\app\outputs\flutter-apk\app-release.apk
```

### B. Build Debug APK
APK ini menyertakan simbol debug dan tools inspeksi (ukuran ~186 MB):
```bash
flutter build apk --debug
```
**Lokasi output:**
```text
build\app\outputs\flutter-apk\app-debug.apk
```

### C. Build App Bundle (AAB untuk Google Play Store)
Jika ingin merilis aplikasi ke Google Play Console:
```bash
flutter build appbundle --release
```
**Lokasi output:**
```text
build\app\outputs\bundle\release\app-release.aab
```

### D. Pasang APK Langsung ke HP via CLI
Jika HP terhubung dengan kabel USB:
```bash
# Pasang Release APK
flutter install -d <DEVICE_ID>
```
Atau menggunakan ADB langsung:
```bash
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

---

## 6. Catatan Khusus & Solusi Masalah (Troubleshooting)

Proyek ini telah dikonfigurasi untuk menangani beberapa masalah umum pada ekosistem Flutter modern di Windows:

| Potensi Masalah | Penjelasan | Solusi yang Sudah Diterapkan di Proyek |
|---|---|---|
| **AGP Version Check Error pada `flutter run`** | Flutter 3.47 memblokir build jika versi Android Gradle Plugin < 8.11.1. | Sudah dipasang `skipDependencyChecks=true` di `android/gradle.properties`. Perintah `flutter run` dapat berjalan langsung tanpa flag tambahan. |
| **`this and base files have different roots`** | Error Kotlin compiler saat project berada di drive `D:` sedangkan pub cache berada di drive `C:`. | Sudah dipasang `kotlin.incremental=false` dan `kotlin.incremental.useClasspathSnapshot=false` di `android/gradle.properties`. |
| **`android:attr/lStar not found` (AAPT linking)** | Package `isar_flutter_libs` lama mengunci `compileSdkVersion 30`. | Sudah dipasang hook `afterEvaluate` di `android/build.gradle.kts` agar subproject dengan SDK < 31 otomatis dinaikkan ke SDK 36. |
| **Plugin butuh compileSdk 36** | Plugin seperti `app_links`, `camera`, `geolocator` menargetkan SDK 36. | `compileSdk = 36` sudah diatur di `android/app/build.gradle.kts`. |
| **Konflik dependensi `intl`** | `easy_localization` + Flutter 3.47 membutuhkan `intl ^0.20.x`. | `pubspec.yaml` sudah menggunakan `intl: ^0.20.2`. |
