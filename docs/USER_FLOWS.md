# Snappie App - Complete User Flows & Use Cases

## Overview
This document catalogs every user-facing flow in the application, organized by feature area. Each flow includes entry points, steps, decision points, and exit points.

---

## 1. ONBOARDING & AUTHENTICATION FLOWS

### 1.1 First Launch - Onboarding Carousel
**Entry**: App cold start (no session)
**Route**: `/onboarding`
**Controller**: `OnboardingController`
**Views**: `OnboardingView` (3 pages)

**Steps**:
1. Show onboarding carousel (3 pages)
2. User swipes or taps "Next"
3. On last page → "Get Started" → Navigate to `/login`
4. Skip button available on any page → `/login`

**Exit**: `/login`

---

### 1.2 Login with Google
**Entry**: `/login` (from onboarding or logged-out state)
**Route**: `/login`
**Controller**: `AuthController`
**Views**: `LoginView`

**Steps**:
1. User taps "Sign in with Google"
2. Google Sign-In flow (Firebase) → returns Google user (email, name)
3. Call backend `/auth/login` with Google email
4. **Success**: Token stored → `/main` (MainLayout)
5. **UserNotFound**: Redirect to `/register` (pre-fills email)
6. **HasActiveSession**: Show snackbar, stay on login
7. **NetworkError**: Show snackbar, retry

**Optimistic**: UI shows loading, no immediate state change until success

**Exit**: `/main` (success) or `/register` (new user)

---

### 1.3 Registration (Post-Google Sign-In)
**Entry**: `/register` (from login when user not found)
**Route**: `/register`
**Controller**: `AuthController` (same instance)
**Views**: `RegisterView` (3-page stepper)

**Pages**:
- **Page 0**: Name (first/last), Username (min 8 chars, debounced availability check), Email (pre-filled)
- **Page 1**: Gender (Male/Female/Other), Avatar selection (gender-specific options)
- **Page 2**: Food Types (multi-select, min 3), Place Values (multi-select, min 3)

**Validation**: All fields required, username unique, min selections met
**Submit**: `authService.registerUser()` → ProcessingModal (min 1s)
**Success**: Mark `OnboardingService.newRegistration` → `/main` (triggers tab tour + treasure chest)
**Cancel**: Google sign-out → `/login`

**Exit**: `/main` (success) or `/login` (cancel)

---

### 1.4 Post-Registration Onboarding (Tab Tour + Treasure Chest)
**Entry**: First load of `/main` after registration
**Controller**: `MainController`
**Trigger**: `OnboardingService.isNewRegistration`

**Flow**:
1. **Tab Tour** (4 steps, one per tab):
   - Step 0: Beranda (Home) - highlight tab
   - Step 1: Jelajahi (Explore)
   - Step 2: Artikel (Articles)
   - Step 3: Akun (Profile)
   - User can: Next/Previous/Skip → persists `tabTourSeen`
2. **Treasure Chest Modal**: Shown after tour completes
3. Complete → normal app usage

**Exit**: Normal tab navigation

---

### 1.5 Auto-Login / Session Restore
**Entry**: App cold start with valid tokens in SharedPreferences
**Route**: `/main` (direct, bypasses `/login`)
**Flow**:
1. `main.dart` → `AuthService.onInit()` loads tokens
2. `initAuthService()` checks `authService.isLoggedIn`
3. True → `AppPages.MAIN`, False → `AppPages.INITIAL` (onboarding)
4. MainLayout preloads all 4 tab controllers

**Exit**: `/main` with all tabs preloaded

---

### 1.6 Logout
**Entry**: Profile → Settings → Logout button
**Controller**: `ProfileController.logout()`
**Flow**:
1. Confirmation dialog
2. Loading dialog
3. `authService.logout()` (clears tokens, Isar cache)
4. Success snackbar → `/login`
4. Error snackbar, stay on profile

**Exit**: `/login`

---

### 1.7 Terms & Conditions
**Entry**: Login/Register screens (links)
**Route**: `/tnc`
**View**: `TncView` (static content)

---

