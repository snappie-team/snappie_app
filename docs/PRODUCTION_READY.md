# 🚀 Snappie App - Production Ready Checklist

> **Status**: 🚧 In Progress  
> **Last Updated**: 2025-12-31  
> **Priority**: 🔴 Critical | 🟡 High | 🟢 Medium | ⚪ Low

Dokumen ini berisi checklist dan panduan untuk menjadikan Snappie App **production-ready**.

---

## 🔴 CRITICAL - Harus Diperbaiki Sebelum Release

### 1. Security Issues

#### 1.1 Google Services Configuration
- [ ] **Hapus `google-services.json` dari git history**
  ```bash
  # Tambahkan ke .gitignore
  android/app/google-services.json
  
  # Hapus dari git (keep local file)
  git rm --cached android/app/google-services.json
  ```
  
- [ ] **Simpan secara aman** menggunakan:
  - GitHub Secrets untuk CI/CD
  - Secure file storage untuk tim

#### 1.2 Release Signing Configuration
**Lokasi**: `android/app/build.gradle.kts`

```kotlin
// ❌ SAAT INI (TIDAK AMAN!)
buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("debug") // BERBAHAYA!
    }
}

// ✅ SEHARUSNYA
signingConfigs {
    create("release") {
        storeFile = file(System.getenv("KEYSTORE_PATH") ?: "release.keystore")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = System.getenv("KEY_ALIAS")
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    getByName("release") {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Steps untuk membuat release keystore:**
```bash
keytool -genkey -v -keystore snappie-release.keystore -alias snappie -keyalg RSA -keysize 2048 -validity 10000
```

#### 1.3 Environment Variables
- [ ] Buat `.env.example` dengan template (tanpa nilai sensitif)
- [ ] Pastikan `.env` ada di `.gitignore` ✅ (sudah ada)
- [ ] Dokumentasikan semua required environment variables

**Template `.env.example`:**
```env
# Environment Type: development | production
ENVIRONMENT=development

# API Configuration
LOCAL_BASE_URL=http://localhost:3000
HOST_BASE_URL=https://api.snappie.com
API_VERSION=/api/v1

# API Keys (get from admin)
REGISTRATION_API_KEY=your_registration_api_key_here

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

---

### 2. Logging System

#### 2.1 Masalah Saat Ini
- `print()` statements tersebar di 20+ files
- Sensitive data bisa terekspos di logs
- Tidak ada level logging (debug/info/warning/error)

#### 2.2 Solusi: Buat Logger Service

**Lokasi**: `lib/app/core/services/logger_service.dart`

```dart
import 'package:flutter/foundation.dart';
import '../constants/environment_config.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _tag = 'Snappie';
  
  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }
  
  static void info(String message, [String? tag]) {
    _log(LogLevel.info, message, tag);
  }
  
  static void warning(String message, [String? tag]) {
    _log(LogLevel.warning, message, tag);
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    _log(LogLevel.error, message, tag);
    
    if (error != null) {
      _log(LogLevel.error, 'Error: $error', tag);
    }
    
    // Di production, kirim ke crash reporting
    if (EnvironmentConfig.isProduction && error != null) {
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }
  
  static void _log(LogLevel level, String message, [String? tag]) {
    // Skip debug logs di production
    if (EnvironmentConfig.isProduction && level == LogLevel.debug) {
      return;
    }
    
    final prefix = _getPrefix(level);
    final tagStr = tag != null ? '[$tag]' : '[$_tag]';
    
    if (kDebugMode) {
      debugPrint('$prefix $tagStr $message');
    }
  }
  
  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return '🐛';
      case LogLevel.info: return 'ℹ️';
      case LogLevel.warning: return '⚠️';
      case LogLevel.error: return '❌';
    }
  }
}
```

#### 2.3 Migration Guide
```dart
// ❌ BEFORE
print('❌ Error loading challenges: $e');
print('debug gender = $gender'); // SENSITIVE!

// ✅ AFTER
Logger.error('Failed to load challenges', e, stackTrace);
Logger.debug('Gender selected: ${gender.hashCode}'); // Hash sensitive data
```

**Files yang perlu di-update:**
- [ ] `main.dart`
- [ ] `home_controller.dart`
- [ ] `profile_controller.dart`
- [ ] `explore_controller.dart`
- [ ] Semua views di `modules/profile/views/`
- [ ] `dio_client.dart`
- [ ] `auth_service.dart`

