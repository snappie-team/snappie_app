import 'package:json_annotation/json_annotation.dart';

part 'achievement_model.g.dart';

/// Enum for reset schedule types
enum ResetSchedule {
  @JsonValue('none')
  none('none', 'Sekali Saja'),
  @JsonValue('daily')
  daily('daily', 'Harian'),
  @JsonValue('weekly')
  weekly('weekly', 'Mingguan');

  final String value;
  final String label;

  const ResetSchedule(this.value, this.label);

  factory ResetSchedule.fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'daily':
        return ResetSchedule.daily;
      case 'weekly':
        return ResetSchedule.weekly;
      case 'none':
      default:
        return ResetSchedule.none;
    }
  }
}

// User Achievement model
@JsonSerializable()
class UserAchievement {
  int? id;
  String? code;
  String? name;
  String? subtitle;
  String? description;
  @JsonKey(name: 'icon_url')
  String? iconUrl;
  String? type;
  @JsonKey(name: 'reward_coins')
  int? rewardCoins;
  @JsonKey(name: 'reward_xp')
  int? rewardXp;
  @JsonKey(name: 'reset_schedule')
  String? resetSchedule;
  int? progress;
  int? target;
  int? percentage;
  @JsonKey(name: 'is_completed')
  bool? isCompleted;
  @JsonKey(name: 'completed_at')
  String? completedAt;
  @JsonKey(name: 'is_claimed')
  bool? isClaimed;
  @JsonKey(name: 'claimed_at')
  String? claimedAt;
  @JsonKey(name: 'user_achievement_id')
  int? userAchievementId;
  @JsonKey(name: 'criteria_action')
  String? criteriaAction;
  @JsonKey(name: 'criteria_target')
  int? criteriaTarget;
  @JsonKey(name: 'additional_info')
  Map<String, dynamic>? additionalInfo;

  UserAchievement();

  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      _$UserAchievementFromJson(json);
  Map<String, dynamic> toJson() => _$UserAchievementToJson(this);
}

/// Achievement model
@JsonSerializable()
class Achievement {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'achievement_id')
  int? achievementId;
  bool? status;
  @JsonKey(name: 'additional_info')
  AchievementAdditionalInfo? additionalInfo;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  Achievement();

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

/// Challenge model
@JsonSerializable()
class Challenge {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'challenge_id')
  int? challengeId;
  bool? status;
  @JsonKey(name: 'additional_info')
  AchievementAdditionalInfo? additionalInfo;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  Challenge();

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}

@JsonSerializable()
class AchievementAdditionalInfo {
  @JsonKey(name: 'unlocked_at')
  String? unlockedAt;
  String? progress;
  @JsonKey(name: 'current_count')
  int? currentCount;
  @JsonKey(name: 'target_count')
  int? targetCount;
  @JsonKey(name: 'criteria_type')
  String? criteriaType;
  @JsonKey(name: 'completed_at')
  String? completedAt;

  AchievementAdditionalInfo();

  factory AchievementAdditionalInfo.fromJson(Map<String, dynamic> json) =>
      _$AchievementAdditionalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementAdditionalInfoToJson(this);

  /// Calculate progress percentage
  double get progressPercent {
    if (targetCount == null || targetCount == 0) return 0;
    return ((currentCount ?? 0) / targetCount!) * 100;
  }
}

@JsonSerializable()
class PaginatedAchievements {
  List<Achievement>? items;
  int? total;
  @JsonKey(name: 'current_page')
  int? currentPage;
  @JsonKey(name: 'per_page')
  int? perPage;
  @JsonKey(name: 'last_page')
  int? lastPage;

  PaginatedAchievements();

  factory PaginatedAchievements.fromJson(Map<String, dynamic> json) =>
      _$PaginatedAchievementsFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedAchievementsToJson(this);
}

@JsonSerializable()
class PaginatedChallenges {
  List<Challenge>? items;
  int? total;
  @JsonKey(name: 'current_page')
  int? currentPage;
  @JsonKey(name: 'per_page')
  int? perPage;
  @JsonKey(name: 'last_page')
  int? lastPage;

  PaginatedChallenges();

  factory PaginatedChallenges.fromJson(Map<String, dynamic> json) =>
      _$PaginatedChallengesFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedChallengesToJson(this);
}

/// Response model untuk claim challenge
@JsonSerializable()
class ClaimChallengeResponse {
  ClaimChallengeInfo? challenge;
  @JsonKey(name: 'user_stats')
  ClaimUserStats? userStats;

  ClaimChallengeResponse();

  factory ClaimChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$ClaimChallengeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimChallengeResponseToJson(this);
}

@JsonSerializable()
class ClaimChallengeInfo {
  int? id;
  String? code;
  String? name;
  String? description;
  @JsonKey(name: 'icon_url')
  String? iconUrl;
  @JsonKey(name: 'reward_coins')
  int? rewardCoins;
  @JsonKey(name: 'reward_xp')
  int? rewardXp;

  ClaimChallengeInfo();

  factory ClaimChallengeInfo.fromJson(Map<String, dynamic> json) =>
      _$ClaimChallengeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimChallengeInfoToJson(this);
}

@JsonSerializable()
class ClaimUserStats {
  @JsonKey(name: 'total_coin')
  int? totalCoin;
  @JsonKey(name: 'total_exp')
  int? totalExp;
  @JsonKey(name: 'total_achievement')
  int? totalAchievement;
  @JsonKey(name: 'total_challenge')
  int? totalChallenge;

  ClaimUserStats();

  factory ClaimUserStats.fromJson(Map<String, dynamic> json) =>
      _$ClaimUserStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ClaimUserStatsToJson(this);
}