## 2. MAIN NAVIGATION (4 TABS)

### 2.1 Tab Structure
**Route**: `/main` → `MainLayout` with bottom navigation
**Controller**: `MainController` (persistent)

**Tabs** (index → route → controller):
| Index | Label | Route | Controller |
|-------|-------|-------|------------|
| 0 | Beranda (Home) | `/main` | `HomeController` |
| 1 | Jelajahi (Explore) | `/explore` | `ExploreController` |
| 2 | Artikel (Articles) | `/articles` | `ArticlesController` |
| 3 | Akun (Profile) | `/profile` | `ProfileController` |

**Behavior**:
- `MainController.changeTab(index)` switches tab
- Switching to Home (0) or Profile (3) triggers data refresh if already initialized
- All 4 controllers preloaded at startup (`initializeIfNeeded()`)

---

## 3. BERANDA (HOME) FLOWS

### 3.1 Feed Loading
**Entry**: Tab 0 selected (first time or refresh)
**Controller**: `HomeController.initializeIfNeeded()` → `loadHomeData()`

**Parallel Loads**:
1. User profile from AuthService
2. Posts (page 1, 20 items) via `PostRepository.getPosts()`
3. Follow data (followers/following) via `SocialRepository.getFollowData()`
4. Saved posts via `UserRepository.getUserSaved()`
5. Liked posts (derived from loaded posts)
6. Articles for carousel (non-blocking) via `ArticlesRepository.getArticles()`

**Pull-to-refresh**: `refreshData()` → full reload

---

### 3.2 Post Interactions (Optimistic Updates)

#### Like/Unlike Post
**Action**: Tap heart icon on post
**Flow**:
1. Optimistic: Toggle local `_likedPostIds`, update `likesCount` on post model
2. API: `PostRepository.toggleLikePost(postId)`
3. **Success**: Confirm state
4. **Failure**: Revert optimistic update, throw error → snackbar

#### Save/Unsave Post
**Action**: Tap bookmark icon
**Flow**:
1. Optimistic: Toggle local `_savedPostIds`
2. API: `UserRepository.toggleSavedPost(savedPostIds)` (sends full list)
3. **Success**: Sync with server response
4. **Failure**: Revert, reload saved posts from server

#### Follow/Unfollow User
**Action**: Tap follow button on post author
**Flow**:
1. Optimistic: Toggle `_followingOverrides[userId]`
2. API: `SocialRepository.followUser(userId)`
3. **Failure**: Revert override

#### Share Post
**Action**: Tap share icon
**Status**: TODO - shows "Post shared successfully!" snackbar

#### Comment Post
**Action**: Tap comment icon
**Status**: TODO - shows "Comment feature coming soon!" snackbar

#### View Post Detail
**Action**: Tap post content
**Route**: `/post-detail`
**View**: `PostDetailView`
**Data**: Passes selected `PostModel` + image URLs

---

### 3.3 Create Post
**Entry**: FAB on Home tab
**Route**: `/create-post`
**View**: `CreatePostView`
**Status**: Basic implementation, navigation only

---

### 3.4 Notifications
**Entry**: Bell icon on Home tab
**Route**: `/notifications`
**View**: `NotificationsView`
**Controller**: `NotificationController`
**Status**: UI/navigation only

---

### 3.5 Promotional Banner
**Entry**: Home feed top
**Component**: `PromotionalBanner` (dismissible)
**State**: `HomeController.showBanner` (persisted per session)
**Dismiss**: `hideBanner()` → hidden until app restart

---

## 4. JELAJAHI (EXPLORE) FLOWS

### 4.1 Place Discovery
**Entry**: Tab 1 selected (requires login)
**Controller**: `ExploreController.initializeIfNeeded()` → `loadExploreData()`

**Loads** (parallel):
1. Places (50 items) via `PlaceRepository.getPlaces()`
2. Categories (hardcoded fallback)

**Authentication Gate**: Redirects to login if not authenticated

---

### 4.2 Place Filtering & Search

#### Local Search (Debounced)
**Input**: Search bar text
**Flow**: `handleSearchInput(query)` → 300ms debounce → `_applyLocalSearch()` filters `_allPlaces` by name
**State**: `isSearching` for loading indicator

