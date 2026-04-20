import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'logger_service.dart';

/// Centralized wrapper around FirebaseAnalytics.
///
/// Registered as a permanent GetX service so every controller/service
/// can reach it with `Get.find<AnalyticsService>()`.
class AnalyticsService extends GetxService {
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver observer;

  /// Maps route names (from app_pages.dart) to research screen names.
  static const _routeToScreenName = <String, String>{
    '/main': 'catalog_home',
    '/place-detail': 'place_detail',
    '/reviews': 'place_detail',
    '/facilities': 'place_detail',
    '/gallery': 'place_detail',
    '/give-review': 'place_detail',
    '/mission-photo': 'quest_detail',
    '/mission-photo-preview': 'quest_detail',
    '/mission-review': 'quest_detail',
    '/leaderboard': 'leaderboard',
    '/achievements': 'badge_achievement',
    '/challenges': 'challenge_page',
    '/coins-history': 'coupon_page',
    '/profile': 'user_profile',
    '/user-profile': 'user_profile',
    '/edit-profile': 'user_profile',
    '/create-post': 'forum',
    '/post-detail': 'forum',
    '/post': 'forum',
    '/notifications': 'forum',
    '/onboarding': 'onboarding',
    '/login': 'login',
    '/register': 'register',
    '/settings': 'user_profile',
    '/saved-places': 'user_profile',
    '/saved-posts': 'user_profile',
  };

  @override
  void onInit() {
    super.onInit();
    _analytics = FirebaseAnalytics.instance;

    // Disable automatic screen reporting so Android Activity names
    // (MainActivity, SignInHubActivity) don't overwrite our custom names.
    _analytics.setAnalyticsCollectionEnabled(true);

    observer = FirebaseAnalyticsObserver(
      analytics: _analytics,
      nameExtractor: _screenNameExtractor,
    );
    Logger.info('AnalyticsService initialized', 'Analytics');
  }

  /// Extracts a screen name from the current route settings.
  /// Falls back to the route name itself if no mapping exists.
  String? _screenNameExtractor(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null) return null;
    return _routeToScreenName[routeName] ?? routeName;
  }

  // ──────────────────────────────────────────────
  // User identity
  // ──────────────────────────────────────────────

  /// Set the Firebase user ID (call after login/register).
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    Logger.debug('Analytics: setUserId → $userId', 'Analytics');
  }

  /// Clear user ID (call on logout).
  Future<void> clearUserId() async {
    await _analytics.setUserId(id: null);
    Logger.debug('Analytics: userId cleared', 'Analytics');
  }

  /// Set a user property for segmentation.
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
    Logger.debug('Analytics: setUserProperty $name → $value', 'Analytics');
  }

  // ──────────────────────────────────────────────
  // Screen tracking
  // ──────────────────────────────────────────────

  /// Manually log a screen_view event.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    Logger.debug('Analytics: screen_view → $screenName', 'Analytics');
  }

  // ──────────────────────────────────────────────
  // Custom events
  // ──────────────────────────────────────────────

  /// Generic event logger used by all custom-event helpers below.
  Future<void> _log(String name, Map<String, Object>? params) async {
    await _analytics.logEvent(name: name, parameters: params);
    Logger.debug('Analytics: logEvent → $name $params', 'Analytics');
  }

  // ── Mission / Quest events ──

  Future<void> logMissionStarted({
    required String placeId,
    required String placeName,
  }) =>
      _log('mission_started', {
        'place_id': placeId,
        'place_name': placeName,
        'timestamp': DateTime.now().toIso8601String(),
      });

  Future<void> logMissionCompleted({
    required String placeId,
    required String placeName,
    required String step,
  }) =>
      _log('mission_completed', {
        'place_id': placeId,
        'place_name': placeName,
        'step': step,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Challenge events ──

  Future<void> logChallengeCompleted({
    required String challengeId,
    required String challengeName,
  }) =>
      _log('challenge_completed', {
        'challenge_id': challengeId,
        'challenge_name': challengeName,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Achievement events ──

  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) =>
      _log('achievement_unlocked', {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Reward events ──

  Future<void> logRewardReceived({
    required String type,
    required int amount,
  }) =>
      _log('reward_received', {
        'reward_type': type,
        'amount': amount,
        'timestamp': DateTime.now().toIso8601String(),
      });

  Future<void> logCouponRedeemed({
    required String rewardId,
    required String rewardName,
    required int coinCost,
  }) =>
      _log('coupon_redeemed', {
        'reward_id': rewardId,
        'reward_name': rewardName,
        'coin_cost': coinCost,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Leaderboard events ──

  Future<void> logLeaderboardViewed({
    required String period,
  }) =>
      _log('leaderboard_viewed', {
        'period': period,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Forum events ──

  Future<void> logForumPostCreated({
    required String postId,
    required String placeId,
  }) =>
      _log('forum_post_created', {
        'post_id': postId,
        'place_id': placeId,
        'timestamp': DateTime.now().toIso8601String(),
      });

  // ── Place events ──

  Future<void> logPlaceFavorited({
    required String placeId,
    required String placeName,
    required bool isSaved,
  }) =>
      _log('place_favorited', {
        'place_id': placeId,
        'place_name': placeName,
        'is_saved': isSaved.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
}
