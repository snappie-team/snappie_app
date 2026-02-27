import 'package:json_annotation/json_annotation.dart';

part 'gamification_response_model.g.dart';

/// Rewards container for gamification results
@JsonSerializable()
class GamificationRewards {
  final int? coins;
  final int? xp;

  GamificationRewards({
    this.coins,
    this.xp,
  });

  factory GamificationRewards.fromJson(Map<String, dynamic> json) =>
      _$GamificationRewardsFromJson(json);

  Map<String, dynamic> toJson() => _$GamificationRewardsToJson(this);
}

/// Summary of an achievement for popup display
@JsonSerializable()
class AchievementSummary {
  final int? id;
  final String? code;
  final String? name;
  final String? subtitle;
  final String? description;
  final String? type; // "achievement" or "challenge"
  final int? level; // For leveled achievements

  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  @JsonKey(name: 'criteria_action')
  final String? criteriaAction;

  @JsonKey(name: 'criteria_target')
  final int? criteriaTarget;

  @JsonKey(name: 'reward_coins')
  final int? rewardCoins;

  @JsonKey(name: 'reward_xp')
  final int? rewardXp;

  @JsonKey(name: 'completed_at')
  final String? completedAt;

  AchievementSummary({
    this.id,
    this.code,
    this.name,
    this.subtitle,
    this.description,
    this.type,
    this.level,
    this.iconUrl,
    this.criteriaAction,
    this.criteriaTarget,
    this.rewardCoins,
    this.rewardXp,
    this.completedAt,
  });

  factory AchievementSummary.fromJson(Map<String, dynamic> json) =>
      _$AchievementSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AchievementSummaryToJson(this);

  /// Check if this should show popup (only for type "achievement")
  bool get shouldShowPopup => type == 'achievement';

  /// Get display level text
  String get levelText => level != null ? 'Level $level' : '';

  /// Check if has rewards
  bool get hasRewards =>
      (rewardCoins != null && rewardCoins! > 0) ||
      (rewardXp != null && rewardXp! > 0);
}

/// Summary of a challenge for silent update
@JsonSerializable()
class ChallengeSummary {
  final int? id;
  final String? code;
  final String? name;
  final String? type; // Should be "challenge"
  final int? progress;
  final int? target;
  final int? percentage;

  @JsonKey(name: 'reward_coins')
  final int? rewardCoins;

  @JsonKey(name: 'reward_xp')
  final int? rewardXp;

  ChallengeSummary({
    this.id,
    this.code,
    this.name,
    this.type,
    this.progress,
    this.target,
    this.percentage,
    this.rewardCoins,
    this.rewardXp,
  });

  factory ChallengeSummary.fromJson(Map<String, dynamic> json) =>
      _$ChallengeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ChallengeSummaryToJson(this);

  /// Check if completed
  bool get isCompleted => percentage == 100;
}

/// Container for gamification results from API response
@JsonSerializable()
class GamificationResult {
  @JsonKey(name: 'achievements_unlocked')
  final List<AchievementSummary>? achievementsUnlocked;

  @JsonKey(name: 'challenges_completed')
  final List<ChallengeSummary>? challengesCompleted;

  final GamificationRewards? rewards;

  GamificationResult({
    this.achievementsUnlocked,
    this.challengesCompleted,
    this.rewards,
  });

  factory GamificationResult.fromJson(Map<String, dynamic> json) =>
      _$GamificationResultFromJson(json);

  Map<String, dynamic> toJson() => _$GamificationResultToJson(this);

  /// Check if there are any achievements to show popup
  bool get hasAchievementsToShow =>
      achievementsUnlocked != null &&
      achievementsUnlocked!.isNotEmpty &&
      achievementsUnlocked!.any((a) => a.shouldShowPopup);

  /// Check if there are any challenges that completed
  bool get hasChallengesCompleted =>
      challengesCompleted != null && challengesCompleted!.isNotEmpty;

  /// Get total rewards earned
  int get totalCoins => rewards?.coins ?? 0;
  int get totalXp => rewards?.xp ?? 0;

  /// Get all achievements that should show popup
  List<AchievementSummary> get achievementsToShow =>
      achievementsUnlocked?.where((a) => a.shouldShowPopup).toList() ?? [];
}

/// Generic wrapper for action responses with optional gamification data
class ActionResponseWithGamification<T> {
  final T actionData;
  final GamificationResult? gamification;

  ActionResponseWithGamification({
    required this.actionData,
    this.gamification,
  });

  /// Check if has gamification data
  bool get hasGamification => gamification != null;

  /// Check if should show achievement popup
  bool get shouldShowAchievementPopup =>
      gamification?.hasAchievementsToShow ?? false;

  /// Check if should update challenges silently
  bool get shouldUpdateChallenges =>
      gamification?.hasChallengesCompleted ?? false;
}
