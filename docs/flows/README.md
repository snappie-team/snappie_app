# Snappie App - User Flows Index

## Complete Flow Documentation

This directory contains detailed documentation for every user flow in the Snappie App, organized by feature area. Each flow includes activity diagrams, sequence diagrams, state management details, and testing checklists.

---

## 📁 Directory Structure

```
docs/flows/
├── auth/                    # Authentication & Onboarding (7 flows)
├── home/                    # Home/Beranda Feed (5 flows)
├── explore/                 # Explore/Jelajahi Places (4 flows)
├── articles/                # Articles/Artikel (1 flow)
├── profile/                 # Profile/Akun (3 flows)
├── mission/                 # Mission/Gamification (1 flow)
└── cross-cutting/           # Cross-Cutting Concerns (5 flows)
```

---

## 🔐 Auth Flows (`auth/`)

| File | Flow | Description |
|------|------|-------------|
| `01-onboarding-carousel.md` | **Onboarding Carousel** | 3-page welcome carousel for new users |
| `02-google-login.md` | **Google Sign-In Login** | Firebase Google Auth → Backend token exchange |
| `03-registration.md` | **Registration (3-Step)** | Profile info, gender/avatar, preferences |
| `04-post-registration-onboarding.md` | **Tab Tour + Treasure Chest** | 4-step tab tour + reward modal |
| `05-auto-login.md` | **Auto-Login/Session Restore** | Token validation + refresh on app start |
| `06-logout.md` | **Logout** | Confirmation → Clear tokens → Redirect |
| `07-terms-conditions.md` | **Terms & Conditions** | Static content view |

**Key Components**: `AuthController`, `AuthService`, `GoogleAuthService`, `OnboardingService`, `MainController`

---

## 🏠 Home Flows (`home/`)

| File | Flow | Description |
|------|------|-------------|
| `01-feed-loading.md` | **Feed Loading & Refresh** | Parallel loads: posts, follows, saved, liked, articles |
| `02-post-interactions.md` | **Post Interactions** | Like, Save, Follow, Share, Comment, Detail (optimistic) |
| `03-create-post.md` | **Create Post** | FAB → Form → Upload → API (TODO) |
| `04-notifications.md` | **Notifications** | Bell icon → List → Navigation (UI only) |
| `05-promotional-banner.md` | **Promotional Banner** | Dismissible top banner (session-persisted) |

**Key Components**: `HomeController`, `PostRepository`, `SocialRepository`, `UserRepository`, `ArticlesRepository`

---

## 🗺️ Explore Flows (`explore/`)

| File | Flow | Description |
|------|------|-------------|
| `01-place-discovery.md` | **Place Discovery & Filtering** | Search, category, rating, price, nearby, food types, place values |
| `02-place-detail.md` | **Place Detail & Sub-Tabs** | Info, Reviews, Facilities, Gallery + Gamification status |
| `03-reviews.md` | **Reviews (View & Create)** | List reviews, filter, create with rating/photos/survey |
| `04-saved-places.md` | **Saved Places (Favorites)** | Heart toggle, optimistic updates, full-screen view |

**Key Components**: `ExploreController`, `PlaceRepository`, `ReviewRepository`, `CheckinRepository`, `GamificationRepository`, `LocationService`

---

## 📰 Articles Flows (`articles/`)

| File | Flow | Description |
|------|------|-------------|
| `01-articles-listing.md` | **Articles Listing** | Local search, category filter, external URL launch |

**Key Components**: `ArticlesController`, `ArticlesRepository`

---

## 👤 Profile Flows (`profile/`)

| File | Flow | Description |
|------|------|-------------|
| `01-main-profile.md` | **Main Profile & Tabs** | Stats, 4 sub-tabs (Profil, Tersimpan, Peringkat, Pencapaian) |
| `02-settings-subpages.md` | **Settings & Sub-Pages** | Language, Help, FAQ, Feedback, Invite, Logout |
| `03-saved-leaderboard-achievements.md` | **Saved Items, Leaderboard, Achievements** | Full-screen views for saved, rankings, badges, challenges |

**Key Components**: `ProfileController`, `UserRepository`, `PostRepository`, `AchievementRepository`, `AuthService`

---

## 🎯 Mission Flows (`mission/`)

| File | Flow | Description |
|------|------|-------------|
| `01-mission-gamification.md` | **Mission (Check-in + Review + Feedback)** | 3-step flow with Cloudinary upload, GPS, gamification rewards |

**Key Components**: `MissionController`, `CheckinRepository`, `ReviewRepository`, `CloudinaryService`, `GamificationHandlerService`, `LocationService`

---

## 🔧 Cross-Cutting Flows (`cross-cutting/`)

