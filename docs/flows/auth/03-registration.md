# User Flow: Registration (3-Step Stepper)

## Overview
Post-Google Sign-In registration for new users. Collects profile info in 3 steps with validation.

## Entry Points
- Route: `/register` (from login when `AuthErrorType.userNotFound`)
- Pre-filled: Email from Google account

## Components
- **Controller**: `AuthController` (same instance as login)
- **View**: `RegisterView` (`lib/app/modules/auth/views/register_view.dart`)
- **Route**: `AppPages.REGISTER = '/register'`
- **Binding**: `AuthBinding` (shared with login)

## Activity Diagram

```mermaid
flowchart TD
    A[/register Route] --> B[RegisterView: Page 0 - Basic Info]
    B --> C[User Enters: First Name, Last Name, Username, Email]
    C --> D{Validation}
    D -->|Invalid| E[Show Field Errors]
    E --> C
    D -->|Valid| F[Username Available?]
    F -->|No| G[Show 'Username taken' Error]
    G --> C
    F -->|Yes| H[Next Page]
    H --> I[RegisterView: Page 1 - Gender & Avatar]
    I --> J[User Selects Gender]
    J --> K[User Selects Avatar]
    K --> L{Both Selected?}
    L -->|No| M[Show Validation Error]
    M --> K
    L -->|Yes| N[Next Page]
    N --> O[RegisterView: Page 2 - Preferences]
    O --> P[User Selects Food Types (min 3)]
    P --> Q[User Selects Place Values (min 3)]
    Q --> R{Both >= 3?}
    R -->|No| S[Show Min Selection Error]
    S --> P
    R -->|Yes| T[Tap 'Daftar' / Register]
    T --> U[ProcessingModal Show]
    U --> V[AuthService.registerUser]
    V --> W{Backend Response}
    W -->|Success| X[Mark New Registration]
    X --> Y[Get.offAllNamed /main]
    Y --> Z[MainController: Tab Tour + Treasure Chest]
    W -->|Error| A1[Hide Modal + Show Snackbar]
    A1 --> O
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant RegisterView
    participant AuthController
    participant AuthService
    participant Backend API
    participant OnboardingService
    participant GetX Navigation
    participant MainController

    Note over User,MainController: Entry from Login (UserNotFound)
    
    User->>RegisterView: Opens /register
    RegisterView->>AuthController: (shared instance)
    AuthController->>AuthController: _loadGoogleUserData()
    AuthController->>registerEmailController: text = googleEmail
    
    %% Page 0: Basic Info
    User->>RegisterView: Enters firstname, lastname, username
    RegisterView->>AuthController: firstnameController.addListener()
    AuthController->>AuthController: _isFirstnameValid = !empty
    RegisterView->>AuthController: usernameController.addListener()
    AuthController->>AuthController: _isUsernameValid = length >= 8
    AuthController->>AuthController: debounced _checkUsernameAvailability()
    
    User->>RegisterView: Taps "Next"
    RegisterView->>AuthController: nextPage()
    AuthController->>AuthController: _selectedPageIndex = 1
    
    %% Page 1: Gender & Avatar
    User->>RegisterView: Selects Gender
    RegisterView->>AuthController: setGender(Gender.male/female/other)
    AuthController->>AuthController: _selectedGender = value
    AuthController->>AuthController: getAvatarOptions(gender)
    
    User->>RegisterView: Selects Avatar
    RegisterView->>AuthController: setAvatar(avatarPath)
    AuthController->>AuthController: _selectedAvatar = path
    
    User->>RegisterView: Taps "Next"
    RegisterView->>AuthController: nextPage()
    AuthController->>AuthController: _selectedPageIndex = 2
    
    %% Page 2: Preferences
    User->>RegisterView: Selects Food Types (checkboxes)
    RegisterView->>AuthController: toggleFoodTypeSelection(type)
    AuthController->>AuthController: _selectedFoodTypes.add/remove
    
    User->>RegisterView: Selects Place Values (checkboxes)
    RegisterView->>AuthController: togglePlaceValueSelection(value)
    AuthController->>AuthController: _selectedPlaceValues.add/remove
    
    User->>RegisterView: Taps "Daftar" (Register)
    RegisterView->>AuthController: register()
    
    AuthController->>AuthController: _validateForm()
    alt Validation Fails
        AuthController->>AuthController: _showSnackbar(error)
        return
    end
    
    AuthController->>AuthController: _isRegisterLoading = true
    AuthController->>ProcessingModal: show("Mendaftarkan akun Anda...")
    
    AuthController->>AuthService: registerUser(name, username, email, gender, avatar, foodTypes, placeValues)
    AuthService->>Backend API: POST /auth/register {profile_data}
    
    alt Success (200/201)
        Backend API-->>AuthService: {user, tokens}
        AuthService->>AuthService: _saveTokens()
        AuthService-->>AuthController: error = null
        AuthController->>AuthController: wait min 1 second
        AuthController->>ProcessingModal: hide()
        AuthController->>OnboardingService: markAsNewRegistration()
        AuthController->>GetX Navigation: offAllNamed(AppPages.MAIN)
        GetX Navigation->>MainController: checkAndStartOnboardingFlow()
        MainController->>MainController: _startTabTour() -> _showTreasureChest()
    else Error
        Backend API-->>AuthService: {message}
        AuthService-->>AuthController: error = message
        AuthController->>AuthController: wait min 1 second
        AuthController->>ProcessingModal: hide()
        AuthController->>AuthController: _showSnackbar("Gagal", error)
    end
    
    AuthController->>AuthController: _isRegisterLoading = false
```