#### Category Filter
**Action**: Tap category chip
**Flow**: `filterByCategory(category)` → `loadPlaces(refresh: true)`

#### Rating Filter
**Action**: Select rating (1-5) → `applyRatingFilter()` → reload
**Clear**: `clearRatingFilter()`

#### Price Range Filter
**Action**: Select price range → `applyPriceFilter()` → reload

#### Special Filters (mutually exclusive via `_selectedFilter`):
- **Popular** (`popular=true`)
- **Partner** (`partner=true`)
- **Nearby** (requires location permission → GPS coords)
- **Food Types** (multi-select from `FoodTypeExtension`)
- **Place Values** (multi-select from `PlaceValueExtension`)

#### Clear All Filters
**Action**: `clearFilters()` → resets all filter state → reload

---

### 4.3 Place Detail
**Entry**: Tap place card
**Route**: `/place-detail`
**View**: `PlaceDetailView`
**Controller**: `ExploreController` (shared instance)

**Loads**:
1. `loadPlaceById(placeId)` → full place details
2. `loadPlaceReviews(placeId)` → reviews list
3. `loadPlaceGamificationStatus(placeId)` → checkin/review eligibility
4. `updatePlaceFeedbackStatus(placeId)` → checks if user submitted feedback

**Tabs in Detail**:
- **Info**: Place details, attributes, facilities
- **Ulasan (Reviews)**: `/reviews` route, `ReviewsView`
- **Fasilitas**: `/facilities` route, `FacilitiesView`
- **Galeri**: `/gallery` route, `GalleryView` (checkins + posts)

---

### 4.4 Reviews Flow

#### View Reviews
**Route**: `/reviews` (from place detail)
**View**: `ReviewsView`
**Data**: `ExploreController.reviews` (loaded with place detail)

#### Create Review (Standalone)
**Entry**: Place detail → "Tulis Ulasan" button (not via mission)
**Route**: `/give-review` (not in routes, uses `ExploreController.createReview()` directly)
**Flow**:
1. User inputs: rating (1-5), content, optional images
2. `ExploreController.createReview()` → `ReviewRepository.createReview()`
3. Success: Snackbar with XP/coin reward → back to reviews list
4. Error: Snackbar

---

### 4.5 Check-in Flow (Standalone)
**Entry**: Place detail → "Check-in" button
**Controller**: `ExploreController.createCheckin()`
**Requires**: Location permission, GPS coords
**Flow**:
1. Get current position via `LocationService`
2. `CheckinRepository.createCheckin(placeId, lat, lon, additionalInfo)`
3. Success snackbar

---

### 4.6 Gallery (Checkins + Posts)
**Entry**: Place detail → Galeri tab
**Route**: `/gallery`
**View**: `GalleryView`
**Loads** (parallel):
1. `loadGalleryCheckins(placeId)` → checkins with images
2. `loadGalleryPosts(placeId)` → posts with images
**Display**: Grid of all images from both sources

---

### 4.7 Saved Places (Favorites)
**Entry**: Profile → Saved Places or Explore → heart icon
**Route**: `/saved-places`
**View**: `SavedPlacesView`
**Controller**: `ExploreController` (shared)

**Load**: `loadSavedPlaces()` → `UserRepository.getUserSaved()` → extract place IDs

**Toggle Save**:
- Optimistic: Add/remove from `_savedPlaces`
- API: `UserRepository.toggleSavedPlace(savedPlaceIds)` (sends full list)
- Sync with server response

---

### 4.8 Mission / Gamification Flow (Multi-Step)
**Entry**: Place detail → "Mulai Mission" (when eligible)
**Routes**: 
- `/mission-photo` → `MissionPhotoView`
- `/mission-photo-preview` → `MissionPhotoPreviewView`
- `/mission-review` → `MissionReviewView`
**Controller**: `MissionController` (fresh per mission via `MissionBinding`)

