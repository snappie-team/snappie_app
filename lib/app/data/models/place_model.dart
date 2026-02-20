import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'place_model.g.dart';

@collection
@JsonSerializable(explicitToJson: true)
class PlaceModel {
  @JsonKey(includeFromJson: false, includeToJson: false)
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  int? id;

  String? name;
  String? description;

  double? longitude;
  double? latitude;

  @JsonKey(
      name: 'image_urls',
      fromJson: _placeImagesFromJson,
      toJson: _placeImagesToJson)
  List<PlaceImage>? imageUrls;

  @JsonKey(name: 'coin_reward')       int? coinReward;
  @JsonKey(name: 'exp_reward')        int? expReward;
  @JsonKey(name: 'min_price')         double? minPrice;
  @JsonKey(name: 'max_price')         double? maxPrice;
  @JsonKey(name: 'avg_rating')        double? avgRating;
  @JsonKey(name: 'total_review')      int? totalReview;
  @JsonKey(name: 'total_checkin')     int? totalCheckin;

  bool? status;

  @JsonKey(name: 'partnership_status')
  bool? partnershipStatus;

  @JsonKey(name: 'place_detail')
  PlaceDetail? placeDetail;

  @JsonKey(name: 'place_value')
  List<String>? placeValue;

  @JsonKey(name: 'food_type')
  List<String>? foodType;

  @JsonKey(name: 'menu_image_url')
  String? menuImageUrl;

  List<MenuItem>? menu;

  @JsonKey(name: 'place_attributes')
  PlaceAttributes? placeAttributes;

  @JsonKey(name: 'created_at')
  DateTime? createdAt;

  @JsonKey(name: 'updated_at')
  DateTime? updatedAt;

  PlaceModel();

  factory PlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceModelToJson(this);
}

@JsonSerializable()
@embedded
class PlaceDetail {
  @JsonKey(name: 'short_description')
  String? shortDescription;

  String? address;

  @JsonKey(name: 'opening_hours')
  String? openingHours;
  @JsonKey(name: 'closing_hours')
  String? closingHours;

  @JsonKey(name: 'opening_days')
  List<String>? openingDays;

  @JsonKey(name: 'contact_number')
  String? contactNumber;

  String? website;

  PlaceDetail();

  factory PlaceDetail.fromJson(Map<String, dynamic> json) =>
      _$PlaceDetailFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
@embedded
class PlaceAttributes {
  List<Facility>? facility;
  List<Parking>? parking;
  List<Payment>? payment;
  List<Service>? service;
  List<Capacity>? capacity;
  List<Accessibility>? accessibility;

  PlaceAttributes();

  factory PlaceAttributes.fromJson(Map<String, dynamic> json) =>
      _$PlaceAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceAttributesToJson(this);
}

@JsonSerializable()
@embedded
class MenuItem {
  String? name;
  @JsonKey(name: 'image_url')
  String? imageUrl;

  double? price;

  String? description;

  MenuItem();

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);
}

@JsonSerializable()
@embedded
class Facility {
  String? name;
  String? description;

  Facility();

  factory Facility.fromJson(Map<String, dynamic> json) =>
      _$FacilityFromJson(json);
  Map<String, dynamic> toJson() => _$FacilityToJson(this);
}

@JsonSerializable()
@embedded
class Parking {
  String? name;
  String? description;

  Parking();

  factory Parking.fromJson(Map<String, dynamic> json) =>
      _$ParkingFromJson(json);
  Map<String, dynamic> toJson() => _$ParkingToJson(this);
}

@JsonSerializable()
@embedded
class Payment {
  String? name;
  String? description;

  Payment();

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}

@JsonSerializable()
@embedded
class Service {
  String? name;
  String? description;

  Service();

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}

@JsonSerializable()
@embedded
class Capacity {
  String? name;
  String? description;

  Capacity();

  factory Capacity.fromJson(Map<String, dynamic> json) =>
      _$CapacityFromJson(json);
  Map<String, dynamic> toJson() => _$CapacityToJson(this);
}

@JsonSerializable()
@embedded
class Accessibility {
  String? name;
  String? description;

  Accessibility();

  factory Accessibility.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityFromJson(json);
  Map<String, dynamic> toJson() => _$AccessibilityToJson(this);
}

@JsonSerializable()
@embedded
class PlaceImage {
  String? url;
  String? description;

  PlaceImage();

  factory PlaceImage.fromJson(Map<String, dynamic> json) =>
      _$PlaceImageFromJson(json);
  Map<String, dynamic> toJson() => _$PlaceImageToJson(this);
}

/// Custom converter for image_urls that handles both formats:
/// - Legacy: ["url1", "url2"] (plain strings from current backend)
/// - New: [{"url": "url1", "description": "desc1"}, ...] (objects)
List<PlaceImage>? _placeImagesFromJson(dynamic json) {
  if (json == null) return null;
  if (json is! List) return null;
  return json.map((item) {
    if (item is String) {
      // Legacy format: plain URL string
      return PlaceImage()..url = item;
    } else if (item is Map<String, dynamic>) {
      // New format: {url, description} object
      return PlaceImage.fromJson(item);
    }
    return PlaceImage();
  }).toList();
}

List<Map<String, dynamic>>? _placeImagesToJson(List<PlaceImage>? images) {
  return images?.map((e) => e.toJson()).toList();
}
