import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_model.g.dart';

/// Leaderboard entry model
@JsonSerializable()
class LeaderboardEntry {
  int? rank;
  @JsonKey(name: 'user_id')
  int? userId;
  String? name;
  String? username;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'total_exp')
  int? totalExp;
  @JsonKey(name: 'total_checkin')
  int? totalCheckin;
  String? period;

  LeaderboardEntry();

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LeaderboardEntryToJson(this);
}