**Steps**:
1. **Photo (Check-in)**:
   - Camera capture or gallery pick
   - Preview screen (confirm/retake)
   - Submit: Upload to Cloudinary → `CheckinRepository.createCheckin()` with coords + image URL
   - Gamification handling via `GamificationHandlerService`
   - Success → Step 2

2. **Review**:
   - Rating (required), content, optional media
   - Food Types multi-select, Place Values multi-select
   - Survey (3 yes/no questions) → stored in `surveyAnswers`
   - Submit: `ReviewRepository.createReview()` with all data + checkin image
   - Gamification handling
   - Success → Step 3

3. **Feedback** (App Review):
   - 4-step feedback: info accuracy, best photo, hidden gem, recommend rating, liked features, free text
   - Submit: `ReviewRepository.updateReview()` with `feedback` in `additional_info` + `is_submitted_app_review=true`
   - Updates local profile coins/XP via `ProfileController`
   - Success → Mission complete, back to place detail

**Conflict Handling** (409):
- Already checked-in this month → `isConflictError` flag
- Already reviewed this month → `isConflictError` flag
- UI shows appropriate error state

---

## 5. ARTIKEL (ARTICLES) FLOWS

### 5.1 Article Listing
**Entry**: Tab 2 selected
**Controller**: `ArticlesController.initializeIfNeeded()` → `loadArticles()` + `loadCategories()`

**Loads**: Articles via `ArticlesRepository.getArticles()` (no auth required)

---

### 5.2 Article Filtering & Search

#### Local Search (Debounced)
**Input**: Search bar
**Flow**: `searchArticles(query)` → 300ms debounce → `_applyFilters()` searches title, description, author, category

#### Category Filter
**Action**: Tap category
**Flow**: `filterByCategory(category)` → `_applyFilters()`

#### Clear Filters
**Action**: `clearFilters()` → reset search + category

---

### 5.3 Article Detail
**Entry**: Tap article card
**Route**: `/articles-detail` (not implemented in routes)
**Action**: Opens external URL via `url_launcher`

---

### 5.4 Bookmark Article
**Action**: Tap bookmark icon
**Status**: TODO - shows "Article bookmarked successfully!" snackbar

---

## 6. AKUN (PROFILE) FLOWS

### 6.1 Profile Loading
**Entry**: Tab 3 selected (first time)
**Controller**: `ProfileController.initializeIfNeeded()` → `_loadAllData()`

**Parallel Loads**:
1. `loadUserProfile()` → `UserRepository.getUserProfile()` (fresh from API)
2. `loadUserPosts()` → `PostRepository.getPostsByUserId()`
3. `loadSavedItems()` → `UserRepository.getUserSaved()` (places + posts with preview data)
4. `loadLeaderboard()` → weekly + monthly
5. `loadUserAchievements()` → `AchievementRepository.getUserAchievements()` + challenges count

**Pull-to-refresh**: `refreshProfile()` → full reload

---

### 6.2 Profile Tabs (Bottom Tab Bar in ProfileView)
| Index | Tab | Content |
|-------|-----|---------|
| 0 | Profil | User stats, posts grid |
| 1 | Tersimpan | Saved places + saved posts (toggle) |
| 2 | Peringkat | Weekly/Monthly leaderboard toggle |
| 3 | Pencapaian | Achievements + Challenges badges |

---

### 6.3 Profile Sub-Flows

#### View Own Profile (Editable)
**Route**: `/profile` (tab)
**View**: `ProfileView`
**Actions**: Edit profile, Settings, Logout, Share profile

#### View Other User Profile (Read-Only)
**Entry**: Tap user avatar on post, comment, leaderboard
**Route**: `/user-profile`
**View**: `UserProfileView` (stateless, no controller)

#### Edit Profile
**Route**: `/edit-profile`
**View**: `EditProfileView`
**Status**: TODO - shows "Edit profile feature coming soon!"

#### Settings
**Route**: `/settings`
**View**: `SettingsView`
**Options**: Language, Help Center, FAQ, App Feedback, Invite Friends, Logout

#### Language Selection
**Route**: `/language`
**View**: `LanguageView`
**Options**: Indonesian, English (uses `EasyLocalization`)

