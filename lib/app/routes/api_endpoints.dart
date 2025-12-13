import '../core/constants/environment_config.dart';

class ApiEndpoints {
  // Base URLs - Now using EnvironmentConfig
  static String get baseUrl => EnvironmentConfig.baseUrl;
  static String get apiVersion => EnvironmentConfig.apiVersion;

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String refreshTokenFallback = '/auth/refresh-token';
  static const List<String> refreshTokenCandidates = <String>[
    refreshToken,
    refreshTokenFallback,
  ];
  static const String logout = '/auth/logout';

  // User endpoints
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String users = '/users';
  static const String usersSearch = '/users/search';
  static const String userById = '/users/id/{id}';
  static const String userSaved = '/users/saved';
  static const String userCheckins = '/users/id/{id}/checkins';
  static const String userReviews = '/users/id/{id}/reviews';
  static const String userRewards = '/users/id/{id}/rewards';
  static const String userPosts = '/users/id/{id}/posts';
  static const String userAchievements = '/users/id/{id}/achievements';
  static const String userChallenges = '/users/id/{id}/challenges';

  // Place endpoints
  static const String places = '/places';
  static const String placeDetail = '/places/id/{id}';
  static const String placeReviews = '/places/id/{id}/reviews';
  static const String placeCheckins = '/places/id/{id}/checkins';
  static const String placePosts = '/places/id/{id}/posts';

  // Checkin endpoints
  static const String createCheckin = '/gamification/checkin';
  static const String reviewPlace = '/gamification/review';
  static const String updateReview = '/gamification/review/{id}';
  static const String coinTransactions = '/gamification/coins/transactions';
  static const String expTransactions = '/gamification/exp/transactions';

  // Leaderboard endpoints
  static const String leaderboardWeekly = '/leaderboard/weekly';
  static const String leaderboardMonthly = '/leaderboard/monthly';

  // Articles endpoints
  static const String articles = '/articles';
  static const String articleDetail = '/articles/id/{id}';

  // Posts endpoints
  static const String posts = '/social/posts';
  static const String postDetail = '/social/posts/id/{id}';
  static const String postLike = '/social/posts/id/{post_id}/like';
  static const String postComment = '/social/posts/id/{post_id}/comment';

  // Social endpoints
  static const String socialFollow = '/social/follow';
  static const String socialFollowUser = '/social/follow/id/{user_id}';

  // Utility methods
  static String getFullUrl(String endpoint) => '$baseUrl$apiVersion$endpoint';
  static String replaceId(String endpoint, String id) =>
      endpoint.replaceAll('{id}', id);
}
