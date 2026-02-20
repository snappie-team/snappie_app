import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:snappie_app/app/data/models/comment_model.dart';
import 'package:snappie_app/app/data/models/like_model.dart';

part 'post_model.g.dart';

@collection
@JsonSerializable()
class PostModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? id;

  @Index()
  @JsonKey(name: 'user_id')
  int? userId;
  @Index()
  @JsonKey(name: 'place_id')
  int? placeId;

  @JsonKey(name: 'image_urls')
  List<String>? imageUrls;

  String? content;

  @JsonKey(name: 'total_like')
  int? likesCount;

  @JsonKey(name: 'total_comment')
  int? commentsCount;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  bool? status;

  @JsonKey(name: 'user')
  UserPost? user;
  @JsonKey(name: 'place')
  PlacePost? place;
  @ignore
  @JsonKey(name: 'likes')
  List<LikeModel>? likes;
  @ignore
  @JsonKey(name: 'comments')
  List<CommentModel>? comments;

  PostModel();

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  PostModel copyWith({
    int? id,
    int? userId,
    int? placeId,
    List<String>? imageUrls,
    String? content,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? status,
    UserPost? user,
    PlacePost? place,
    List<LikeModel>? likes,
    List<CommentModel>? comments,
  }) {
    return PostModel()
      ..id = id ?? this.id
      ..userId = userId ?? this.userId
      ..placeId = placeId ?? this.placeId
      ..imageUrls = imageUrls ?? this.imageUrls
      ..content = content ?? this.content
      ..likesCount = likesCount ?? this.likesCount
      ..commentsCount = commentsCount ?? this.commentsCount
      ..createdAt = createdAt ?? this.createdAt
      ..updatedAt = updatedAt ?? this.updatedAt
      ..status = status ?? this.status
      ..user = user ?? this.user
      ..place = place ?? this.place
      ..likes = likes ?? this.likes
      ..comments = comments ?? this.comments;
  }
}

@JsonSerializable()
@embedded
class UserPost {
  int? id;
  String? name;
  String? username;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'frame_url')
  String? frameUrl;

  UserPost();

  factory UserPost.fromJson(Map<String, dynamic> json) =>
      _$UserPostFromJson(json);
  Map<String, dynamic> toJson() => _$UserPostToJson(this);
}

@JsonSerializable()
@embedded
class PlacePost {
  int? id;
  String? name;
  @JsonKey(name: 'image_urls', fromJson: _placePostImagesFromJson)
  List<String>? imageUrls;

  PlacePost();

  factory PlacePost.fromJson(Map<String, dynamic> json) =>
      _$PlacePostFromJson(json);
  Map<String, dynamic> toJson() => _$PlacePostToJson(this);
}

/// Handles both formats for place image_urls inside posts:
/// - Legacy: ["url1", "url2"] (plain strings)
/// - New: [{"url": "url1", "description": "desc"}, ...] (objects)
List<String>? _placePostImagesFromJson(dynamic json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map<String>((item) {
    if (item is String) return item;
    if (item is Map<String, dynamic>) return (item['url'] as String?) ?? '';
    return '';
  }).toList();
}
