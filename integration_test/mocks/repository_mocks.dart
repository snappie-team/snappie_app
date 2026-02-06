import 'package:get/get.dart';
import 'package:snappie_app/app/data/repositories/achievement_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/checkin_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/gamification_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/review_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/social_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';
import 'package:snappie_app/app/data/models/user_model.dart';
import 'package:snappie_app/app/data/models/post_model.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/data/models/review_model.dart';
import 'package:snappie_app/app/data/models/checkin_model.dart';
import 'package:snappie_app/app/data/models/social_model.dart';
import 'package:snappie_app/app/data/models/gamification_model.dart';
import 'package:snappie_app/app/data/models/gamification_response_model.dart';
import 'package:snappie_app/app/data/models/comment_model.dart';
import 'package:snappie_app/app/data/models/leaderboard_model.dart';
import 'package:snappie_app/app/data/models/achievement_model.dart';
import 'package:snappie_app/app/data/models/reward_model.dart';

// ============================================================================
// Repository Mocks
// ============================================================================

class MockUserRepository extends GetxService implements UserRepository {
  @override
  Future<UserModel> getUserProfile() async {
    return UserModel()
      ..id = 1
      ..name = "Test User"
      ..username = "testuser"
      ..email = "test@example.com"
      ..totalCoin = 100
      ..totalExp = 1000;
  }

  @override
  Future<UserModel> getUserById(int id) async {
    return UserModel()
      ..id = id
      ..name = "User $id";
  }

  @override
  Future<UserModel> updateUserProfile({
    String? username,
    String? email,
    String? name,
    String? gender,
    String? imageUrl,
    List<String>? foodTypes,
    List<String>? placeValues,
    String? phone,
    DateTime? dateOfBirth,
    String? bio,
    Map<String, dynamic>? privacySettings,
    Map<String, dynamic>? notificationPreferences,
    Map<String, dynamic>? userSettings,
    Map<String, dynamic>? userNotification,
  }) async {
    return UserModel();
  }

  @override
  Future<UserSaved> getUserSaved() async {
    return UserSaved();
  }

  @override
  Future<List<int>> toggleSavedPlace(List<int> placeIds) async => placeIds;

  @override
  Future<List<int>> toggleSavedPost(List<int> postIds) async => postIds;

  @override
  Future<UserSearchResult> searchUsers(String query,
      {int page = 1, int perPage = 10}) async {
    return UserSearchResult();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPostRepository extends GetxService implements PostRepository {
  @override
  Future<List<PostModel>> getPosts(
      {int page = 1, bool trending = false, bool following = false}) async {
    return [];
  }

  @override
  Future<List<PostModel>> getPostsByUserId(int userId,
      {int page = 1, int perPage = 20}) async {
    return [];
  }

  @override
  Future<PostModel> createPost({
    required int placeId,
    required String content,
    List<String>? imageUrls,
    List<String>? hashtags,
    String? locationDetails,
  }) async {
    return PostModel();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPlaceRepository extends GetxService implements PlaceRepository {
  @override
  Future<List<PlaceModel>> getPlaces({
    List<String>? foodTypes,
    List<String>? placeValues,
    int perPage = 20,
    int page = 1,
    String? search,
    double? minRating,
    double? latitude,
    double? longitude,
    double? radius,
    bool? popular,
    bool? partner,
    bool? activeOnly,
  }) async {
    return [];
  }

  @override
  Future<PlaceModel> getPlaceById(int id) async {
    return PlaceModel()..id = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReviewRepository extends GetxService implements ReviewRepository {
  @override
  Future<ReviewModel> createReview({
    required int placeId,
    required String content,
    required int rating,
    required Map<String, dynamic> additionalInfo,
    List<String>? imageUrls,
  }) async {
    return ReviewModel();
  }

  @override
  Future<List<ReviewModel>> getPlaceReviews(int placeId) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCheckinRepository extends GetxService implements CheckinRepository {
  @override
  Future<ActionResponseWithGamification<CheckinModel>> createCheckin({
    required int placeId,
    required double latitude,
    required double longitude,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) async {
    return ActionResponseWithGamification(
      actionData: CheckinModel(),
      gamification: GamificationResult(),
    );
  }

  @override
  Future<List<CheckinModel>> getCheckinsByPlaceId(int placeId,
      {int page = 1, int perPage = 20}) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSocialRepository extends GetxService implements SocialRepository {
  @override
  Future<SocialFollowData> getFollowData() async {
    return SocialFollowData(followers: [], following: []);
  }

  @override
  Future<void> followUser(int userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGamificationRepository extends GetxService
    implements GamificationRepository {
  @override
  Future<List<ExpTransaction>> getExpTransactions({String? period}) async => [];

  @override
  Future<List<CoinTransaction>> getCoinTransactions({String? period}) async =>
      [];

  @override
  Future<PlaceGamificationStatus> getPlaceStatus({required int placeId}) async {
    return PlaceGamificationStatus(
        hasCheckinThisMonth: false, hasReviewThisMonth: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAchievementRepository extends GetxService
    implements AchievementRepository {
  @override
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async => [];

  @override
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async => [];

  @override
  Future<List<UserAchievement>> getUserAchievements() async => [];

  @override
  Future<List<UserAchievement>> getUserChallenges() async => [];

  @override
  Future<PaginatedUserRewards> getUserRewards(int userId,
      {int page = 1, int perPage = 10}) async {
    return PaginatedUserRewards()
      ..items = []
      ..currentPage = 1
      ..lastPage = 1
      ..perPage = 10
      ..total = 0;
  }

  @override
  Future<PaginatedAchievements> getAchievements(int userId,
      {int page = 1, int perPage = 10}) async {
    return PaginatedAchievements()
      ..items = []
      ..currentPage = 1
      ..lastPage = 1
      ..perPage = 10
      ..total = 0;
  }

  @override
  Future<PaginatedChallenges> getChallenges(int userId,
      {int page = 1, int perPage = 10}) async {
    return PaginatedChallenges()
      ..items = []
      ..currentPage = 1
      ..lastPage = 1
      ..perPage = 10
      ..total = 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
