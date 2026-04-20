import 'package:get/get.dart';
import 'package:snappie_app/app/data/models/achievement_model.dart';
import 'package:snappie_app/app/data/models/articles_model.dart';
import 'package:snappie_app/app/data/models/checkin_model.dart';
import 'package:snappie_app/app/data/models/gamification_model.dart';
import 'package:snappie_app/app/data/models/gamification_response_model.dart';
import 'package:snappie_app/app/data/models/leaderboard_model.dart';
import 'package:snappie_app/app/data/models/like_model.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/data/models/post_model.dart';
import 'package:snappie_app/app/data/models/review_model.dart';
import 'package:snappie_app/app/data/models/reward_model.dart';
import 'package:snappie_app/app/data/models/social_model.dart';
import 'package:snappie_app/app/data/models/user_model.dart';
import 'package:snappie_app/app/data/repositories/achievement_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/articles_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/checkin_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/gamification_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/review_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/social_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';

import 'mock_data.dart';

class MockPostRepository implements PostRepository {
  bool _isLiked = false;
  int _likesCount = 10;
  bool shouldFailToggleLike = false;
  final List<PostModel> _createdPosts = <PostModel>[];

  PostModel _buildPostModel({required int postId}) {
    final post = PostModel()
      ..id = postId
      ..userId = 2
      ..placeId = 1
      ..content = 'Tempat ini amazing!'
      ..imageUrls = ['https://example.com/post1.jpg']
      ..likesCount = _likesCount
      ..commentsCount = 2
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    if (_isLiked) {
      final like = LikeModel()
        ..relatedToType = 'post'
        ..relatedToId = postId
        ..userId = MockData.testUser.id;
      post.likes = [like];
    } else {
      post.likes = <LikeModel>[];
    }

    final user = UserPost()
      ..id = 2
      ..name = 'Foodie'
      ..username = 'foodie';
    post.user = user;

    return post;
  }

  @override
  Future<List<PostModel>> getPosts({int page = 1, int perPage = 20}) async =>
      <PostModel>[
        ..._createdPosts.reversed,
        _buildPostModel(postId: 1),
      ];

  @override
  Future<PostModel> getPostById(int id) async {
    final existing = _createdPosts.where((post) => post.id == id);
    if (existing.isNotEmpty) {
      return existing.first;
    }
    return _buildPostModel(postId: id);
  }

  @override
  Future<List<PostModel>> getPostsByUserId(int userId,
          {int page = 1, int perPage = 20}) async =>
      MockData.testPosts;

  @override
  Future<List<PostModel>> getPostsByPlaceId(int placeId,
          {int page = 1, int perPage = 20}) async =>
      MockData.testPosts;

  @override
  Future<bool> toggleLikePost(int postId) async {
    if (shouldFailToggleLike) {
      throw Exception('Simulasi gagal toggle like');
    }

    _isLiked = !_isLiked;
    _likesCount += _isLiked ? 1 : -1;
    if (_likesCount < 0) _likesCount = 0;
    return _isLiked;
  }

  @override
  Future<PostModel> createPost({
    required int placeId,
    required String content,
    List<String>? imageUrls,
    List<String>? hashtags,
    String? locationDetails,
  }) async {
    final post = PostModel()
      ..id = 999
      ..placeId = placeId
      ..userId = MockData.testUser.id
      ..content = content
      ..imageUrls = imageUrls ?? <String>[]
      ..likesCount = 0
      ..commentsCount = 0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    _createdPosts.add(post);

    return post;
  }

