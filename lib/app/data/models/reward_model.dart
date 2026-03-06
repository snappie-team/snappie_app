import 'package:json_annotation/json_annotation.dart';

part 'reward_model.g.dart';

/// User reward model (also used for available rewards)
@JsonSerializable()
class UserReward {
  int? id;
  @JsonKey(name: 'user_id')
  int? userId;
  @JsonKey(name: 'reward_id')
  int? rewardId;
  String? name;
  String? description;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'coin_requirement')
  int? coinRequirement;
  int? stock;
  @JsonKey(name: 'can_redeem')
  bool? canRedeem;
  bool? status;
  @JsonKey(name: 'additional_info')
  RewardAdditionalInfo? additionalInfo;
  @JsonKey(name: 'user_reward_id')
  int? userRewardId;
  @JsonKey(name: 'is_redeemed')
  bool? isRedeemed;
  @JsonKey(name: 'is_used')
  bool? isUsed;
  @JsonKey(name: 'is_expired')
  bool? isExpired;
  @JsonKey(name: 'redemption_code')
  String? redemptionCode;
  @JsonKey(name: 'used_at')
  String? usedAt;
  @JsonKey(name: 'expires_at')
  String? expiresAt;
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
  String? deskripsi;
  @JsonKey(name: 'cara_pakai')
  List<String>? caraPakai;
  @JsonKey(name: 'syarat_ketentuan')
  List<String>? syaratKetentuan;

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
