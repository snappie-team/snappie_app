# Firebase Analytics — Setup & Documentation

Dokumen ini menjelaskan implementasi Firebase Analytics di aplikasi Snappie untuk keperluan riset akademis.

---

## Tujuan

Melacak perilaku pengguna dengan 3 jenis data:

1. **Metrik Otomatis** — Durasi sesi, engagement rate, retensi
2. **Observasi Layar** — Layar mana yang dikunjungi dan berapa lama, dikategorikan **Gamification** vs **Non-Gamification**
3. **Custom Events** — 9 aksi pengguna terkait mekanik gamifikasi

---

## Arsitektur

```
main.dart
├── Firebase.initializeApp()
├── CoreDependencies.init()
│   └── AnalyticsService (permanent GetxService)
│       ├── FirebaseAnalytics instance
│       └── FirebaseAnalyticsObserver
└── GetMaterialApp
    └── navigatorObservers: [analyticsService.observer]
```

### File Utama

| File | Peran |
|------|-------|
| `lib/app/core/services/analytics_service.dart` | Wrapper terpusat untuk semua operasi analytics + route-to-screen mapping |
| `lib/app/core/dependencies/core_dependencies.dart` | Registrasi `AnalyticsService` sebagai service permanen |
| `lib/main.dart` | Pasang `FirebaseAnalyticsObserver` ke navigator |
| `android/app/src/main/AndroidManifest.xml` | Menonaktifkan automatic screen reporting Android |
| `lib/app/modules/shared/layout/controllers/main_controller.dart` | Log `screen_view` saat user pindah tab |

### Cara Akses dari Controller / View

```dart
import 'package:snappie_app/app/core/services/analytics_service.dart';

// Dari mana saja via GetX
final analytics = Get.find<AnalyticsService>();
analytics.logScreenView(screenName: 'catalog_home');
analytics.logMissionStarted(placeId: '123', placeName: 'Warung ABC');
```

---

## 1. Event Otomatis

Dengan menambahkan `FirebaseAnalyticsObserver` ke `navigatorObservers`, event berikut otomatis terlacak **tanpa kode tambahan**:

| Event | Deskripsi |
|-------|-----------|
| `app_open` | Aplikasi dibuka |
| `session_start` | Sesi baru dimulai |
| `user_engagement` | Waktu aktif pengguna (parameter: `engagement_time_msec`) |
| `screen_view` | Navigasi antar halaman (parameter: `screen_name`) |

---

## 2. Screen Name Tagging

Screen tracking dilakukan melalui **3 mekanisme yang saling melengkapi**:

1. **AndroidManifest.xml** — `google_analytics_automatic_screen_reporting_enabled = false` untuk mematikan pelacakan otomatis Activity class (yang menampilkan `MainActivity`/`SignInHubActivity`)
2. **`FirebaseAnalyticsObserver` + `nameExtractor`** — Observer di navigator menggunakan mapping `_routeToScreenName` untuk menerjemahkan setiap rute GetX ke nama layar riset (misal `/place-detail` → `place_detail`)
3. **`MainController.changeTab()`** — Karena 4 tab utama (Home, Explore, Articles, Profile) berbagi rute `/main` yang sama, observer hanya melihat satu rute. Maka `changeTab()` memanggil `logScreenView()` secara eksplisit setiap kali user berpindah tab
4. **Manual `logScreenView()`** — Sebagai *fallback* di `initState()` / `addPostFrameCallback` untuk layar-layar yang bisa diakses langsung (gamification screens)

### Layar Gamification

| `screen_name` | View | File |
|----------------|------|------|
| `quest_detail` | MissionPhotoView | `lib/app/modules/mission/views/mission_photo_view.dart` |
| `challenge_page` | UserChallengesView | `lib/app/modules/profile/views/user_challenge_view.dart` |
| `leaderboard` | LeaderboardFullView | `lib/app/modules/profile/views/leaderboard_full_view.dart` |
| `badge_achievement` | UserAchievementView | `lib/app/modules/profile/views/user_achievement_view.dart` |
| `coupon_page` | CoinsHistoryView | `lib/app/modules/profile/views/coins_history_view.dart` |
| `user_profile` | ProfileView | `lib/app/modules/profile/views/profile_view.dart` |