  @override
  Future<PostModel> updatePost({
    required int postId,
    String? content,
    List<String>? imageUrls,
    int? placeId,
    List<String>? hashtags,
  }) async {
    final post = PostModel()
      ..id = postId
      ..placeId = placeId ?? MockData.testPlaces.first.id
      ..userId = MockData.testUser.id
      ..content = content ?? 'Updated post'
      ..imageUrls = imageUrls ?? <String>[]
      ..likesCount = 0
      ..commentsCount = 0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    final existingIndex = _createdPosts.indexWhere((item) => item.id == postId);
    if (existingIndex >= 0) {
      _createdPosts[existingIndex] = post;
    }

    return post;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSocialRepository implements SocialRepository {
  @override
  Future<SocialFollowData> getFollowData({int? userId}) async =>
      SocialFollowData(
        followers: <FollowEntry>[],
        following: <FollowEntry>[],
        totalFollowers: 0,
        totalFollowing: 0,
      );

  @override
  Future<void> followUser(int userId) async {}
}

class MockUserRepository implements UserRepository {
  final List<int> _savedPostIds = [1];

  void setSavedPostIds(List<int> ids) {
    _savedPostIds
      ..clear()
      ..addAll(ids);
  }

  @override
  Future<UserModel> getUserProfile() async => MockData.testUser;

  @override
  Future<UserSaved> getUserSaved() async {
    final base = MockData.testUserSaved;
    final savedPosts = _savedPostIds
        .map((id) => (SavedPostPreview()
          ..id = id
          ..contentPreview = 'Saved post $id'))
        .toList();

    return UserSaved()
      ..savedPlaces = base.savedPlaces
      ..savedArticles = base.savedArticles
      ..savedPosts = savedPosts;
  }

  @override
  Future<List<int>> toggleSavedPlace(List<int> placeIds) async => placeIds;

  @override
  Future<List<int>> toggleSavedPost(List<int> postIds) async {
    _savedPostIds
      ..clear()
      ..addAll(postIds);
    return List<int>.from(_savedPostIds);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockPlaceRepository implements PlaceRepository {
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
    var places = MockData.testPlaces;

    if (search != null && search.trim().isNotEmpty) {
      final normalizedQuery = search.trim().toLowerCase();
      places = places
          .where((place) =>
              (place.name ?? '').toLowerCase().contains(normalizedQuery))
          .toList();
    }

    if (foodTypes != null && foodTypes.isNotEmpty) {
      places = places.where((place) {
        final placeFoodTypes = place.foodType ?? const <String>[];
        return placeFoodTypes.any(foodTypes.contains);
      }).toList();
    }

    if (placeValues != null && placeValues.isNotEmpty) {
      places = places.where((place) {
        final placeValueLabels = place.placeValue ?? const <String>[];
        return placeValueLabels.any(placeValues.contains);
      }).toList();
    }

    if (minRating != null) {
      places =
          places.where((place) => (place.avgRating ?? 0) >= minRating).toList();
    }

    if (partner == true) {
      places = places
          .where((place) => (place.partnershipStatus ?? false) == true)
          .toList();
    }

    if (popular == true) {
      places = List<PlaceModel>.from(places)
        ..sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
    }

    return places;
  }

  @override
  Future<PlaceModel> getPlaceById(int id) async => MockData.testPlaces.first;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockReviewRepository implements ReviewRepository {
  @override
  Future<ActionResponseWithGamification<ReviewModel>> createReview({
    required int placeId,
    required String content,
    required int rating,
    required Map<String, dynamic> additionalInfo,
    List<String>? imageUrls,
  }) async {
    final review = ReviewModel()
      ..id = 1
      ..placeId = placeId
      ..userId = MockData.testUser.id
      ..content = content
      ..rating = rating
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return ActionResponseWithGamification<ReviewModel>(
      actionData: review,
      gamification: GamificationResult(
        rewards: GamificationRewards(
          xp: 30,
          coins: 15,
        ),
        achievementsUnlocked: const <AchievementSummary>[],
        challengesCompleted: const <ChallengeSummary>[],
      ),
    );
  }

  @override
  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? content,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final review = ReviewModel()
      ..id = reviewId
      ..placeId = MockData.testPlaces.first.id
      ..userId = MockData.testUser.id
      ..content = content ?? 'Updated review'
      ..rating = rating ?? 4
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return review;
  }

  @override
  Future<List<ReviewModel>> getPlaceReviews(int placeId) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCheckinRepository implements CheckinRepository {
  @override
  Future<ActionResponseWithGamification<CheckinModel>> createCheckin({
    required int placeId,
    required double latitude,
    required double longitude,
    String? imageUrl,
    Map<String, dynamic>? additionalInfo,
  }) async {
    final checkin = CheckinModel()
      ..id = 1
      ..placeId = placeId
      ..userId = 1
      ..latitude = latitude
      ..longitude = longitude
      ..imageUrl = imageUrl
      ..status = true
      ..isAnonymous = (additionalInfo?['is_anonymous'] as bool?) ?? false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return ActionResponseWithGamification<CheckinModel>(
      actionData: checkin,
      gamification: GamificationResult(
        rewards: GamificationRewards(
          xp: 50,
          coins: 25,
        ),
        achievementsUnlocked: const <AchievementSummary>[],
        challengesCompleted: const <ChallengeSummary>[],
      ),
    );
  }

  @override
  Future<List<CheckinModel>> getCheckinsByPlaceId(int placeId,
          {int page = 1, int perPage = 20}) async =>
      [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockArticlesRepository implements ArticlesRepository {
  @override
  Future<List<ArticlesModel>> getArticles({int page = 1}) async =>
      MockData.testArticles;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAchievementRepository implements AchievementRepository {
  final List<UserAchievement> _userAchievements = <UserAchievement>[];
  final List<UserAchievement> _userChallenges = <UserAchievement>[];
  final List<UserReward> _availableRewards = <UserReward>[];
  final Map<int, Map<String, dynamic>> _useRewardResponses =
      <int, Map<String, dynamic>>{};

  int _claimRewardCoins = 0;
  int _claimRewardXp = 0;
  int _nextUserRewardId = 1000;

  void setUserAchievements(List<UserAchievement> achievements) {
    _userAchievements
      ..clear()
      ..addAll(achievements);
  }

  void setUserChallenges(List<UserAchievement> challenges) {
    _userChallenges
      ..clear()
      ..addAll(challenges);
  }

  void setClaimRewards({required int coins, required int xp}) {
    _claimRewardCoins = coins;
    _claimRewardXp = xp;
  }

  void setAvailableRewards(List<UserReward> rewards) {
    _availableRewards
      ..clear()
      ..addAll(rewards);
  }

  void setUseRewardResponse(int userRewardId, Map<String, dynamic> response) {
    _useRewardResponses[userRewardId] = Map<String, dynamic>.from(response);
  }

  @override
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async =>
      MockData.weeklyLeaderboard;

  @override
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async =>
      MockData.monthlyLeaderboard;

  @override
  Future<List<UserAchievement>> getUserAchievements({int? userId}) async =>
      List<UserAchievement>.from(_userAchievements);

  @override
  Future<List<UserAchievement>> getUserChallenges() async =>
      List<UserAchievement>.from(_userChallenges);

  @override
  Future<List<UserReward>> getAvailableRewards() async =>
      List<UserReward>.from(_availableRewards);

  @override
  Future<ClaimChallengeResponse> claimChallenge(int challengeId) async {
    return ClaimChallengeResponse()
      ..challenge = (ClaimChallengeInfo()
        ..id = challengeId
        ..name = 'Challenge #$challengeId'
        ..rewardCoins = _claimRewardCoins
        ..rewardXp = _claimRewardXp)
      ..userStats = (ClaimUserStats()
        ..totalCoin = MockData.testUser.totalCoin
        ..totalExp = MockData.testUser.totalExp);
  }

  @override
  Future<UserReward> redeemReward(int rewardId) async {
    final index =
        _availableRewards.indexWhere((reward) => reward.id == rewardId);
    if (index < 0) {
      throw Exception('Reward tidak ditemukan');
    }

    final original = _availableRewards[index];
    final userRewardId = _nextUserRewardId++;

    final updated = UserReward()
      ..id = userRewardId
      ..rewardId = original.id
      ..name = original.name
      ..description = original.description
      ..imageUrl = original.imageUrl
      ..coinRequirement = original.coinRequirement
      ..stock = original.stock
      ..status = original.status
      ..additionalInfo = original.additionalInfo
      ..canRedeem = false
      ..userRewardId = userRewardId
      ..isRedeemed = true
      ..isUsed = false
      ..isExpired = false;

    _availableRewards[index] = UserReward()
      ..id = original.id
      ..rewardId = original.rewardId
      ..name = original.name
      ..description = original.description
      ..imageUrl = original.imageUrl
      ..coinRequirement = original.coinRequirement
      ..stock = original.stock
      ..status = original.status
      ..additionalInfo = original.additionalInfo
      ..canRedeem = false
      ..userRewardId = userRewardId
      ..isRedeemed = true
      ..isUsed = false
      ..isExpired = false;

    return updated;
  }

  @override
  Future<Map<String, dynamic>> useReward(int userRewardId) async {
    final response = _useRewardResponses[userRewardId] ??
        <String, dynamic>{
          'redemption_code': 'SNAP-${userRewardId.toString().padLeft(4, '0')}',
          'expires_at':
              DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        };

    final index = _availableRewards.indexWhere(
      (reward) => reward.userRewardId == userRewardId,
    );

    if (index >= 0) {
      final original = _availableRewards[index];
      _availableRewards[index] = UserReward()
        ..id = original.id
        ..rewardId = original.rewardId
        ..name = original.name
        ..description = original.description
        ..imageUrl = original.imageUrl
        ..coinRequirement = original.coinRequirement
        ..stock = original.stock
        ..status = original.status
        ..additionalInfo = original.additionalInfo
        ..canRedeem = false
        ..userRewardId = original.userRewardId
        ..isRedeemed = true
        ..isUsed = true
        ..isExpired = false
        ..redemptionCode = response['redemption_code'] as String?
        ..expiresAt = response['expires_at'] as String?;
    }

    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockGamificationRepository implements GamificationRepository {
  final List<CoinTransaction> _coinTransactions = <CoinTransaction>[];

  void setCoinTransactions(List<CoinTransaction> transactions) {
    _coinTransactions
      ..clear()
      ..addAll(transactions);
  }

  @override
  Future<List<ExpTransaction>> getExpTransactions({String? period}) async =>
      <ExpTransaction>[];

  @override
  Future<List<CoinTransaction>> getCoinTransactions({String? period}) async =>
      List<CoinTransaction>.from(_coinTransactions);

  @override
  Future<PlaceGamificationStatus> getPlaceStatus(
          {required int placeId}) async =>
      PlaceGamificationStatus(
        placeId: placeId,
        hasCheckinThisMonth: false,
        hasReviewThisMonth: false,
        canCheckin: true,
        canReview: true,
        canSubmitAppReview: true,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

late MockPostRepository mockPostRepository;
late MockSocialRepository mockSocialRepository;
late MockUserRepository mockUserRepository;
late MockPlaceRepository mockPlaceRepository;
late MockReviewRepository mockReviewRepository;
late MockCheckinRepository mockCheckinRepository;
late MockArticlesRepository mockArticlesRepository;
late MockAchievementRepository mockAchievementRepository;
late MockGamificationRepository mockGamificationRepository;

void registerMockRepositories() {
  mockPostRepository = MockPostRepository();

  mockSocialRepository = MockSocialRepository();

  mockUserRepository = MockUserRepository();

  mockPlaceRepository = MockPlaceRepository();

  mockReviewRepository = MockReviewRepository();

  mockCheckinRepository = MockCheckinRepository();

  mockArticlesRepository = MockArticlesRepository();

  mockAchievementRepository = MockAchievementRepository();

  mockGamificationRepository = MockGamificationRepository();

  Get.put<PostRepository>(mockPostRepository, permanent: true);
  Get.put<SocialRepository>(mockSocialRepository, permanent: true);
  Get.put<UserRepository>(mockUserRepository, permanent: true);
  Get.put<PlaceRepository>(mockPlaceRepository, permanent: true);
  Get.put<ReviewRepository>(mockReviewRepository, permanent: true);
  Get.put<CheckinRepository>(mockCheckinRepository, permanent: true);
  Get.put<ArticlesRepository>(mockArticlesRepository, permanent: true);
  Get.put<AchievementRepository>(mockAchievementRepository, permanent: true);
  Get.put<GamificationRepository>(mockGamificationRepository, permanent: true);
}
