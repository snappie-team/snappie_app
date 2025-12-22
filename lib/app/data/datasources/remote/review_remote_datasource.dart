import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import '../../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  Future<ReviewModel> createReview({
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
  Future<ReviewModel> createReview({
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

      final response = await dioClient.dio.post(
        ApiEndpoints.reviewPlace,
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

