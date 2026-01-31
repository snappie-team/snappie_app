import 'package:get/get.dart';
import 'package:snappie_app/app/data/repositories/gamification_repository_impl.dart';
import '../controllers/explore_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/place_repository_impl.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../data/repositories/checkin_repository_impl.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';

/// Binding untuk Explore module
/// Lazy load saat tab Explore dibuka
class ExploreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreController>(
      () => ExploreController(
        gamificationRepository: Get.find<GamificationRepository>(),
        placeRepository: Get.find<PlaceRepository>(),
        reviewRepository: Get.find<ReviewRepository>(),
        checkinRepository: Get.find<CheckinRepository>(),
        postRepository: Get.find<PostRepository>(),
        userRepository: Get.find<UserRepository>(),
        authService: Get.find<AuthService>(),
      ),
    );
  }
}