### Layar Non-Gamification

| `screen_name` | View | File |
|----------------|------|------|
| `catalog_home` | ExploreView | `lib/app/modules/explore/views/explore_view.dart` |
| `place_detail` | PlaceDetailView | `lib/app/modules/explore/views/place_detail_view.dart` |
| `forum` | HomeView | `lib/app/modules/home/views/home_view.dart` |
| `article_page` | ArticlesView | `lib/app/modules/articles/views/articles_view.dart` |

### Contoh Implementasi

```dart
// 1. Di MainController — setiap kali user pindah tab
void changeTab(int index) {
  _currentIndex.value = index;
  final screenName = _tabScreenNames[index]; // 'forum', 'catalog_home', dll
  Get.find<AnalyticsService>().logScreenView(screenName: screenName);
}

// 2. Di StatefulWidget — untuk layar yang di-push langsung
@override
void initState() {
  super.initState();
  Get.find<AnalyticsService>().logScreenView(screenName: 'leaderboard');
}

// 3. Observer nameExtractor — otomatis saat route berubah
// Mapping di AnalyticsService:
// '/place-detail' → 'place_detail'
// '/mission-photo' → 'quest_detail'
// '/leaderboard' → 'leaderboard'
```

---

## 3. Custom Events

Semua event secara otomatis menyertakan parameter `timestamp` (ISO 8601). Parameter `user_id` diset secara global via `setUserId()` saat login.

### 3.1 `mission_started`

Dipanggil saat pengguna memulai misi baru.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `place_id` | String | `"42"` |
| `place_name` | String | `"Warung Sate Pak Budi"` |
| `timestamp` | String | `"2026-03-11T04:30:00.000"` |

**Trigger:** `MissionController.initMission()`

### 3.2 `mission_completed`

Dipanggil saat pengguna menyelesaikan suatu langkah misi (foto / ulasan).

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `place_id` | String | `"42"` |
| `place_name` | String | `"Warung Sate Pak Budi"` |
| `step` | String | `"photo"` atau `"review"` |
| `timestamp` | String | `"2026-03-11T04:35:00.000"` |

**Trigger:** `MissionController.submitPhoto()` dan `MissionController.submitReview()`

### 3.3 `challenge_completed`

Dipanggil saat tantangan selesai secara otomatis (via respons API gamifikasi).

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `challenge_id` | String | `"5"` |
| `challenge_name` | String | `"Kunjungi 3 Tempat"` |
| `timestamp` | String | `"2026-03-11T04:36:00.000"` |

**Trigger:** `GamificationHandlerService._handleChallengeUpdates()`

### 3.4 `achievement_unlocked`

Dipanggil saat pencapaian baru terbuka dan popup ditampilkan.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `achievement_id` | String | `"12"` |
| `achievement_name` | String | `"Penjelajah Pemula"` |
| `timestamp` | String | `"2026-03-11T04:37:00.000"` |

**Trigger:** `GamificationHandlerService._showAchievementPopups()`

### 3.5 `reward_received`

Dipanggil saat pengguna menerima hadiah koin atau XP.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `reward_type` | String | `"coins"` atau `"xp"` |
| `amount` | int | `50` |
| `timestamp` | String | `"2026-03-11T04:38:00.000"` |

**Trigger:** `GamificationHandlerService._updateUserStats()`

### 3.6 `coupon_redeemed`

Dipanggil saat pengguna mengklaim hadiah dari tantangan yang sudah selesai.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `reward_id` | String | `"7"` |
| `reward_name` | String | `"Foto 5 Tempat"` |
| `coin_cost` | int | `100` |
| `timestamp` | String | `"2026-03-11T04:39:00.000"` |

**Trigger:** `UserChallengesView._claimChallenge()`

### 3.7 `leaderboard_viewed`

Dipanggil saat pengguna berpindah tab di leaderboard.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `period` | String | `"weekly"` atau `"monthly"` |
| `timestamp` | String | `"2026-03-11T04:40:00.000"` |

**Trigger:** `LeaderboardFullView._onTabChanged()`