#### Help Center
**Route**: `/help-center`
**View**: `HelpCenterView` (static content)

#### FAQ
**Route**: `/faq`
**View**: `FaqView` (static content)

#### Invite Friends / Share Profile
**Route**: `/invite-friends`
**View**: `InviteFriendsView`
**Features**: Share link + QR code (`qr_flutter` + `share_plus`)

#### App Feedback
**Route**: `/app-feedback`
**View**: `AppFeedbackView`
**Status**: TODO

#### Saved Places (Full Screen)
**Route**: `/saved-places`
**View**: `SavedPlacesView`
**Data**: `ExploreController.savedPlaces` (loaded on demand)

#### Saved Posts (Full Screen)
**Route**: `/saved-posts`
**View**: `SavedPostsView`
**Data**: `ProfileController.savedPosts`

#### Leaderboard (Full Screen)
**Route**: `/leaderboard`
**View**: `LeaderboardFullView`
**Tabs**: Weekly / Monthly
**Data**: `ProfileController.weeklyLeaderboard` / `monthlyLeaderboard`

#### Achievements
**Route**: `/achievements`
**View**: `UserAchievementView`
**Data**: `ProfileController.userAchievements`

#### Challenges
**Route**: `/challenges`
**View**: `UserChallengesView`
**Badge**: `ProfileController.completedChallengesCount` (red dot indicator)

#### Followers / Following
**Route**: `/followers-following`
**View**: `FollowersFollowingView`
**Tabs**: Followers / Following
**Data**: From `SocialRepository` (not fully implemented in ProfileController)

#### Coins History
**Route**: `/coins-history`
**View**: `CoinsHistoryView`
**Status**: UI only

---

### 6.4 Avatar Frame Selection
**Entry**: Profile → tap avatar frame area
**Flow**: `ProfileController.updateSelectedFrame(frameUrl)` → API → updates local state
**Data**: `userData.userSettings.frameUrl`

---

### 6.5 Profile Stats (From UserModel)
- Total Coins, XP, Following, Followers
- Total Check-ins, Posts, Articles, Reviews, Achievements, Challenges
- Real-time updates via `addCoins()`, `addExp()`, `incrementCompletedChallenges()`

---

## 7. CROSS-CUTTING CONCERNS

### 7.1 Token Auto-Refresh
**Location**: `DioClient` interceptor
**Trigger**: 401 response on any API call
**Flow**:
1. Attempt refresh token call
2. **Success**: Retry original request with new token
3. **Failure**: `AuthService.logout()` → redirect to `/login`
**Transparent**: User rarely sees this unless refresh fails

---

### 7.2 Offline / Network Handling
**Check**: `ConnectivityPlus` in repositories
**Pattern**: 
- Online: Fetch from API → cache to Isar
- Offline: Read from Isar cache
- NetworkException thrown → UI shows error state

---

### 7.3 Error Handling Pattern
**Standard** (in controllers):
```dart
try {
  _setLoading(true);
  data = await repository.call();
  _data.value = data;
} on NetworkException catch (e) {
  _errorMessage.value = 'No connection';
  Logger.warning(...);
} on ServerException catch (e) {
  _errorMessage.value = e.message;
  Logger.error(...);
} on AuthenticationException {
  _errorMessage.value = 'Session expired';
  await _handleLogout();
} catch (e, stack) {
  _errorMessage.value = 'Unexpected error';
  Logger.error(...);
} finally {
  _setLoading(false);
}
```

---

### 7.4 Deep Links
**Service**: `DeepLinkService`
**Entry**: `main.dart` → `DeepLinkService.init()` after `runApp`
**Routes**: Handles custom scheme links (not fully documented)

---

### 7.5 App Update Check
**Service**: `AppUpdateService`
**Trigger**: `MainController.onReady()` + `AuthController.onReady()`
**Flow**: Checks for update → prompts user

---

### 7.6 Image Upload (Cloudinary)
**Used by**: Mission (checkin photo), Create Post (TODO), Profile avatar (TODO)
**Service**: `CloudinaryService.uploadCheckinImage(File)`
**Flow**: Local file → Cloudinary → secure URL → sent to backend

