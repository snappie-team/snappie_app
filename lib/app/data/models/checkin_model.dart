import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:snappie_app/app/data/models/post_model.dart';

part 'checkin_model.g.dart';

@collection
@JsonSerializable()
class CheckinModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? id;

  @Index() @JsonKey(name: 'user_id')  int? userId;
  @Index() @JsonKey(name: 'place_id') int? placeId;

  double? latitude;
  double? longitude;

  @JsonKey(name: 'image_url') String? imageUrl;
  bool? status;

  /// Flag anonim — sembunyikan username di galeri
  @JsonKey(
    name: 'is_anonymous',
    readValue: _readIsAnonymous,
  )
  bool? isAnonymous;

  /// User data dari API response (tidak disimpan di Isar)
  @ignore
  @JsonKey(name: 'user')
  UserPost? user;

  @JsonKey(name: 'created_at') DateTime? createdAt;
  @JsonKey(name: 'updated_at') DateTime? updatedAt;

  CheckinModel();
  factory CheckinModel.fromJson(Map<String, dynamic> json) =>
      _$CheckinModelFromJson(json);
  Map<String, dynamic> toJson() => _$CheckinModelToJson(this);
}

/// Extract is_anonymous: cek top-level dulu, fallback ke additional_info
Object? _readIsAnonymous(Map json, String key) {
  if (json[key] != null) return json[key];
  final info = json['additional_info'];
  if (info is Map) return info[key];
  return null;
}
