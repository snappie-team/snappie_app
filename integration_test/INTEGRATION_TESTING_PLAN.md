# Rancangan Integration Testing - Snappie App

Dokumen ini menjelaskan strategi dan rancangan *integration testing* untuk aplikasi Snappie, berdasarkan analisis Use Cases (`docs/USE_CASES.md`). Rancangan ini diimplementasikan menggunakan paket `integration_test` bawaan Flutter dengan pendekatan **Robot Pattern**.

## 1. Tujuan dan Ruang Lingkup

Tujuan utama adalah memastikan seluruh alur bisnis utama (*critical flows*) berjalan dengan benar dari sisi pengguna (End-to-End), meliputi interaksi UI, navigasi, dan integrasi antar modul.

### Ruang Lingkup Modul:
1.  **Autentikasi**: Login Google, Registrasi User Baru (Onboarding).
2.  **Eksplorasi**: Pencarian tempat, Filter, Detail Tempat.
3.  **Gamifikasi**: Check-in (Mock Camera/Location), Misi, Rewards.
4.  **Sosial**: Review, Posting, Interaksi (Like/Save).
5.  **Profil**: Leaderboard, History Koin, Achievements.

---

## 2. Arsitektur Testing (Robot Pattern)

Untuk menjaga kode testing tetap bersih, mudah dibaca, dan *reusable*, kami menerapkan **Robot Pattern**.

### Struktur Direktori
```
test/integration_test/
├── robots/              # Encapsulasi interaksi UI & Assertions
│   ├── auth_robot.dart
│   ├── explore_robot.dart
│   ├── mission_robot.dart
│   └── ...
├── tests/               # File eksekusi test per Use Case
│   ├── auth_test.dart
│   ├── explore_test.dart
│   └── ...
├── helpers/             # Utilities (Keys, Mock Setup)
└── data/                # Test Data (Dummy Users, Places)
```

### Konsep Robot
Setiap "Robot" merepresentasikan satu layar atau fitur utama. Robot memiliki metode untuk:
1.  **Actions**: Melakukan aksi user (tap, scroll, enter text).
2.  **Verifications**: Memverifikasi kondisi UI (expect widget exists, text matches).

Contoh:
```dart
// Di dalam test file
await authRobot.tapLoginWithGoogle(); // Action
authRobot.verifyMainPageDisplayed();  // Verification
```

---

## 3. Skenario Pengujian Berdasarkan Use Case

Berikut adalah pemetaan Use Case ke dalam skenario pengujian spesifik.

### UC1: Autentikasi Pengguna
*File: `tests/auth_test.dart`*
*   **Skenario 1 (Onboarding)**:
    *   Buka aplikasi pertama kali.
    *   Swipe halaman onboarding 1-3.
    *   Verifikasi tombol "Skip" dan "Next".
    *   Navigasi ke halaman Login.
*   **Skenario 2 (Registrasi User Baru)**:
    *   Simulasi login Google (User tidak ditemukan).
    *   Redirect ke halaman Register.
    *   Isi form profil (Nama, Username, Gender).
    *   Pilih *Food Types* & *Place Values*.
    *   Submit dan verifikasi masuk ke Home.

### UC2: Menelusuri Tempat (Explore)
*File: `tests/explore_test.dart`*
*   **Skenario 1 (Search & Filter)**:
    *   Buka tab Jelajahi.
    *   Ketik keyword pencarian.
    *   Terapkan filter (Kategori: "Coffee", Harga: "$$").
    *   Verifikasi hasil list berkurang sesuai filter.
*   **Skenario 2 (Detail Tempat)**:
    *   Tap salah satu kartu tempat.
    *   Verifikasi detail tempat muncul (Nama, Rating, Alamat).
    *   Verifikasi tombol "Mulai Misi" ada.

### UC3: Melakukan Check-in (Gamifikasi)
*File: `tests/gamification_test.dart`*
*   **Skenario 1 (Check-in Flow)**:
    *   Buka detail tempat.
    *   Tap "Mulai Misi".
    *   Simulasi ambil foto (Mock Camera).
    *   Simulasi lokasi valid (Mock Location).
    *   Submit foto.
    *   Verifikasi Modal Sukses muncul (Reward XP & Koin).

### UC4 & UC5: Sosial & Interaksi
*File: `tests/home_test.dart`*
*   **Skenario 1 (Create Post)**:
    *   Tap tombol "+" (Create Post).
    *   Pilih tempat, isi caption, upload foto.
    *   Submit.
    *   Verifikasi post muncul di Feed.
*   **Skenario 2 (Interaksi)**:
    *   Tap tombol Like pada post.
    *   Verifikasi icon hati berubah merah (Optimistic UI).
    *   Tap tombol Save/Bookmark.
    *   Verifikasi post tersimpan.

### UC7 & UC8: Profil & Leaderboard
*File: `tests/profile_test.dart`*
*   **Skenario 1 (View Profile)**:
    *   Buka tab Akun.
    *   Verifikasi data Level, XP, dan Koin sesuai.
*   **Skenario 2 (Leaderboard)**:
    *   Buka halaman Leaderboard.
    *   Switch tab Mingguan/Bulanan.
    *   Verifikasi list user muncul.

---

## 4. Strategi Data & Mocking

### Test Data (`data/test_data.dart`)
Menggunakan data statis untuk konsistensi pengujian:
*   **User**: `test_user@snappie.id`
*   **Place**: "Kopi Kenangan Mantan" (ID: `test_place_001`)

### Handling External Services
Karena ini adalah *Integration Test* yang berjalan di device/emulator:
1.  **Backend API**: Idealnya menggunakan *Mock Server* atau *Staging Environment* agar tidak mengotori production database.
2.  **Camera**: Menggunakan `image_picker` yang di-mock atau file gambar statis yang di-inject ke emulator.
3.  **Location**: Menggunakan fitur mock location pada Android Emulator / iOS Simulator, atau mock `Geolocator` service di level kode (`TestHelper`).

---

## 5. Cara Menjalankan Test

Eksekusi dilakukan melalui terminal root project:

```bash
# Menjalankan seluruh suite test
flutter test integration_test/app_test.dart

# Menjalankan test spesifik (contoh: Auth)
flutter test integration_test/tests/auth_test.dart

# Menjalankan pada device spesifik
flutter test integration_test/app_test.dart -d <device_id>
```

---

## 6. Prasyarat Eksekusi
*   Emulator/Device terhubung (Android/iOS).
*   Koneksi internet aktif (untuk scenario yang hit real/staging API).
*   Konfigurasi `.env` test sudah terpasang.
