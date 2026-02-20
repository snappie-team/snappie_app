import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import '../../../core/services/logger_service.dart';
import '../../models/review_model.dart';
import '../../models/gamification_response_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ActionResponseWithGamification<ReviewModel>> createReview({
    required int placeId,
    required String content,
    required int rating,
    required Map<String, dynamic> additionalInfo,
    List<String>? imageUrls,
  });

  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? content,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalInfo,
  });

  Future<List<ReviewModel>> getPlaceReviews(int placeId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final DioClient dioClient;

  ReviewRemoteDataSourceImpl(this.dioClient);

  @override
  Future<ActionResponseWithGamification<ReviewModel>> createReview({
    required int placeId,
    required String content,
    required int rating,
    required Map<String, dynamic> additionalInfo,
    List<String>? imageUrls,
  }) async {
    try {
      final payload = <String, dynamic>{
        'place_id': placeId,
        'content': content,
        'rating': rating,
        'additional_info': additionalInfo,
      };

      if (imageUrls != null && imageUrls.isNotEmpty) {
        payload['image_urls'] = imageUrls;
      }

      Logger.debug(
        'createReview payload: placeId=$placeId, content=$content, rating=$rating, images=${imageUrls?.length ?? 0}, additionalKeys=${additionalInfo.keys.toList()}',
        'ReviewRemoteDataSource',
      );

      final response = await dioClient.dio.post(
        ApiEndpoints.reviewPlace,
        data: payload,
      );

      Logger.debug(
        'createReview response: status=${response.statusCode}, data=${response.data}',
        'ReviewRemoteDataSource',
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;

        // Parse review data (may be nested under 'review' key)
        final reviewJson = data['review'] ?? data;
        final review = ReviewModel.fromJson(reviewJson as Map<String, dynamic>);

        // Parse gamification data (optional)
        GamificationResult? gamification;
        if (data['gamification'] != null) {
          try {
            gamification = GamificationResult.fromJson(
              data['gamification'] as Map<String, dynamic>,
            );
            Logger.debug(
              'Gamification data found: achievements=${gamification.achievementsUnlocked?.length}, challenges=${gamification.challengesCompleted?.length}',
              'ReviewRemoteDataSource',
            );
          } catch (e) {
            Logger.warning('Failed to parse gamification data: $e', 'ReviewRemoteDataSource');
          }
        }

        return ActionResponseWithGamification<ReviewModel>(
          actionData: review,
          gamification: gamification,
        );
      }

      throw ServerException(
        responseData is Map ? responseData['message'] ?? 'Failed to create review' : 'Failed to create review',
        response.statusCode ?? 500,
      );
    } on ApiResponseException catch (e) {
      Logger.error('createReview api response error', e, null, 'ReviewRemoteDataSource');
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      Logger.error('createReview dio error', e, null, 'ReviewRemoteDataSource');
      throw _mapDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      Logger.error('createReview unexpected error', e, null, 'ReviewRemoteDataSource');
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<ReviewModel> updateReview({
    required int reviewId,
    int? rating,
    String? content,
    List<String>? imageUrls,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (rating != null) {
        payload['rating'] = rating;
      }
      if (content != null) {
        payload['content'] = content;
      }
      if (imageUrls != null) {
        payload['image_urls'] = imageUrls;
      }
      if (additionalInfo != null) {
        payload['additional_info'] = additionalInfo;
      }

      final response = await dioClient.dio.put(
        ApiEndpoints.replaceId(ApiEndpoints.updateReview, '$reviewId'),
        data: payload,
      );

      return extractApiResponseData<ReviewModel>(
        response,
        (json) => ReviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<List<ReviewModel>> getPlaceReviews(int placeId) async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.replaceId(ApiEndpoints.placeReviews, '$placeId'));

      return extractApiResponseListData<ReviewModel>(
        response,
        (json) => ReviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  Exception _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) return AuthenticationException('Authentication required');
    if (status == 403) return AuthorizationException('Access denied');
    if (status == 404) return ServerException('Not found', 404);
    if (status == 409) {
      final errorMsg = data is Map ? data['error'] ?? data['message'] ?? 'Conflict' : 'Conflict';
      return ConflictException(errorMsg.toString());
    }
    if (status == 422) {
      return ValidationException(
        data is Map ? (data['message'] ?? 'Validation failed') : 'Validation failed',
        errors: data is Map && data['errors'] is Map ? Map<String, dynamic>.from(data['errors']) : null,
      );
    }

    return ServerException(data is Map ? data['message'] ?? 'Network error occurred' : 'Network error occurred', status ?? 500);
  }
}

