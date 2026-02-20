import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../home/controllers/home_controller.dart';
import '../../../explore/controllers/explore_controller.dart';
import '../../../articles/controllers/articles_controller.dart';
import '../../../profile/controllers/profile_controller.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/post_repository_impl.dart';
import '../../../../data/repositories/place_repository_impl.dart';
import '../../../../data/repositories/review_repository_impl.dart';
import '../../../../data/repositories/checkin_repository_impl.dart';
import '../../../../data/repositories/user_repository_impl.dart';
import '../../../../data/repositories/achievement_repository_impl.dart';
import '../../../../data/repositories/social_repository_impl.dart';
import '../../../../data/repositories/gamification_repository_impl.dart';

import '../../../../data/repositories/articles_repository_impl.dart';

/// Binding untuk MainLayout
/// Inject semua controllers yang dibutuhkan oleh tabs di MainLayout
///
/// HYBRID APPROACH:
/// - MainController: permanent (root controller)
/// - Tab Controllers: lazyPut (dibuat saat pertama kali diakses)
/// - Combined dengan LazyIndexedChild untuk optimal lazy loading
class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Main controller - permanent (always alive)
    Get.put<MainController>(
      MainController(),
      permanent: true,
    );

    // Tab controllers - lazyPut with fenix for auto-recreation
    // fenix: true ensures controller is auto-recreated if disposed
    // Di-combine dengan LazyIndexedChild untuk lazy initialization

    // Home tab
    Get.lazyPut<HomeController>(
      () => HomeController(
        authService: Get.find<AuthService>(),
        postRepository: Get.find<PostRepository>(),
        socialRepository: Get.find<SocialRepository>(),
        userRepository: Get.find<UserRepository>(),
        articlesRepository: Get.find<ArticlesRepository>(),
      ),
      fenix: true,
    );

    // Explore tab
    Get.lazyPut<ExploreController>(
      () => ExploreController(
        userRepository: Get.find<UserRepository>(),
        placeRepository: Get.find<PlaceRepository>(),
        reviewRepository: Get.find<ReviewRepository>(),
        checkinRepository: Get.find<CheckinRepository>(),
        postRepository: Get.find<PostRepository>(),
        authService: Get.find<AuthService>(),
        gamificationRepository: Get.find<GamificationRepository>(),
      ),
      fenix: true,
    );

    // Articles tab
    Get.lazyPut<ArticlesController>(
      () => ArticlesController(),
      fenix: true,
    );

    // Profile tab
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authService: Get.find<AuthService>(),
        userRepository: Get.find<UserRepository>(),
        postRepository: Get.find<PostRepository>(),
        placeRepository: Get.find<PlaceRepository>(),
        achievementRepository: Get.find<AchievementRepository>(),
      ),
      fenix: true,
    );
  }
}
