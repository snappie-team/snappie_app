# Sitemap Aplikasi Snappie

## 1) Entry Point dan Auth

- /onboarding: OnboardingView (initial route)
- /splash: SplashView
- /login: LoginView
  - menuju /register (jika user belum terdaftar)
  - menuju /tnc
  - setelah login sukses menuju /main
- /register: RegisterView
  - setelah registrasi sukses menuju /main
- /tnc: TncView

## 2) Container Utama (Bottom Navigation)

- /main: MainLayout
- /post: MainLayout (alias route)

MainLayout memuat 4 tab berikut:
- Tab Beranda: HomeView
- Tab Jelajahi: ExploreView
- Tab Artikel: ArticlesView
- Tab Akun: ProfileView

## 3) Tab Beranda

- HomeView
  - /create-post: CreatePostView
  - /notifications: NotificationsView
  - /invite-friends: InviteFriendsView
  - kartu post dapat menuju:
    - /post-detail: PostDetailView
    - /user-profile: UserProfileView
    - /place-detail: PlaceDetailView
- PostView (placeholder, belum digunakan sebagai halaman aktif)

## 4) Tab Jelajahi

- ExploreView
  - /place-detail: PlaceDetailView
  - /challenges: UserChallengesView
- PlaceDetailView
  - /reviews: ReviewsView
  - /facilities: FacilitiesView
  - /gallery: GalleryView
  - /mission-photo: MissionPhotoView
- ReviewsView
  - /mission-photo: MissionPhotoView
  - /mission-review: MissionReviewView

## 5) Tab Artikel

- ArticlesView
  - menampilkan daftar artikel dan pencarian artikel
  - saat ini tidak ada route detail artikel yang terdaftar di GetPage

## 6) Tab Akun (Profile)

- /profile: ProfileView
- /user-profile: UserProfileView
- /settings: SettingsView
  - /edit-profile: EditProfileView
  - /language: LanguageView
  - /help-center: HelpCenterView
  - /faq: FaqView
  - /app-feedback: AppFeedbackView
- /saved-places: SavedPlacesView
- /saved-posts: SavedPostsView
- /leaderboard: LeaderboardFullView
- /achievements: UserAchievementView
- /challenges: UserChallengesView
- /followers-following: FollowersFollowingView
- /coins-history: CoinsHistoryView
- /invite-friends: InviteFriendsView
  - subpage internal via Get.to: _AddFriendsSearchView (tanpa named route)

## 7) Flow Mission

- /mission-photo: MissionPhotoView
- /mission-photo-preview: MissionPhotoPreviewView
- /mission-review: MissionReviewView
- MissionFeedbackView tersedia sebagai file halaman, tetapi belum diregistrasi sebagai named route GetPage

## 8) Halaman Notifikasi

- /notifications: NotificationsView
  - dapat menavigasi ke:
    - /followers-following
    - /post-detail
    - /place-detail
    - /leaderboard
  - terdapat pemanggilan ke /rewards, namun route ini belum terdaftar di GetPage

## 9) Catatan Konsistensi Routing

Konstanta route berikut didefinisikan, tetapi belum diregistrasi pada daftar GetPage saat ini:
- /explore
- /places
- /give-review
- /articles
- /articles-detail
- /rewards

## 10) Ringkasan Struktur Navigasi

- Entry: Onboarding/Login/Register
- Setelah autentikasi: MainLayout (4 tab)
- Detail lintas tab: post, place, profil user, notifikasi
- Mission: foto -> preview -> ulasan (feedback view ada, belum didaftarkan)
- Profile: pusat navigasi pengaturan, simpanan, leaderboard, achievement, challenge, sosial