---

### 7.7 Gamification Handler
**Service**: `GamificationHandlerService`
**Trigger**: API responses with `gamification` field (checkin, review, feedback)
**Handles**:
- XP/Coin rewards → updates `ProfileController`
- Achievement unlocks → sequential popups (non-stacking)
- Challenge progress updates → background refresh
- Non-blocking: runs after main success flow

---

## 8. NAVIGATION MAP

```
/onboarding (initial)
    ↓
/login → /register (3-step) → /main
    ↑                        ↓
    └────── logout ─────────┘

/main (MainLayout with 4 tabs)
├── Tab 0: /main → HomeController
│   ├── /post-detail (PostDetailView)
│   ├── /create-post (CreatePostView)
│   └── /notifications (NotificationsView)
│
├── Tab 1: /explore → ExploreController
│   ├── /place-detail (PlaceDetailView)
│   │   ├── /reviews (ReviewsView)
│   │   ├── /facilities (FacilitiesView)
│   │   └── /gallery (GalleryView)
│   ├── /saved-places (SavedPlacesView)
│   └── Mission Flow:
│       ├── /mission-photo (MissionPhotoView)
│       ├── /mission-photo-preview (MissionPhotoPreviewView)
│       └── /mission-review (MissionReviewView)
│
├── Tab 2: /articles → ArticlesController
│   └── (external URL launch)
│
└── Tab 3: /profile → ProfileController
    ├── /user-profile (UserProfileView)
    ├── /edit-profile (EditProfileView)
    ├── /settings (SettingsView)
    │   ├── /language (LanguageView)
    │   ├── /help-center (HelpCenterView)
    │   ├── /faq (FaqView)
    │   ├── /invite-friends (InviteFriendsView)
    │   ├── /app-feedback (AppFeedbackView)
    │   └── (logout → /login)
    ├── /saved-places (SavedPlacesView)
    ├── /saved-posts (SavedPostsView)
    ├── /leaderboard (LeaderboardFullView)
    ├── /achievements (UserAchievementView)
    ├── /challenges (UserChallengesView)
    ├── /followers-following (FollowersFollowingView)
    └── /coins-history (CoinsHistoryView)
```

---

## 9. STATE MANAGEMENT NOTES

- **GetX Controllers**: One per feature, registered in `MainBinding` (tabs) or route bindings (auth, mission)
- **Reactive**: `.obs` variables, `Obx()` in views
- **Persistence**: 
  - Tokens/user session → SharedPreferences (AuthService)
  - Cached models → Isar (UserLocalDataSource)
  - Onboarding flags → SharedPreferences (OnboardingService)
- **Optimistic Updates**: Home (like, save, follow), Explore (save place), Mission (multi-step)
- **Lazy Initialization**: `initializeIfNeeded()` pattern prevents duplicate loads

---

## 10. KNOWN TODOs / INCOMPLETE FLOWS

| Flow | Status | Location |
|------|--------|----------|
| Comment on post | TODO | `HomeController.commentPost()` |
| Share post | TODO | `HomeController.sharePost()` |
| Create post | Basic UI only | `CreatePostView` |
| Bookmark article | TODO | `ArticlesController.bookmarkArticle()` |
| Edit profile | TODO | `ProfileController.editProfile()` |
| View achievements (detail) | TODO | `ProfileController.viewAchievements()` |
| View history | TODO | `ProfileController.viewHistory()` |
| App feedback submit | TODO | `AppFeedbackView` |
| Followers/Following API | Partial | `SocialRepository` |
| Categories API | Hardcoded | `ExploreController.loadCategories()` |
| Article categories API | Empty | `ArticlesController.loadCategories()` |
| Notifications API | Not connected | `NotificationController` |
| Deep link routing | Partial | `DeepLinkService` |
| Unit/Widget tests | None exist | `test/` directory missing |
| Crashlytics | Not integrated | `PRODUCTION_READY.md` |
| Release signing | Debug only | `android/app/build.gradle.kts` |