| File | Flow | Description |
|------|------|-------------|
| `01-token-refresh.md` | **Token Auto-Refresh** | Silent 401 handling → Refresh → Retry or Logout |
| `02-error-handling.md` | **Standardized Error Handling** | Exception hierarchy, snackbar patterns, logging |
| `03-deeplinks-appupdates.md` | **Deep Links & App Updates** | URI routing + Play Store/App Store version checks |
| `04-cloudinary-gamification.md` | **Cloudinary Upload & Gamification** | Image upload + centralized reward/achievement handling |
| `05-offline-support.md` | **Offline Support** | Isar caching, connectivity detection, graceful degradation |

**Key Components**: `DioClient`, `AuthService`, `ErrorHandler`, `AppSnackbar`, `DeepLinkService`, `AppUpdateService`, `CloudinaryService`, `GamificationHandlerService`, `NetworkInfo`

---

## 📊 Flow Statistics

| Category | Flows | Diagrams | Controllers |
|----------|-------|----------|-------------|
| Auth | 7 | 14 | 2 |
| Home | 5 | 10 | 1 |
| Explore | 4 | 8 | 1 |
| Articles | 1 | 2 | 1 |
| Profile | 3 | 6 | 1 |
| Mission | 1 | 3 | 1 |
| Cross-Cutting | 5 | 10 | 5 Services |
| **Total** | **26** | **53** | **12** |

---

## 🎨 Diagram Conventions

### Activity Diagrams
- **Rounded rectangles**: User actions/states
- **Diamonds**: Decision points
- **Rectangles**: System processes
- **Arrows**: Flow direction

### Sequence Diagrams
- **Participants**: User, Views, Controllers, Services, Repositories, APIs
- **Solid arrows**: Method calls
- **Dashed arrows**: Returns/Responses
- **Alt/Else**: Conditional flows
- **Par/And**: Parallel operations
- **Loop**: Repeated actions

---

## 🔗 Navigation Map

```
/onboarding → /login → /register (3-step) → /main
                                    ↓
                              /main (4 tabs)
    ┌────────────────────────────┼────────────────────────────┐
    ▼                            ▼                            ▼
Tab 0: /main                   Tab 1: /explore              Tab 2: /articles
(Home)                         (Places)                     (Articles)
    │                            │                            │
    ├─ /post-detail            ├─ /place-detail             ├─ External URL
    ├─ /create-post            │   ├─ /reviews               │
    └─ /notifications          │   ├─ /facilities            │
                               │   └─ /gallery               │
                               │                                │
                               ├─ /saved-places               │
                               │                                │
                               └─ /mission-photo              │
                                   ├─ /mission-photo-preview  │
                                   ├─ /mission-review         │
                                   └─ /mission-feedback       │
                                                                │
Tab 3: /profile                                                     
(Profile)                                                        
    │                                                            
    ├─ /user-profile                                             
    ├─ /edit-profile                                             
    ├─ /settings                                                 
    │   ├─ /language                                             
    │   ├─ /help-center                                          
    │   ├─ /faq                                                  
    │   ├─ /app-feedback                                         
    │   ├─ /invite-friends                                       
    │   └─ /logout → /login                                      
    ├─ /saved-places                                             
    ├─ /saved-posts                                              
    ├─ /leaderboard                                              
    ├─ /achievements                                             
    └─ /challenges                                               
```

---

## 🧪 Testing Strategy

Each flow document includes a **Testing Checklist** covering:
- Happy path validation
- Error scenarios
- Edge cases
- State persistence
- Navigation correctness

### Recommended Test Order

1. **Auth Flows** - Foundation for all other flows
2. **Home Feed** - Core user engagement
3. **Explore Places** - Primary value proposition
4. **Mission/Gamification** - Retention mechanics
5. **Profile** - User identity & progression
6. **Cross-Cutting** - Reliability & UX polish

---

## 📝 Maintenance Notes

- Update flow docs when:
  - New features added
  - API contracts change
  - Navigation restructured
  - State management patterns evolve
- Diagrams use Mermaid syntax - render in GitHub/VS Code
- Keep sequence diagrams in sync with controller code
- Activity diagrams reflect current user journeys

---

## 🔍 Quick Reference: Key Files

| Feature | Controller | View | Repository | Service |
|---------|------------|------|------------|---------|
| Auth | `AuthController` | `LoginView`, `RegisterView` | - | `AuthService`, `GoogleAuthService` |
| Home | `HomeController` | `HomeView` | `PostRepository`, `SocialRepository` | - |
| Explore | `ExploreController` | `ExploreView`, `PlaceDetailView` | `PlaceRepository`, `ReviewRepository` | `LocationService` |
| Articles | `ArticlesController` | `ArticlesView` | `ArticlesRepository` | - |
| Profile | `ProfileController` | `ProfileView` | `UserRepository`, `AchievementRepository` | `AuthService` |
| Mission | `MissionController` | `Mission*View` | `CheckinRepository`, `ReviewRepository` | `CloudinaryService`, `GamificationHandlerService` |

---

*Generated from codebase analysis. Last updated: 2026-08-18*