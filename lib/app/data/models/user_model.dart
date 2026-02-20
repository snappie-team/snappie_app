import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@collection
@JsonSerializable(explicitToJson: true)
class UserModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? id;

  String? name;
  String? username;
  String? email;

  @JsonKey(name: 'image_url')
  String? imageUrl;

  @JsonKey(name: 'total_coin')
  int? totalCoin;
  @JsonKey(name: 'total_exp')
  int? totalExp;
  @JsonKey(name: 'total_following')
  int? totalFollowing;
  @JsonKey(name: 'total_follower')
  int? totalFollower;
  @JsonKey(name: 'total_checkin')
  int? totalCheckin;
  @JsonKey(name: 'total_post')
  int? totalPost;
  @JsonKey(name: 'total_article')
  int? totalArticle;
  @JsonKey(name: 'total_review')
  int? totalReview;
  @JsonKey(name: 'total_achievement')
  int? totalAchievement;
  @JsonKey(name: 'total_challenge')
  int? totalChallenge;

  bool? status;

  @JsonKey(name: 'last_login_at')
  DateTime? lastLoginAt;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  @JsonKey(name: 'user_detail')
  UserDetail? userDetail;

  @JsonKey(name: 'user_preferences')
  UserPreferences? userPreferences;

  @JsonKey(name: 'user_saved')
  UserSaved? userSaved;

  @JsonKey(name: 'user_settings')
  UserSettings? userSettings;

  @JsonKey(name: 'user_notification')
  UserNotification? userNotification;

  UserModel();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

/* ===== Embedded structs ===== */

@JsonSerializable()
@embedded
class UserDetail {
  String? bio;
  String? gender;
  @JsonKey(name: 'date_of_birth')
  String? dateOfBirth;
  String? phone;

  UserDetail();
  factory UserDetail.fromJson(Map<String, dynamic> json) =>
      _$UserDetailFromJson(json);
  Map<String, dynamic> toJson() => _$UserDetailToJson(this);
}

@JsonSerializable()
@embedded
class UserPreferences {
  @JsonKey(name: 'food_type')
  List<String>? foodType;

  @JsonKey(name: 'place_value')
  List<String>? placeValue;

  UserPreferences();

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

@JsonSerializable()
@embedded
class UserSaved {
  @JsonKey(name: 'saved_places')
  List<SavedPlacePreview>? savedPlaces;

  @JsonKey(name: 'saved_posts')
  List<SavedPostPreview>? savedPosts;

  @JsonKey(name: 'saved_articles')
  List<int>? savedArticles;

  UserSaved();

  factory UserSaved.fromJson(Map<String, dynamic> json) =>
      _$UserSavedFromJson(json);

  Map<String, dynamic> toJson() => _$UserSavedToJson(this);
}

/// Preview model for saved places (lightweight)
@JsonSerializable()
@embedded
class SavedPlacePreview {
  int? id;
  String? name;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'short_description')
  String? shortDescription;
  double? rating;

  SavedPlacePreview();

  factory SavedPlacePreview.fromJson(Map<String, dynamic> json) =>
      _$SavedPlacePreviewFromJson(json);
  Map<String, dynamic> toJson() => _$SavedPlacePreviewToJson(this);
}

/// Preview model for saved posts (lightweight)
@JsonSerializable()
@embedded
class SavedPostPreview {
  int? id;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'content_preview')
  String? contentPreview;
  @JsonKey(name: 'user_name')
  String? userName;
  @JsonKey(name: 'like_count')
  int? likeCount;

  SavedPostPreview();

  factory SavedPostPreview.fromJson(Map<String, dynamic> json) =>
      _$SavedPostPreviewFromJson(json);
  Map<String, dynamic> toJson() => _$SavedPostPreviewToJson(this);
}

@JsonSerializable()
@embedded
class UserSettings {
  String? language;
  String? theme;

  @JsonKey(name: 'frame_url')
  String? frameUrl;

  UserSettings();
  factory UserSettings.fromJson(Map<String, dynamic> json) =>
      _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);
}

@JsonSerializable()
@embedded
class UserNotification {
  @JsonKey(name: 'push_notification')
  bool? pushNotification;

  UserNotification();
  factory UserNotification.fromJson(Map<String, dynamic> json) =>
      _$UserNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$UserNotificationToJson(this);
}

/// User search result model
@JsonSerializable()
class UserSearchItem {
  int? id;
  String? name;
  String? username;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'total_follower')
  int? totalFollower;
  @JsonKey(name: 'total_following')
  int? totalFollowing;
  @JsonKey(name: 'is_followed')
  bool? isFollowed;

  UserSearchItem();
  factory UserSearchItem.fromJson(Map<String, dynamic> json) =>
      _$UserSearchItemFromJson(json);
  Map<String, dynamic> toJson() => _$UserSearchItemToJson(this);
}

/// Paginated user search result
@JsonSerializable()
class UserSearchResult {
  List<UserSearchItem>? users;
  SearchPagination? pagination;

  UserSearchResult();
  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      _$UserSearchResultFromJson(json);
  Map<String, dynamic> toJson() => _$UserSearchResultToJson(this);
}

@JsonSerializable()
class SearchPagination {
  @JsonKey(name: 'current_page')
  int? currentPage;
  @JsonKey(name: 'per_page')
  int? perPage;
  @JsonKey(name: 'has_more')
  bool? hasMore;

  SearchPagination();
  factory SearchPagination.fromJson(Map<String, dynamic> json) =>
      _$SearchPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$SearchPaginationToJson(this);
}