## State Management (AuthController - Registration Fields)

| Variable | Type | Description |
|----------|------|-------------|
| `_selectedPageIndex` | `RxInt` | Current stepper page (0,1,2) |
| `_isRegisterLoading` | `RxBool` | Submit loading state |
| `firstnameController` | `TextEditingController` | First name input |
| `lastnameController` | `TextEditingController` | Last name input |
| `usernameController` | `TextEditingController` | Username input (debounced check) |
| `registerEmailController` | `TextEditingController` | Email (pre-filled) |
| `_selectedGender` | `RxString` | 'male'/'female'/'others' |
| `_selectedAvatar` | `RxString` | Selected avatar path |
| `_selectedFoodTypes` | `RxList<String>` | Multi-select food types |
| `_selectedPlaceValues` | `RxList<String>` | Multi-select place values |
| `_isUsernameAvailable` | `RxBool` | Username availability result |
| `_isCheckingUsername` | `RxBool` | Debounced check in progress |
| `_usernameError` | `Rxn<String>` | Username error message |

## Validation Rules

### Page 0: Basic Info
| Field | Rule | Error Message |
|-------|------|---------------|
| First Name | Required, non-empty | "Please enter your full name" |
| Last Name | Required, non-empty | "Please enter your full name" |
| Username | Required, min 8 chars | "Username must be at least 8 characters" |
| Username | Unique (debounced API) | "Username sudah digunakan" |
| Email | Required, valid format | "Email is required" |

### Page 1: Gender & Avatar
| Field | Rule | Error Message |
|-------|------|---------------|
| Gender | Required (one selected) | "Please select your gender" |
| Avatar | Required (one selected) | "Please select an avatar" |

### Page 2: Preferences
| Field | Rule | Error Message |
|-------|------|---------------|
| Food Types | Min 3 selected | "Please select at least 3 food types" |
| Place Values | Min 3 selected | "Please select at least 3 place values" |

## Key Methods

### `_validateForm()` (lines 415-505)
Comprehensive validation across all 3 pages. Returns `false` with snackbar on first failure.

### `_checkUsernameAvailability(String username)` (lines 137-149)
```dart
// Debounced 600ms after typing stops
Future.delayed(600ms, () {
  if (versionMatches) _checkUsernameAvailability(username);
});
```
Calls `authService.checkUsernameAvailability(username)` → updates `_isUsernameAvailable`, `_usernameError`.