---

## 🟡 HIGH PRIORITY - Penting untuk Stability

### 3. Crash Reporting

#### 3.1 Setup Firebase Crashlytics

**Step 1: Tambah dependency**
```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^4.0.0
```

**Step 2: Initialize di main.dart**
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(...);
  
  // Setup Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(...);
}
```

**Step 3: Manual error reporting**
```dart
try {
  // risky operation
} catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
}
```

---

### 4. Testing Coverage

#### 4.1 Current State
| Metric | Current | Target |
|--------|---------|--------|
| Test files | 5 | 50+ |
| Coverage | ~5% | 70%+ |
| Types | Integration only | Unit + Widget + Integration |

#### 4.2 Test Structure yang Dibutuhkan
```
test/
├── unit/
│   ├── repositories/
│   │   ├── user_repository_test.dart
│   │   ├── place_repository_test.dart
│   │   ├── post_repository_test.dart
│   │   └── ...
│   ├── controllers/
│   │   ├── home_controller_test.dart
│   │   ├── explore_controller_test.dart
│   │   ├── profile_controller_test.dart
│   │   └── ...
│   └── services/
│       ├── auth_service_test.dart
│       ├── location_service_test.dart
│       └── ...
├── widget/
│   ├── widgets/
│   │   ├── post_card_test.dart
│   │   ├── place_card_test.dart
│   │   └── ...
│   └── views/
│       ├── home_view_test.dart
│       ├── profile_view_test.dart
│       └── ...
├── integration/
│   └── flows/
│       ├── auth_flow_test.dart
│       ├── checkin_flow_test.dart
│       └── ...
└── mocks/
    ├── mock_repositories.dart
    ├── mock_services.dart
    └── mock_data.dart
