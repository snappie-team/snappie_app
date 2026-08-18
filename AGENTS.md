# Snappie App - Agent Instructions

## Quick Commands

```bash
# Install deps
flutter pub get

# Code generation (Isar models + JSON serialization)
dart run build_runner build --delete-conflicting-outputs

# Easy Localization generation
dart run easy_localization:generate -S assets/translations -O lib/app/core/localization -o locale_keys.g.dart -f keys

# Run app
flutter run

# Analyze (lint)
flutter analyze

# Run tests
flutter test
```

## Architecture (Simplified - No Domain Layer)

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── core/                    # Shared infrastructure
│   │   ├── constants/           # Env config, API endpoints, themes
│   │   ├── dependencies/        # DI setup (GetX) - core_dependencies.dart, data_dependencies.dart
│   │   ├── errors/              # Custom exceptions
│   │   ├── helpers/             # API response extractors
│   │   ├── network/             # Dio client + interceptors
│   │   ├── services/            # AuthService, IsarService, Logger, DeepLink
│   │   └── utils/               # Extensions, helpers
│   ├── data/                    # Data Layer
│   │   ├── datasources/
│   │   │   ├── local/           # Isar database
│   │   │   └── remote/          # Dio API calls
│   │   ├── models/              # JSON serializable + Isar annotated
│   │   └── repositories/        # Repository implementations
│   ├── modules/                 # Feature modules (GetX controllers + views + bindings)
│   │   ├── auth/, home/, explore/, articles/, profile/, mission/
│   │   └── shared/              # Reusable widgets (categorized)
│   └── routes/                  # GetX routing + API endpoints
```

## Key Technologies

- **State Management**: GetX (controllers, bindings, DI, navigation)
- **Local DB**: Isar (NoSQL) - requires `build_runner` after model changes
- **HTTP**: Dio with auth interceptors (auto token refresh on 401)
- **Auth**: Firebase Auth + Google Sign-In → backend token exchange
- **Storage**: SharedPreferences (tokens) + Isar (cached models)
- **i18n**: easy_localization (id/en) - codegen required
- **Images**: Cloudinary for uploads
- **Env**: `.env` file (not committed) - see `EnvironmentConfig` for required keys

## Critical Setup (Must Do Before Running)

1. **`.env` file** at project root with:
   ```
   ENVIRONMENT=development
   LOCAL_BASE_URL=http://10.0.2.2:8000
   HOST_BASE_URL=https://api.example.com
   API_VERSION=v1
   REGISTRATION_API_KEY=your_key
   CLOUDINARY_CLOUD_NAME=...
   CLOUDINARY_API_KEY=...
   CLOUDINARY_API_SECRET=...
   ```

2. **Google Services**: Place `google-services.json` in `android/app/` (NOT in git)

3. **Assets**: Request `assets/` folder from author (images, icons, translations)

4. **Codegen**: Run `build_runner` after any model changes

## Common Gotchas

- **No test directory exists** - tests need to be created from scratch (see PRODUCTION_READY.md for structure)
- **Release build uses debug signing** - configure release keystore in `android/app/build.gradle.kts` before production
- **Print statements everywhere** - Logger service exists but not fully migrated (see PRODUCTION_READY.md)
- **Token auto-refresh** happens in Dio interceptor; on failure → logout + redirect to login
- **Optimistic updates** used for like/save/follow in Home feed
- **Isar models** have `.g.dart` generated files - don't edit manually

## File Patterns to Know

- **Controllers**: `lib/app/modules/<feature>/controllers/<feature>_controller.dart`
- **Views**: `lib/app/modules/<feature>/views/<feature>_view.dart`
- **Bindings**: `lib/app/modules/<feature>/bindings/<feature>_binding.dart`
- **Remote datasource**: `lib/app/data/datasources/remote/<feature>_remote_datasource.dart`
- **Repository**: `lib/app/data/repositories/<feature>_repository_impl.dart`
- **Models**: `lib/app/data/models/<feature>_model.dart` + `.g.dart`

## Adding a Feature

1. Models in `data/models/` (run `build_runner`)
2. Datasources in `data/datasources/local|remote/`
3. Repository in `data/repositories/`
4. Controller/View/Binding in `modules/<feature>/`
5. Register in `core/dependencies/data_dependencies.dart`
6. Add route in `routes/app_pages.dart` + endpoint in `routes/api_endpoints.dart`

## Environment Config

`lib/app/core/constants/environment_config.dart` - reads `.env`, provides `isProduction`, `baseUrl`, `apiKey`, Cloudinary config.

## Important Files

- `lib/main.dart` - initialization order: Firebase → dotenv → CoreDependencies → DataDependencies → EasyLocalization → runApp
- `lib/app/core/services/auth_service.dart` - session management, token refresh, logout
- `lib/app/core/network/dio_client.dart` - HTTP client with auth interceptor
- `lib/app/core/helpers/api_response_helpers.dart` - `extractApiResponseData<T>()`, `extractApiResponseListData<T>()`

## Reference Docs

- `README.md` - Full architecture overview, setup, feature list
- `docs/PRODUCTION_READY.md` - Critical security fixes, testing structure, CI/CD, logging migration
- `docs/USER_FLOWS.md` - Complete user flows & use cases (10 sections, navigation map, TODOs)
- `docs/flows/README.md` - **Detailed flow index with 26 documented flows**
- `docs/flows/auth/` - 7 auth flows (onboarding, login, registration, tab tour, auto-login, logout, TNC)
- `docs/flows/home/` - 5 home flows (feed loading, post interactions, create post, notifications, promo banner)
- `docs/flows/explore/` - 4 explore flows (place discovery, place detail, reviews, saved places)
- `docs/flows/articles/` - 1 articles flow (listing, search, filter)
- `docs/flows/profile/` - 3 profile flows (main profile, settings, saved/leaderboard/achievements)
- `docs/flows/mission/` - 1 mission flow (3-step gamification)
- `docs/flows/cross-cutting/` - 5 cross-cutting flows (token refresh, error handling, deep links, Cloudinary, offline)
- `CLAUDE.md` - General coding guidelines (simplicity, surgical changes, goal-driven)