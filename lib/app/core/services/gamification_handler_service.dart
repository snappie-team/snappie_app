import 'package:get/get.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../data/models/gamification_response_model.dart';
import '../../modules/shared/widgets/index.dart';

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
      print('[GamificationHandler] Processing gamification result...');
      
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
      
      print('[GamificationHandler] Processing complete');
    } catch (e) {
      print('[GamificationHandler] Error processing gamification: $e');
      // Don't throw - gamification errors should not break user flow
    }
  }

  /// Show achievement popups sequentially
  static Future<void> _showAchievementPopups(
    List<AchievementSummary> achievements,
  ) async {
    print('[GamificationHandler] Showing ${achievements.length} achievement popups');
    
    for (var i = 0; i < achievements.length; i++) {
      final achievement = achievements[i];
      print('[GamificationHandler] Showing achievement: ${achievement.name}');
      
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

  /// Handle challenge updates silently
  static void _handleChallengeUpdates(
    List<ChallengeSummary> challenges,
  ) {
    final completedCount = challenges.where((c) => c.isCompleted).length;
    print('[GamificationHandler] Processing $completedCount completed challenges');
    
    if (completedCount > 0) {
      try {
        // Update badge counter
        final profileController = Get.find<ProfileController>();
        profileController.incrementCompletedChallenges(completedCount);
        
        // Refresh challenges data in background (non-blocking)
        profileController.loadChallenges();
      } catch (e) {
        print('[GamificationHandler] Error updating challenges: $e');
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
        print('[GamificationHandler] Adding ${rewards.coins} coins');
        await profileController.addCoins(rewards.coins!);
      }
      
      if (rewards.xp != null && rewards.xp! > 0) {
        print('[GamificationHandler] Adding ${rewards.xp} XP');
        await profileController.addExp(rewards.xp!);
      }
    } catch (e) {
      print('[GamificationHandler] Error updating user stats: $e');
    }
  }
}
