import 'package:get/get.dart';
import 'package:snappie_app/app/data/models/achievement_model.dart';
import 'package:snappie_app/app/modules/profile/views/profile_view.dart';
import 'package:snappie_app/app/modules/profile/views/user_achievement_view.dart';
import 'package:snappie_app/app/modules/profile/views/user_challenge_view.dart';
import 'package:snappie_app/app/modules/profile/views/user_profile_view.dart';
import 'package:snappie_app/app/modules/profile/views/saved_places_view.dart';
import 'package:snappie_app/app/modules/profile/views/saved_posts_view.dart';
import 'package:snappie_app/app/modules/profile/views/rewards_view.dart';
import 'package:snappie_app/app/modules/profile/views/achievements_view.dart';
import 'package:snappie_app/app/modules/profile/views/challenges_view.dart';
import 'package:snappie_app/app/modules/profile/views/followers_following_view.dart';
import 'package:snappie_app/app/modules/profile/views/leaderboard_full_view.dart';
import 'package:snappie_app/app/modules/profile/views/coins_history_view.dart';
import 'package:snappie_app/app/modules/profile/views/invite_friends_view.dart';
import 'package:snappie_app/app/modules/profile/views/settings_view.dart';
import 'package:snappie_app/app/modules/profile/views/edit_profile_view.dart';
import 'package:snappie_app/app/modules/profile/views/language_view.dart';
import 'package:snappie_app/app/modules/profile/views/help_center_view.dart';
import 'package:snappie_app/app/modules/profile/views/faq_view.dart';
import 'package:snappie_app/app/modules/home/views/notifications_view.dart';
import 'package:snappie_app/app/modules/shared/components/tnc_view.dart';
import 'package:snappie_app/app/modules/home/views/post_detail_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/shared/layout/views/main_layout.dart';
import '../modules/shared/layout/bindings/main_binding.dart';
import '../modules/explore/views/place_detail_view.dart';
import '../modules/explore/views/reviews_view.dart';
import '../modules/explore/views/facilities_view.dart';
import '../modules/explore/views/gallery_view.dart';
import '../modules/explore/views/give_review_view.dart';
import '../modules/explore/bindings/explore_binding.dart';
import '../modules/shared/components/splash_view.dart';
import '../modules/mission/views/mission_photo_view.dart';
import '../modules/mission/views/mission_photo_preview_view.dart';
import '../modules/mission/views/mission_review_view.dart';
import '../modules/mission/bindings/mission_binding.dart';
import '../modules/home/views/create_post_view.dart';

class AppPages {
  AppPages._();

  static const INITIAL = '/login';

  // Splash and Auth
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const SPLASH = '/splash';
  static const TNC = '/tnc';

  // Home
  static const MAIN = '/main';
  static const POST = '/post';
  static const POST_DETAIL = '/post-detail';
  static const CREATE_POST = '/create-post';
  static const NOTIFICATIONS = '/notifications';

  // Explore
  static const EXPLORE = '/explore';
  static const PLACES = '/places';
  static const PLACE_DETAIL = '/place-detail';
  static const REVIEWS = '/reviews';
  static const GIVE_REVIEW = '/give-review';
  static const FACILITIES = '/facilities';
  static const GALLERY = '/gallery';

  // Articles
  static const ARTICLES = '/articles';
  static const ARTICLES_DETAIL = '/articles-detail';

  // Profile
  static const PROFILE = '/profile';
  static const USER_PROFILE =
      '/user-profile'; // Read-only profile untuk navigasi dari widget lain
  static const SETTINGS = '/settings';
  static const EDIT_PROFILE = '/edit-profile';
  static const LANGUAGE = '/language';
  static const HELP_CENTER = '/help-center';
  static const FAQ = '/faq';
  static const SAVED_PLACES = '/saved-places';
  static const SAVED_POSTS = '/saved-posts';
  static const LEADERBOARD = '/leaderboard';
  static const REWARDS = '/rewards';
  static const ACHIEVEMENTS = '/achievements';
  static const CHALLENGES = '/challenges';
  static const FOLLOWERS_FOLLOWING = '/followers-following';
  static const COINS_HISTORY = '/coins-history';
  static const INVITE_FRIENDS = '/invite-friends';

  // Mission
  static const MISSION_PHOTO = '/mission-photo';
  static const MISSION_PHOTO_PREVIEW = '/mission-photo-preview';
  static const MISSION_REVIEW = '/mission-review';

