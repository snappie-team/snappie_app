# User Flow: Onboarding Carousel

## Overview
First-time user experience showing app value proposition across 3 pages before authentication.

## Entry Points
- App cold start (no valid session in SharedPreferences)
- Route: `/onboarding` (AppPages.INITIAL)

## Components
- **Controller**: `OnboardingController` (`lib/app/modules/auth/controllers/onboarding_controller.dart`)
- **View**: `OnboardingView` (`lib/app/modules/auth/views/onboarding_view.dart`)
- **Binding**: `OnboardingBinding` (`lib/app/modules/auth/bindings/onboarding_binding.dart`)
- **Route**: `AppPages.ONBOARDING = '/onboarding'`

## Activity Diagram

```mermaid
flowchart TD
    A[App Cold Start] --> B{Valid Session?}
    B -->|No| C[Show Onboarding Carousel]
    B -->|Yes| D[Navigate to /main]
    C --> E[Page 1: Welcome]
    E --> F[User Swipes/Taps Next]
    F --> G[Page 2: Features]
    G --> H[User Swipes/Taps Next]
    H --> I[Page 3: Get Started]
    I --> J{User Action}
    J -->|Next/Get Started| K[Navigate to /login]
    J -->|Skip| K
    K --> L[AuthController.onInit]
    L --> M[Check Google Sign-In Availability]
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant User
    participant OnboardingView
    participant OnboardingController
    participant GetX Navigation
    participant AuthController

    User->>OnboardingView: App launches
    OnboardingView->>OnboardingController: onInit()
    OnboardingController->>OnboardingController: pageController = PageController()
    OnboardingController->>OnboardingController: currentPage = 0, totalPages = 3
    
    loop For each page (0 to 2)
        OnboardingView->>User: Render page content
        User->>OnboardingView: Swipe or tap "Next"
        OnboardingView->>OnboardingController: nextPage()
        alt Not last page
            OnboardingController->>pageController: nextPage(duration: 300ms, curve: easeInOut)
            OnboardingController->>currentPage: currentPage.value++
        else Last page
            OnboardingController->>GetX Navigation: offAllNamed(AppPages.LOGIN)
            GetX Navigation->>AuthController: Initialize AuthBinding
        end
    end
    
    alt User taps Skip (any page)
        OnboardingView->>OnboardingController: skip()
        OnboardingController->>GetX Navigation: offAllNamed(AppPages.LOGIN)
    end
```

## State Management

| Variable | Type | Description |
|----------|------|-------------|
| `currentPage` | `RxInt` | Current page index (0-2) |
| `totalPages` | `int` | Constant 3 |
| `pageController` | `PageController` | Controls page animation |

## Key Methods

### `onPageChanged(int index)`
Updates `currentPage` reactively when user swipes.

### `nextPage()`
```dart
if (currentPage < totalPages - 1) {
  pageController.nextPage(duration: 300ms, curve: Curves.easeInOut);
} else {
  Get.offAllNamed(AppPages.LOGIN); // Navigate to login
}
```

### `skip()`
Immediate navigation to login: `Get.offAllNamed(AppPages.LOGIN)`

## Navigation Flow

```
┌─────────────────┐
│  App Launch     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Check Session   │◄──── SharedPreferences (AuthService)
└────────┬────────┘
         │ No Session
         ▼
┌─────────────────┐
│ /onboarding     │
│ OnboardingView  │
│ 3 Pages         │
└────────┬────────┘
         │ Next/Skip
         ▼
┌─────────────────┐
│ /login          │
│ LoginView       │
│ AuthController  │
└─────────────────┘
```

## Edge Cases

| Scenario | Handling |
|----------|----------|
| App kill during onboarding | Restarts from page 0 (no persistence) |
| Back button on page 0 | Exits app (handled by Flutter) |
| Rapid taps | PageController handles animation queue |
| Device rotation | PageController maintains position |

## Testing Checklist

- [ ] Cold start shows onboarding
- [ ] Swipe navigation works all 3 pages
- [ ] Next button advances pages
- [ ] Skip button jumps to login
- [ ] Last page "Get Started" goes to login
- [ ] Page indicators update correctly
- [ ] No memory leaks on navigation

## Related Files

- `lib/app/modules/auth/controllers/onboarding_controller.dart`
- `lib/app/modules/auth/views/onboarding_view.dart`
- `lib/app/modules/auth/bindings/onboarding_binding.dart`
- `lib/app/routes/app_pages.dart` (ONBOARDING route)