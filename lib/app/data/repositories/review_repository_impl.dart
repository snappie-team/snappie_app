import 'package:snappie_app/app/data/models/review_model.dart';
import 'package:snappie_app/app/data/models/gamification_response_model.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote/review_remote_datasource.dart';

/// Review Repository - No domain layer, direct Model return
/// Throws exceptions instead of returning Either<Failure, T>
///
/// Note: ReviewModel needs to be created if it doesn't exist
class ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReviewRepository({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Create a new review
  /// Returns ActionResponseWithGamification to include gamification data
  /// Throws: [ServerException], [NetworkException], [AuthenticationException]
  Future<ActionResponseWithGamification<ReviewModel>> createReview({
    required int placeId,
    required String content,
    required int rating,
    required Map<String, dynamic> additionalInfo,
    List<String>? imageUrls,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.createReview(
      placeId: placeId,
      content: content,
      rating: rating,
      additionalInfo: additionalInfo,
      imageUrls: imageUrls,
    );
  }

  /// Update an existing review
  /// Throws: [ServerException], [NetworkException], [AuthenticationException]
  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? content,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalInfo,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.updateReview(
      reviewId: reviewId,
      rating: rating,
      content: content,
      imageUrls: imageUrls,
      additionalInfo: additionalInfo,
    );
  }

  /// Get place reviews by place ID
  /// Throws: [ServerException], [NetworkException]
  Future<List<ReviewModel>> getPlaceReviews(int placeId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    final reviews = await remoteDataSource.getPlaceReviews(placeId);

    return reviews;
  }
}