```

#### 4.3 Sample Unit Test Template
```dart
// test/unit/repositories/user_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([UserRemoteDataSource, NetworkInfo])
void main() {
  late UserRepository repository;
  late MockUserRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockUserRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepository(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getUserProfile', () {
    test('should return UserModel when network is connected', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserProfile())
          .thenAnswer((_) async => testUserModel);
      
      // Act
      final result = await repository.getUserProfile();
      
      // Assert
      expect(result, equals(testUserModel));
      verify(mockRemoteDataSource.getUserProfile()).called(1);
    });

    test('should throw NetworkException when no connection', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      
      // Act & Assert
      expect(
        () => repository.getUserProfile(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
```

---

### 5. Error Handling Consistency

#### 5.1 Masalah Saat Ini
```dart
// ❌ Pattern yang bermasalah
} catch (e) {
  print('❌ Error loading achievements: $e');
  // Error hilang! User tidak dapat feedback
}
```

#### 5.2 Standard Error Handling Pattern
```dart
// ✅ Pattern yang benar
Future<void> loadData() async {
  _setLoading(true);
  _errorMessage.value = '';
  
  try {
    final data = await repository.getData();
    _data.value = data;
  } on NetworkException catch (e) {
    _errorMessage.value = 'Tidak ada koneksi internet. Coba lagi nanti.';
    Logger.warning('Network error: ${e.message}');
  } on ServerException catch (e) {
    _errorMessage.value = e.message;
    Logger.error('Server error', e);
  } on AuthenticationException {
    _errorMessage.value = 'Sesi Anda telah berakhir. Silakan login kembali.';
    await _handleLogout();
  } catch (e, stackTrace) {
    _errorMessage.value = 'Terjadi kesalahan. Silakan coba lagi.';
    Logger.error('Unexpected error', e, stackTrace);
  } finally {
    _setLoading(false);
  }
}
```

---

## 🟢 MEDIUM PRIORITY - Best Practices

### 6. Offline Support

#### 6.1 Local DataSources yang Dibutuhkan
- [ ] `PlaceLocalDataSource` - Cache places untuk offline viewing
- [ ] `PostLocalDataSource` - Cache posts
- [ ] `ArticleLocalDataSource` - Cache articles

#### 6.2 Caching Strategy
```dart
// Repository dengan caching
Future<List<PlaceModel>> getPlaces() async {
  if (await networkInfo.isConnected) {
    try {
      final remotePlaces = await remoteDataSource.getPlaces();
      await localDataSource.cachePlaces(remotePlaces);
      return remotePlaces;
    } catch (e) {
      return await localDataSource.getCachedPlaces();
    }
  } else {
    return await localDataSource.getCachedPlaces();
  }
}
```

---

### 7. Network Retry Mechanism

**Lokasi**: `lib/app/core/utils/network_retry.dart`

```dart
import 'dart:math';
import '../errors/exceptions.dart';

Future<T> withRetry<T>(
  Future<T> Function() fn, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;
  
  while (true) {
    try {
      return await fn();
    } on NetworkException {
      attempt++;
      if (attempt >= maxRetries) rethrow;
      
      final delay = initialDelay * pow(2, attempt - 1);
      await Future.delayed(delay);
    }
  }
}

// Usage
final places = await withRetry(() => placeRepository.getPlaces());
```

---

### 8. CI/CD Pipeline

**Lokasi**: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [master, develop]
  pull_request:
    branches: [master]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter analyze --no-fatal-infos

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info

  build-android:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

### 9. Flutter Flavors

#### 9.1 Setup untuk Multiple Environments
```
lib/
├── main_development.dart
├── main_staging.dart
└── main_production.dart
```

```dart
// lib/main_development.dart
void main() async {
  await AppConfig.initialize(Environment.development);
  runApp(const MyApp());
}
```

**Run commands:**
```bash
flutter run --target lib/main_development.dart
flutter run --target lib/main_staging.dart
flutter run --target lib/main_production.dart
```

---

### 10. Performance Monitoring

```dart
// Setup Firebase Performance
import 'package:firebase_performance/firebase_performance.dart';

// Custom trace untuk API calls
Future<T> traceApiCall<T>(String name, Future<T> Function() fn) async {
  final trace = FirebasePerformance.instance.newTrace(name);
  await trace.start();
  try {
    return await fn();
  } finally {
    await trace.stop();
  }
}

// Usage
final places = await traceApiCall('get_places', () => api.getPlaces());
```

---

## ⚪ LOW PRIORITY - Polish

### 11. Documentation

- [ ] Update `README.md` dengan setup instructions lengkap
- [ ] Buat `CONTRIBUTING.md` untuk guidelines kontribusi
- [ ] Buat `CHANGELOG.md` untuk tracking versi
- [ ] Dokumentasi API response formats
- [ ] Architecture Decision Records (ADR)

### 12. Code Quality

- [ ] Resolve semua TODO comments (15+ ditemukan)
- [ ] Pindahkan business logic dari Views ke Controllers
- [ ] Aktifkan `avoid_print` lint rule setelah Logger implemented

---

## 📋 Action Items Summary

| # | Task | Effort | Impact | Status |
|---|------|--------|--------|--------|
| 1 | Hapus `google-services.json` dari git | 5 min | 🔴 Critical | ⬜ |
| 2 | Buat production keystore | 30 min | 🔴 Critical | ⬜ |
| 3 | Buat `.env.example` | 15 min | 🔴 Critical | ⬜ |
| 4 | Implement Logger service | 1 jam | 🔴 Critical | ⬜ |
| 5 | Replace semua `print()` | 2 jam | 🔴 Critical | ⬜ |
| 6 | Setup Firebase Crashlytics | 1 jam | 🟡 High | ⬜ |
| 7 | Tambah unit tests untuk repositories | 4 jam | 🟡 High | ⬜ |
| 8 | Standardize error handling | 3 jam | 🟡 High | ⬜ |
| 9 | Implement offline caching | 1 hari | 🟢 Medium | ⬜ |
| 10 | Setup CI/CD pipeline | 2 jam | 🟢 Medium | ⬜ |
| 11 | Add network retry mechanism | 1 jam | 🟢 Medium | ⬜ |
| 12 | Setup Flutter flavors | 2 jam | 🟢 Medium | ⬜ |
| 13 | Update documentation | 2 jam | ⚪ Low | ⬜ |
| 14 | Resolve TODO comments | 4 jam | ⚪ Low | ⬜ |

---

## 📚 Resources

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Firebase Crashlytics Setup](https://firebase.google.com/docs/crashlytics/get-started?platform=flutter)
- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)

---

*Dokumen ini akan di-update seiring progress development.*