  static final routes = <GetPage>[
    // Splash (no binding needed)
    GetPage(
      name: SPLASH,
      page: () => const SplashView(),
    ),

    // Auth module - dengan AuthBinding
    GetPage(
      name: LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: TNC,
      page: () => const TncView(),
    ),

    // Home module - MainBinding inject semua tab controllers (Home, Explore, Articles, Profile)
    GetPage(
      name: MAIN,
      page: () => const MainLayout(),
      binding: MainBinding(),
    ),
    GetPage(
      name: POST,
      page: () => const MainLayout(),
      binding: MainBinding(),
    ),
    GetPage(
      name: POST_DETAIL,
      page: () => const PostDetailView(),
    ),

    GetPage(
      name: CREATE_POST,
      page: () => const CreatePostView(),
    ),
    GetPage(
      name: NOTIFICATIONS,
      page: () => const NotificationsView(),
    ),

    // Explore detail pages - full screen navigation dari tab explore
    GetPage(
      name: PLACE_DETAIL,
      page: () => const PlaceDetailView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: REVIEWS,
      page: () => const ReviewsView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: GIVE_REVIEW,
      page: () => const GiveReviewView(),
      binding: ExploreBinding(),
    ),
    GetPage(
      name: FACILITIES,
      page: () => const FacilitiesView(),
    ),
    GetPage(
      name: GALLERY,
      page: () => const GalleryView(),
      binding: ExploreBinding(),
    ),

    // Profile pages - full screen navigation dari tab profile
    // ProfileController sudah di-inject di MainBinding, jadi tidak perlu binding lagi
    GetPage(
      name: PROFILE,
      page: () => const ProfileView(),
      // Tidak perlu binding karena sudah di MainBinding
    ),
    // UserProfile - read-only profile untuk navigasi dari widget lain (avatar tap, dll)
    // Menggunakan StatefulWidget biasa tanpa controller/binding
    GetPage(
      name: USER_PROFILE,
      page: () => const UserProfileView(),
    ),
    GetPage(
      name: SETTINGS,
      page: () => const SettingsView(),
      // Tidak perlu binding karena sudah di MainBinding
    ),
    GetPage(
      name: HELP_CENTER,
      page: () => const HelpCenterView(),
      // Mengandalkan ProfileController yang sudah di MainBinding (tidak perlu binding)
    ),
    GetPage(
      name: LANGUAGE,
      page: () => const LanguageView(),
      // Mengandalkan ProfileController yang sudah di MainBinding (tidak perlu binding)
    ),
    GetPage(
      name: FAQ,
      page: () => const FaqView(),
      // Mengandalkan ProfileController yang sudah di MainBinding (tidak perlu binding)
    ),
    GetPage(
      name: EDIT_PROFILE,
      page: () => const EditProfileView(),
      // Mengandalkan ProfileController yang sudah di MainBinding
    ),

    // New profile pages
    GetPage(
      name: COINS_HISTORY,
      page: () => const CoinsHistoryView(),
    ),
    GetPage(
      name: INVITE_FRIENDS,
      page: () => const InviteFriendsView(),
    ),

    // Mission module
    GetPage(
      name: MISSION_PHOTO,
      page: () => const MissionPhotoView(),
      binding: MissionBinding(),
    ),
    GetPage(
      name: MISSION_PHOTO_PREVIEW,
      page: () => const MissionPhotoPreviewView(),
      // Uses existing MissionController
    ),
    GetPage(
      name: MISSION_REVIEW,
      page: () => const MissionReviewView(),
      // Uses existing MissionController
    ),

    // Saved items pages (uses existing ProfileController from MainBinding)
    GetPage(
      name: SAVED_PLACES,
      page: () => const SavedPlacesView(),
    ),
    GetPage(
      name: SAVED_POSTS,
      page: () => const SavedPostsView(),
    ),

    // Achievement pages
    GetPage(
      name: LEADERBOARD,
      page: () => const LeaderboardFullView(),
    ),
    GetPage(
      name: REWARDS,
      page: () => const RewardsView(),
    ),
    GetPage(
      name: ACHIEVEMENTS,
      page: () => const UserAchievementView(),
    ),
    GetPage(
      name: CHALLENGES,
      page: () => const UserChallengesView(),
    ),

    // Social pages
    GetPage(
      name: FOLLOWERS_FOLLOWING,
      page: () => const FollowersFollowingView(),
    ),
  ];
}