### `register()` (lines 334-413)
```dart
Future<void> register() async {
  if (!_validateForm()) return;
  
  _isRegisterLoading.value = true;
  ProcessingModal.show(message: 'Mendaftarkan akun Anda...');
  
  final error = await authService.registerUser(
    name: '${firstname} ${lastname}',
    username: username,
    email: email,
    gender: gender,
    imageUrl: avatar,
    foodTypes: foodTypes,
    placeValues: placeValues,
  );
  
  // Ensure min 1 second display
  await Future.delayed(max(0, 1s - elapsed));
  ProcessingModal.hide();
  
  if (error == null) {
    await OnboardingService.markAsNewRegistration();
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().checkAndStartOnboardingFlow();
    }
    Get.offAllNamed(AppPages.MAIN);
  } else {
    _showSnackbar('Gagal', error, Colors.red);
  }
}
```

## Avatar Options (Gender-Specific)

### Male Avatars
| Asset | Color |
|-------|-------|
| `avatar_m1_hdpi.png` | Blue |
| `avatar_m2_hdpi.png` | Green |
| `avatar_m3_hdpi.png` | Orange |
| `avatar_m4_hdpi.png` | Grey |

### Female Avatars
| Asset | Color |
|-------|-------|
| `avatar_f1_hdpi.png` | Orange |
| `avatar_f2_hdpi.png` | Yellow |
| `avatar_f3_hdpi.png` | Green |
| `avatar_f4_hdpi.png` | Pink |

## Navigation Flow

```
┌─────────────┐
│  /login     │
│ UserNotFound│
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│  /register          │
│  RegisterView       │
│  Stepper: 3 Pages   │
└────────┬────────────┘
         │
    ┌────┴────┐
    ▼         ▼
Page 0    Page 1
Basic     Gender
Info      Avatar
    │         │
    └────┬────┘
         ▼
    Page 2
    Preferences
    (Food/Place)
         │
         ▼
┌─────────────────────┐
│  ProcessingModal    │
│  (min 1 second)     │
└────────┬────────────┘
         │
    ┌────┴────┐
    ▼         ▼
Success     Error
    │         │
    ▼         ▼
/main    Snackbar +
         Stay on Page 2
```

## Post-Registration Onboarding Trigger

After successful registration:
1. `OnboardingService.markAsNewRegistration()` - sets flag in SharedPreferences
2. `Get.offAllNamed(AppPages.MAIN)` - navigates to main layout
3. `MainController.checkAndStartOnboardingFlow()` - checks flag
4. If `isNewRegistration` && !`hasSeenTabTour`:
   - `_startTabTour()` → 4-step tab tour
   - `_persistTourSeen()` → marks tour complete
   - `_showTreasureChest()` → reward modal

## Edge Cases

| Scenario | Handling |
|----------|----------|
| Back button on Page 0 | `previousPage()` → stays on Page 0 |
| Back button on Page 1/2 | `previousPage()` → goes back |
| Username check race condition | `_usernameCheckVersion` counter ensures latest wins |
| Network timeout during register | ProcessingModal min 1s, then error snackbar |
| User kills app during registration | No partial state saved (stateless until submit) |
| Duplicate registration attempt | Backend returns error, shown in snackbar |

## Testing Checklist

- [ ] Page 0: All validations work
- [ ] Page 0: Username debounced check (600ms)
- [ ] Page 0: Next disabled until valid
- [ ] Page 1: Gender selection updates avatars
- [ ] Page 1: Avatar selection required
- [ ] Page 2: Food types multi-select (min 3)
- [ ] Page 2: Place values multi-select (min 3)
- [ ] Page 2: Register button validates all pages
- [ ] Success: Navigates to `/main` + tab tour
- [ ] Error: Shows snackbar, stays on Page 2
- [ ] Cancel: Google sign-out → `/login`
- [ ] ProcessingModal shows min 1 second

## Related Files

- `lib/app/modules/auth/controllers/auth_controller.dart` (lines 332-517)
- `lib/app/modules/auth/views/register_view.dart`
- `lib/app/core/services/auth_service.dart` (registerUser method)
- `lib/app/core/services/onboarding_service.dart`
- `lib/app/modules/shared/widgets/_dialog_widgets/processing_modal.dart`