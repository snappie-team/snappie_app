# Snappie App

A Flutter application built with simplified architecture principles, featuring user authentication, state management with GetX, and local storage with Isar database.

## Architecture Overview

This project follows a **simplified architecture** approach, focusing on maintainability and development speed.

At a high level:

- **Data layer**: datasources + repositories + models (no domain layer)
- **Presentation layer**: feature modules (GetX controllers + views)
- **Core**: shared infrastructure (network, services, DI, errors, helpers)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart         # Firebase options (generated)
├── app/
│   ├── core/                    # Core utilities and configurations
│   │   ├── constants/           # App-wide constants
│   │   ├── dependencies/        # Dependency injection setup
│   │   ├── errors/              # Error handling and exceptions
│   │   ├── helpers/             # API response helpers
│   │   ├── network/             # Network configuration and interceptors
│   │   ├── services/            # Core services (Auth, Isar, etc.)
│   │   └── utils/               # Utility functions and helpers
│   ├── data/                    # Data Layer
│   │   ├── datasources/         # Data sources (local & remote)
│   │   │   ├── local/           # Local data sources (Isar)
│   │   │   └── remote/          # Remote data sources (API)
│   │   ├── models/              # Data models with JSON serialization
│   │   └── repositories/        # Repository implementations
│   ├── modules/                 # Feature modules
│   │   ├── articles/            # Articles feature
│   │   ├── auth/                # Authentication feature
│   │   ├── explore/             # Explore places feature
│   │   ├── home/                # Home feed feature
│   │   ├── mission/              # Missions / challenges
│   │   ├── profile/             # User profile feature
│   │   └── shared/              # Shared components and widgets
│   │       ├── components/      # Reusable UI components
│   │       ├── layout/          # Layout components
│   │       └── widgets/         # Categorized widget system
│   │           ├── _card_widgets/      # Card-based widgets
│   │           ├── _dialog_widgets/    # Dialog and modal widgets
│   │           ├── _display_widgets/   # Display and image widgets
│   │           ├── _form_widgets/      # Form input widgets
│   │           ├── _layout_widgets/    # Layout and container widgets
│   │           ├── _navigation_widgets/ # Navigation and button widgets
│   │           └── _state_widgets/     # Loading, error, empty state widgets
│   ├── routes/                  # App routing configuration
```

## Layer Details

### 🏗️ Core Layer (`lib/app/core/`)
Contains foundational components used across the entire application:

- **`constants/`**: App-wide constants like API endpoints, colors, themes, font sizes
- **`dependencies/`**: Centralized dependency injection setup using GetX
- **`errors/`**: Custom exceptions and error handling
- **`helpers/`**: API response parsing and utility helpers
- **`network/`**: HTTP client configuration, interceptors, and network utilities
- **`services/`**: Core services (AuthService, IsarService, GoogleAuthService)
- **`utils/`**: Helper functions, extensions, and utility classes

### 📊 Data Layer (`lib/app/data/`)
Handles all data operations and external dependencies:

- **`datasources/`**: 
  - `local/`: Local data sources (Isar database operations)
  - `remote/`: Remote data sources (API calls with Dio)
- **`models/`**: Data models with JSON serialization and Isar annotations
- **`repositories/`**: Repository implementations with network and local data handling

### 🎨 Presentation Layer (`lib/app/modules/`)
Handles UI and user interactions with feature-based organization:

- **`articles/`**: Article browsing with external URL support
- **`auth/`**: User authentication and registration
- **`explore/`**: Place discovery and check-in functionality
- **`home/`**: Social feed with posts and interactions
- **`profile/`**: User profile management and settings
- **`shared/`**: Reusable components organized by category:
  - `components/`: High-level reusable components
  - `layout/`: Layout containers and scaffold components
  - `widgets/`: Categorized widget system for consistent UI

### 🛣️ Routes (`lib/app/routes/`)
Centralized routing configuration using GetX navigation with API endpoints.

### 🎨 Shared Widget System (`lib/app/modules/shared/widgets/`)
Organized widget system for consistent UI development:

- **`_card_widgets/`**: Card-based components (PromotionalBanner, etc.)
- **`_dialog_widgets/`**: Modal dialogs and bottom sheets
- **`_display_widgets/`**: Image display and network image widgets
- **`_form_widgets/`**: Input fields and form components
- **`_layout_widgets/`**: Containers and layout helpers
- **`_navigation_widgets/`**: Buttons and navigation components
- **`_state_widgets/`**: Loading, error, and empty state widgets

## Key Technologies

- **State Management**: GetX
- **Local Database**: Isar (NoSQL database)
- **HTTP Client**: Dio with custom interceptors
- **Dependency Injection**: GetX
- **Architecture**: Simplified (no domain layer) with shared Core infrastructure
- **Error Handling**: Custom exception handling with API response helpers
- **External URLs**: url_launcher for opening external links
- **Authentication**: Firebase Auth + Google Sign-In, plus backend token/session handling
- **Media Uploads**: Cloudinary
- **Sharing**: share_plus + QR (qr_flutter)

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd snappie_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure environment variables:

Create a `.env` file at the project root. Required keys are defined in `lib/app/core/constants/environment_config.dart`.

Example:

```dotenv
ENVIRONMENT=development
LOCAL_BASE_URL=http://10.0.2.2:8000
HOST_BASE_URL=https://api.example.com
API_VERSION=v1
REGISTRATION_API_KEY=your_key_here
```

4. Generate Isar database schemas and JSON serialization:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

5. Run the app:
```bash
flutter run
```

## Development Guidelines

### Adding New Features

1. **Implement Data Layer**:
   - Create models in `data/models/` with JSON serialization
   - Implement data sources in `data/datasources/local/` or `remote/`
   - Implement repository in `data/repositories/`

2. **Build Presentation Layer**:
   - Create controller in `modules/feature/controllers/`
   - Design views in `modules/feature/views/`
   - Set up bindings in `modules/feature/bindings/`
   - Use shared widgets from `modules/shared/widgets/`

3. **Update Dependencies**:
   - Register new dependencies in `core/dependencies/data_dependencies.dart`
   - Add routes in `routes/app_pages.dart`
   - Update API endpoints in `routes/api_endpoints.dart`

### Widget Development

Use the organized widget system in `modules/shared/widgets/`:
- **Cards**: Use `_card_widgets/` for card-based components
- **Forms**: Use `_form_widgets/` for input components
- **States**: Use `_state_widgets/` for loading/error/empty states
- **Navigation**: Use `_navigation_widgets/` for buttons and navigation

### Code Generation

When modifying Isar models or JSON serialization, run:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### API Integration

The app uses a structured API response system:
- API responses are wrapped in `ApiResponse<T>` format
- Use `extractApiResponseData<T>()` and `extractApiResponseListData<T>()` helpers
- Error handling is centralized in datasource implementations

## Testing

The simplified architecture makes testing straightforward:
- **Unit Tests**: Test controllers and repository implementations
- **Widget Tests**: Test UI components and shared widgets
- **Integration Tests**: Test complete user flows and API integration

## Features

### Current Features
- **Authentication**: Google Sign-In / Firebase Auth + session handling
- **Social Feed**: Post creation, likes, comments, post detail
- **Create Post**: Dedicated create post screen
- **Notifications**: Notifications screen (UI/navigation)
- **Place Discovery**: Browse places, check-ins, reviews
- **Articles**: Browse articles with external URL support
- **Profile Management**: User profiles and settings
- **Profile Sharing**: Share profile via link/QR modal
- **Promotional Banners**: Dismissible promotional content

### Key Components
- **Article Cards**: Reusable widgets with external URL opening
- **Promotional Banner**: Dismissible banner with close button
- **Shared Widget System**: Organized, categorized widget library
- **API Integration**: Structured response handling and error management

## Contributing

1. Follow the established architecture patterns
2. Maintain separation of concerns
3. Write tests for new features
4. Update documentation when adding new modules

For more information about Flutter development, visit the [official documentation](https://docs.flutter.dev/).

## Application Logic & Data Flow (Deep Dive)

Bagian ini menjelaskan “logika kerja” aplikasi dari sudut pandang alur pengguna dan alur data, tanpa perlu membaca kode satu per satu.

### 1) Model mental aplikasi

Aplikasi ini bisa dipahami sebagai gabungan 3 hal besar:

1. **Identitas & sesi** (login Google/Firebase, lalu sesi backend dengan token).
2. **Eksplorasi & sosial** (tempat, posting, interaksi like/save/follow).
3. **Gamification** (check-in + review menghasilkan XP/koin + achievement/challenge).

Semua itu dibungkus ke dalam 4 tab utama:

- **Beranda**: feed sosial (post, like, save, follow).
- **Jelajahi**: discovery tempat (filter, detail tempat, review, check-in, galeri).
- **Artikel**: browsing artikel (pencarian/filter lokal, buka link eksternal).
- **Akun**: profil user (profil, saved items, leaderboard, pengaturan, logout).

### 2) Alur startup (ketika aplikasi dibuka)

Tujuan startup adalah: menyiapkan fondasi aplikasi, lalu memutuskan user masuk ke login atau langsung ke tab utama.

Urutannya secara logika:

1. **Inisialisasi framework & Firebase** agar Google Sign-In siap.
2. **Load environment** dari `.env` untuk menentukan base URL API dan API key khusus registrasi.
3. **Siapkan dependency & service inti** (HTTP client, auth service, lokasi, upload, dll) agar semua modul bisa memakainya.
4. **Load session** dari penyimpanan lokal.
5. Jika **token ada** → masuk ke **Main (tab)**. Jika tidak → masuk ke **Login**.

Intinya: aplikasi berusaha membuat “cold start” tetap cepat, dan hanya melanjutkan ke fetch data fitur tertentu ketika tab itu benar-benar dibuka.

### 3) Konsep sesi & autentikasi (2 tahap)

Autentikasi di aplikasi ini bersifat “hybrid”, karena ada dua kebutuhan:

1. **Google/Firebase**: memverifikasi user memang akun Google valid.
2. **Backend aplikasi**: memberi akses ke data aplikasi (post, tempat, profile, gamification) dengan **access token**.

Alur login yang paling umum:

1. User menekan “Sign in with Google”.
2. Google Sign-In menghasilkan identitas user (terutama email).
3. Aplikasi mengirim email tersebut ke backend untuk login.
4. Backend mengembalikan **token** (dan biasanya refresh token + masa berlaku).
5. Aplikasi menyimpan sesi ke penyimpanan lokal agar user tidak perlu login ulang saat buka aplikasi lagi.

Jika backend menjawab “user belum terdaftar”, aplikasi mengarahkan user ke flow registrasi untuk mengisi profil awal (misalnya username, gender, avatar, preferensi). Setelah registrasi berhasil, aplikasi akan mencoba login kembali agar sesi terbentuk.

### 4) Siklus request API (yang terjadi di balik layar)

Semua call ke backend lewat satu HTTP client yang konsisten. Yang penting dipahami: aplikasi mencoba membuat request “tahan banting” terhadap token kedaluwarsa.

Siklus umum sebuah request:

1. Controller meminta data/aksi (misalnya ambil post atau toggle like).
2. Repository mengecek koneksi internet (untuk beberapa fitur) dan meneruskan ke remote datasource.
3. HTTP client menambahkan header auth.
   - Jika user sudah login, pakai access token.
   - Jika belum login / khusus endpoint tertentu, pakai registration API key.
4. Jika backend membalas sukses, data diparse dan dikembalikan.
5. Jika backend membalas **401 (token expired)**:
   - Aplikasi mencoba **refresh token** (kalau refresh token masih valid).
   - Jika refresh sukses, request semula **diulang** otomatis.
   - Jika refresh gagal, aplikasi melakukan **logout** dan mengarahkan user kembali ke login.

Dengan pola ini, sebagian besar “token expired” terasa transparan bagi user.

### 5) Alur data: UI → Controller → Repository → API

Arsitektur datanya sengaja dibuat sederhana untuk kecepatan pengembangan.

Secara konsep, alurnya seperti ini:

```text
[UI/View]
   |  (user tap, scroll, submit form)
   v
