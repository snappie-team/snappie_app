import 'package:json_annotation/json_annotation.dart';

part 'reward_model.g.dart';

/// User reward model
@JsonSerializable()
class UserReward {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'reward_id')
  int? rewardId;
  bool? status;
  @JsonKey(name: 'additional_info')
  RewardAdditionalInfo? additionalInfo;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'updated_at')
  String? updatedAt;

  UserReward();

  factory UserReward.fromJson(Map<String, dynamic> json) =>
      _$UserRewardFromJson(json);
  Map<String, dynamic> toJson() => _$UserRewardToJson(this);
}

@JsonSerializable()
class RewardAdditionalInfo {
  @JsonKey(name: 'redemption_code')
  String? redemptionCode;
  @JsonKey(name: 'redeemed_at')
  String? redeemedAt;

  RewardAdditionalInfo();

  factory RewardAdditionalInfo.fromJson(Map<String, dynamic> json) =>
      _$RewardAdditionalInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RewardAdditionalInfoToJson(this);
}

/// Paginated response wrapper for achievements data
@JsonSerializable()
class PaginatedUserRewards {
  List<UserReward>? items;
  int? total;
  @JsonKey(name: 'current_page')
  int? currentPage;
  @JsonKey(name: 'per_page')
  int? perPage;
  @JsonKey(name: 'last_page')
  int? lastPage;

  PaginatedUserRewards();

  factory PaginatedUserRewards.fromJson(Map<String, dynamic> json) =>
      _$PaginatedUserRewardsFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedUserRewardsToJson(this);
}