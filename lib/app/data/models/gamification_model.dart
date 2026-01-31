import 'package:json_annotation/json_annotation.dart';

part 'gamification_model.g.dart';

/// XP Transaction model
@JsonSerializable()
class ExpTransaction {
  final int? id;
  
  @JsonKey(name: 'user_id')
  final int? userId;
  
  final int? amount;
  
  final String? type;
  
  final String? description;
  
  @JsonKey(name: 'reference_type')
  final String? referenceType;
  
  @JsonKey(name: 'reference_id')
  final int? referenceId;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  ExpTransaction({
    this.id,
    this.userId,
    this.amount,
    this.type,
    this.description,
    this.referenceType,
    this.referenceId,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpTransaction.fromJson(Map<String, dynamic> json) =>
      _$ExpTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$ExpTransactionToJson(this);
}

/// Coin Transaction metadata
@JsonSerializable()
class CoinTransactionMetadata {
  final String? type;
  final int? id;

  CoinTransactionMetadata({this.type, this.id});

  factory CoinTransactionMetadata.fromJson(Map<String, dynamic> json) =>
      _$CoinTransactionMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTransactionMetadataToJson(this);
}

/// Coin Transaction model
@JsonSerializable(explicitToJson: true)
class CoinTransaction {
  final int? id;
  
  @JsonKey(name: 'user_id')
  final int? userId;
  
  final int? amount;
  
  final CoinTransactionMetadata? metadata;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CoinTransaction({
    this.id,
    this.userId,
    this.amount,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getter to get type from metadata
  String? get type => metadata?.type;
  
  // Helper getter to get reference id from metadata
  int? get referenceId => metadata?.id;

  factory CoinTransaction.fromJson(Map<String, dynamic> json) =>
      _$CoinTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$CoinTransactionToJson(this);
}

/// Paginated response for transactions
@JsonSerializable(explicitToJson: true)
class PaginatedExpTransactions {
  final List<ExpTransaction>? items;
  final int? total;
  
  @JsonKey(name: 'current_page')
  final int? currentPage;
  
  @JsonKey(name: 'last_page')
  final int? lastPage;

  PaginatedExpTransactions({
    this.items,
    this.total,
    this.currentPage,
    this.lastPage,
  });

  factory PaginatedExpTransactions.fromJson(Map<String, dynamic> json) =>
      _$PaginatedExpTransactionsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedExpTransactionsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginatedCoinTransactions {
  final List<CoinTransaction>? items;
  final int? total;
  
  @JsonKey(name: 'current_page')
  final int? currentPage;
  
  @JsonKey(name: 'last_page')
  final int? lastPage;

  PaginatedCoinTransactions({
    this.items,
    this.total,
    this.currentPage,
    this.lastPage,
  });

  factory PaginatedCoinTransactions.fromJson(Map<String, dynamic> json) =>
      _$PaginatedCoinTransactionsFromJson(json);

  Map<String, dynamic> toJson() => _$PaginatedCoinTransactionsToJson(this);
}

@JsonSerializable()
class PlaceGamificationStatus {
  @JsonKey(name: 'place_id')
  final int? placeId;

  final String? month;

  @JsonKey(name: 'has_checkin_this_month')
  final bool? hasCheckinThisMonth;

  @JsonKey(name: 'has_review_this_month')
  final bool? hasReviewThisMonth;

  @JsonKey(name: 'app_review_submitted_this_month')
  final bool? appReviewSubmittedThisMonth;

  @JsonKey(name: 'review_id')
  final int? reviewId;

  @JsonKey(name: 'can_checkin')
  final bool? canCheckin;

  @JsonKey(name: 'can_review')
  final bool? canReview;

  @JsonKey(name: 'can_submit_app_review')
  final bool? canSubmitAppReview;

  PlaceGamificationStatus({
    this.placeId,
    this.month,
    this.hasCheckinThisMonth,
    this.hasReviewThisMonth,
    this.appReviewSubmittedThisMonth,
    this.reviewId,
    this.canCheckin,
    this.canReview,
    this.canSubmitAppReview,
  });

  factory PlaceGamificationStatus.fromJson(Map<String, dynamic> json) =>
      _$PlaceGamificationStatusFromJson(json);

  Map<String, dynamic> toJson() => _$PlaceGamificationStatusToJson(this);
}
