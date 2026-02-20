import 'package:get/get.dart';
import 'logger_service.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../data/models/gamification_response_model.dart';
import '../../modules/shared/widgets/index.dart';
import '../helpers/app_snackbar.dart';

/// Centralized service for handling gamification results
/// Manages achievement popups and challenge updates
class GamificationHandlerService {
  /// Handle gamification result from API response
  ///
  /// - Shows achievement popups sequentially for unlocked achievements
  /// - Updates challenges silently in background
  /// - Updates user stats (coins & XP)
  static Future<void> handleGamificationResult(
    GamificationResult gamification,
  ) async {
    try {
      Logger.debug('Processing gamification result...', 'GamificationHandler');

      // 1. Update user stats first
      await _updateUserStats(gamification.rewards);

      // 2. Show achievement popups (sequential)
      if (gamification.hasAchievementsToShow) {
        await _showAchievementPopups(gamification.achievementsToShow);
      }

      // 3. Handle challenge updates (silent, non-blocking)
      if (gamification.hasChallengesCompleted) {
        _handleChallengeUpdates(gamification.challengesCompleted!);
      }

      Logger.debug('Processing complete', 'GamificationHandler');
    } catch (e) {
      Logger.error(
          'Error processing gamification', e, null, 'GamificationHandler');
      // Don't throw - gamification errors should not break user flow
    }
  }

  /// Show achievement popups sequentially
  static Future<void> _showAchievementPopups(
    List<AchievementSummary> achievements,
  ) async {
    Logger.debug('Showing ${achievements.length} achievement popups',
        'GamificationHandler');

    for (var i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      Logger.debug(
          'Showing achievement: ${achievement.name}', 'GamificationHandler');

      // Show popup
      await Get.dialog(
        AchievementPopupWidget(achievement: achievement),
        barrierDismissible: true,
      );

      // Delay between popups (except after last one)
      if (i < achievements.length - 1) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  /// Handle challenge updates — shows toast for completed challenges
  static void _handleChallengeUpdates(
    List<ChallengeSummary> challenges,
  ) {
    final completed = challenges.where((c) => c.isCompleted).toList();
    Logger.debug('Processing ${completed.length} completed challenges',
        'GamificationHandler');

    if (completed.isNotEmpty) {
      try {
        // Update badge counter
        final profileController = Get.find<ProfileController>();
        profileController.incrementCompletedChallenges(completed.length);

        // Refresh challenges data in background (non-blocking)
        profileController.loadChallenges();

        // Show toast for each completed challenge
        for (final challenge in completed) {
          final rewardParts = <String>[];
          if (challenge.rewardCoins != null && challenge.rewardCoins! > 0) {
            rewardParts.add('+${challenge.rewardCoins} Koin');
          }
          if (challenge.rewardXp != null && challenge.rewardXp! > 0) {
            rewardParts.add('+${challenge.rewardXp} XP');
          }
          AppSnackbar.challengeCompleted(
            challenge.name ?? 'Challenge',
            rewardText: rewardParts.isNotEmpty ? rewardParts.join(' | ') : null,
          );
        }
      } catch (e) {
        Logger.error(
            'Error updating challenges', e, null, 'GamificationHandler');
      }
    }
  }

  /// Update user stats (coins and XP)
  static Future<void> _updateUserStats(
    GamificationRewards? rewards,
  ) async {
    if (rewards == null) return;

    try {
      final profileController = Get.find<ProfileController>();

      if (rewards.coins != null && rewards.coins! > 0) {
        Logger.debug('Adding ${rewards.coins} coins', 'GamificationHandler');
        await profileController.addCoins(rewards.coins!);
      }

      if (rewards.xp != null && rewards.xp! > 0) {
        Logger.debug('Adding ${rewards.xp} XP', 'GamificationHandler');
        await profileController.addExp(rewards.xp!);
      }
    } catch (e) {
      Logger.error('Error updating user stats', e, null, 'GamificationHandler');
    }
  }
}
