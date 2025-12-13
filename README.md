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