[Controller]
   |  (state: loading/error/data, validasi, debounce, optimistic update)
   v
[Repository]
   |  (cek network, pilih sumber data, normalisasi error)
   v
[DataSource Remote]
   |  (call HTTP ke endpoint)
   v
[Backend API]
```

Lalu responsnya kembali ke atas (API → datasource → repository → controller → UI) untuk menampilkan data atau status.

Catatan penting: aplikasi ini cenderung memakai **exception** untuk error (network/server/validation/auth) dan controller memilih reaksi UI (snackbar, empty state, dll).

### 6) Penyimpanan lokal & cache

Ada dua jenis penyimpanan yang dipakai untuk kebutuhan berbeda:

1. **SharedPreferences**: cocok untuk data kecil dan sangat sering dibaca saat startup, seperti token, refresh token, expiry, dan payload user.
2. **Isar (database lokal)**: cocok untuk cache model (misalnya profil user) agar:
   - bisa tampil ketika offline,
   - tidak perlu fetch berulang,
   - data lebih terstruktur.

Strategi sederhananya: untuk beberapa data yang krusial seperti profil user, saat online aplikasi akan fetch dari API lalu cache. Saat offline, aplikasi mencoba mengambil cache; jika cache tidak ada, baru dianggap gagal.

### 7) Logika per fitur (empat tab utama)

#### 7.1 Beranda (social feed)

Tujuan Beranda adalah menampilkan feed post dan membuat interaksi terasa cepat.

Yang biasa terjadi saat tab Beranda pertama kali dibuka:

1. Aplikasi memuat daftar post dari API.
2. Aplikasi memuat data pendukung seperti relasi follow dan daftar post yang disimpan.
3. UI menampilkan post dengan state interaksi (misalnya sudah di-like atau belum, sudah di-save atau belum).

Untuk aksi seperti like/save/follow, aplikasi memakai pendekatan “optimistic update”: UI langsung berubah dulu, lalu request dikirim ke backend. Jika backend gagal, UI dibatalkan agar konsisten.

#### 7.2 Jelajahi (places discovery)

Tujuan Jelajahi adalah membantu user menemukan tempat dan masuk ke aksi bernilai tinggi (review/check-in).

Logika yang menonjol:

- Data tempat biasanya diambil dari API lalu difilter di sisi client untuk pencarian cepat.
- Filter bisa berupa rating, popular/partner, nearby (butuh lokasi), dan preferensi kategori tertentu.
- Dari detail tempat, user bisa masuk ke review, check-in, dan galeri konten terkait.

Karena Jelajahi punya aksi yang berkaitan dengan user (saved, review, check-in), fitur ini umumnya mengharuskan user sudah login.

#### 7.3 Artikel

Tujuan tab Artikel adalah browsing konten informatif.

Polanya:

- Aplikasi memuat daftar artikel dari API.
- Search dan filter cenderung dilakukan lokal agar responsif.
- Saat user membuka artikel, aplikasi biasanya membuka link eksternal.

#### 7.4 Akun/Profil

Tujuan tab Akun adalah menampilkan identitas, progres, dan kontrol user.

Yang dimuat umumnya mencakup:

- Profil user terbaru.
- Post milik user.
- Saved places dan saved posts.
- Leaderboard (mingguan/bulanan).

Profil juga menjadi “titik sinkronisasi” setelah aktivitas gamification, karena XP/koin dan badge challenge/achievement biasanya perlu ikut ter-update.

### 8) Mission (check-in + review + feedback) dan gamification

Mission adalah alur yang paling “bernilai” karena menggabungkan beberapa komponen penting aplikasi.

Contoh alur mission yang umum:

1. User memilih suatu tempat dan mulai mission.
2. Step foto/check-in:
   - Aplikasi mengambil lokasi user.
   - Foto diunggah dulu ke storage (Cloudinary) agar backend cukup menerima URL.
   - Aplikasi mengirim request check-in dengan koordinat + URL foto.
3. Step review:
   - User memberi rating dan menulis ulasan.
   - Backend menyimpan review dan menghitung reward.
4. Step feedback:
   - User menjawab beberapa pertanyaan feedback.

Setelah check-in atau review sukses, backend dapat mengembalikan “paket gamification”, misalnya:

- Reward XP/koin.
- Achievement yang baru terbuka (perlu ditampilkan sebagai popup).
- Challenge yang progresnya berubah (badge/indikator).

Handler gamification dibuat terpusat agar perilakunya konsisten: reward di-update, popup achievement tampil berurutan (tidak menumpuk), lalu challenge di-refresh tanpa mengganggu flow utama.

### 9) Contoh perjalanan user end-to-end

Berikut contoh perjalanan user yang menggambarkan “benang merah” aplikasi:

**User baru** → login Google → backend bilang belum terdaftar → isi registrasi → login ulang → masuk tab → jelajahi tempat → check-in + review → dapat XP/koin + achievement → profil/leaderboard ikut berubah.

**User lama** → buka aplikasi → sesi masih ada → langsung masuk tab → scroll feed → like/save/follow (optimistic) → buka profil untuk melihat progres.

### 10) Panduan memahami dan mengubah flow

Kalau Anda ingin mengubah perilaku aplikasi, biasanya Anda akan memilih “titik kontrol” ini:

- Perubahan aturan login/sesi: ada di layanan autentikasi dan mekanisme refresh.
- Perubahan cara request & error: ada di HTTP client (interceptor) dan datasource.
- Perubahan data yang ditampilkan: ada di controller (cara load, debounce, optimistic update) dan repository.
- Perubahan gamification: ada di handler gamification dan alur mission.

Dengan memahami hubungan antar titik kontrol itu, Anda bisa menambah fitur baru tanpa harus mengubah banyak bagian aplikasi.