### 3.8 `forum_post_created`

Dipanggil saat pengguna berhasil membuat postingan di forum.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `post_id` | String | `""` (belum dikembalikan oleh API) |
| `place_id` | String | `"42"` |
| `timestamp` | String | `"2026-03-11T04:41:00.000"` |

**Trigger:** `CreatePostView._submitPost()`

### 3.9 `place_favorited`

Dipanggil saat pengguna menyimpan atau menghapus tempat dari favorit.

| Parameter | Tipe | Contoh |
|-----------|------|--------|
| `place_id` | String | `"42"` |
| `place_name` | String | `"Warung Sate Pak Budi"` |
| `is_saved` | String | `"true"` atau `"false"` |
| `timestamp` | String | `"2026-03-11T04:42:00.000"` |

**Trigger:** `PlaceDetailView._toggleFavorite()`

---

## 4. User Identity

| Aksi | Lokasi | Method |
|------|--------|--------|
| Set `user_id` saat login/register | `AuthService._saveAuthSession()` | `analytics.setUserId(userId)` |
| Hapus `user_id` saat logout | `AuthService.logout()` | `analytics.clearUserId()` |

Firebase secara otomatis menyertakan `user_id` di semua event setelah `setUserId()` dipanggil, sehingga tidak perlu menambahkannya secara manual di setiap event.

---

## 5. Verifikasi dengan Firebase DebugView

### Langkah 1 — Aktifkan Debug Mode

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.justtffy.snappie_app
```

**iOS:**
Di Xcode, tambahkan `-FIRAnalyticsDebugEnabled` di scheme launch arguments.

### Langkah 2 — Buka DebugView

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Snappie
3. Navigasi ke **Analytics → DebugView**
4. Jalankan aplikasi di device/emulator
5. Event akan muncul secara real-time

### Langkah 3 — Checklist Verifikasi

| Aksi di Aplikasi | Event yang Diharapkan |
|---|---|
| Buka aplikasi | `session_start`, `app_open` |
| Buka tab Beranda | `screen_view` → `forum` |
| Buka tab Jelajahi | `screen_view` → `catalog_home` |
| Tap suatu tempat | `screen_view` → `place_detail` |
| Simpan tempat ke favorit | `place_favorited` |
| Mulai misi | `mission_started` |
| Submit foto | `mission_completed` (step: `photo`) |
| Submit ulasan | `mission_completed` (step: `review`) |
| Achievement terbuka | `achievement_unlocked` |
| Challenge selesai | `challenge_completed` |
| Klaim hadiah challenge | `coupon_redeemed` |
| Dapat koin/XP | `reward_received` |
| Buat postingan | `forum_post_created` |
| Buka leaderboard & ganti tab | `leaderboard_viewed` |

### Langkah 4 — Matikan Debug Mode

```bash
adb shell setprop debug.firebase.analytics.app .none.
```

> **Catatan:** Event membutuhkan waktu hingga **24 jam** untuk muncul di dashboard Analytics standar. Gunakan DebugView untuk verifikasi real-time saat development.

---

## 6. Catatan Teknis

- **Dependency:** `firebase_analytics: ^12.0.3` (kompatibel dengan `firebase_core: ^4.1.0`)
- **`google-services.json`** sudah terkonfigurasi dan **tidak dimodifikasi**
- **Android automatic screen reporting dinonaktifkan** via `AndroidManifest.xml` — tanpa ini, Firebase akan mengirim `screen_view` dengan nama Activity (`MainActivity`) yang menimpa nama custom kita
- **Tab-level tracking** ditangani oleh `MainController.changeTab()` karena 4 tab utama berbagi satu rute `/main`
- **Route-level tracking** ditangani oleh `FirebaseAnalyticsObserver` + `nameExtractor` yang mapping rute ke nama layar riset
- Semua event parameter menggunakan tipe `String` atau `int` (sesuai batasan Firebase Analytics)
- `AnalyticsService` di-register sebagai `permanent: true` melalui `CoreDependencies.init()` agar tersedia di seluruh lifecycle aplikasi
- Logging debug (`Logger.debug`) ditambahkan di setiap method untuk memudahkan debugging
