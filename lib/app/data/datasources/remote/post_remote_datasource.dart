import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import 'package:snappie_app/app/core/helpers/json_mapping_helper.dart';
import '../../models/post_model.dart';
import '../../models/comment_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts({
    int? page,
    bool? trending,
    bool? following,
  });
  Future<PostModel> getPostById(int id);
  Future<List<PostModel>> getPostsByPlaceId(int placeId,
      {int page = 1, int perPage = 20});
  Future<List<PostModel>> getPostsByUserId(int userId,
      {int page = 1, int perPage = 20});
  Future<bool> toggleLikePost(int postId);
  Future<CommentModel> createComment(int postId, String comment);
  Future<PostModel> createPost({
    required int placeId,
    required String content,
    List<String>? imageUrls,
    List<String>? hashtags,
    String? locationDetails,
  });
  Future<void> deletePost(int postId);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient dioClient;
  PostRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<PostModel>> getPosts({
    int? perPage = 10,
    int? page = 1,
    bool? trending = false,
    bool? following = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': perPage,
        'page': page,
        'trending': trending,
        'following': following,
      };

      final response = await dioClient.dio.get(
        ApiEndpoints.posts,
        queryParameters: queryParams,
      );

      return extractApiResponseListData<PostModel>(
        response,
        (json) {
          final raw = Map<String, dynamic>.from(json as Map<String, dynamic>);
          final postJson =
              flattenAdditionalInfoForPost(raw, removeContainer: false);
          return PostModel.fromJson(postJson);
        },
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.replaceId(ApiEndpoints.postDetail, '$id'),
      );

      return extractApiResponseData<PostModel>(
        response,
        (json) => PostModel.fromJson(json as Map<String, dynamic>),
      );
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<PostModel>> getPostsByPlaceId(int placeId,
      {int page = 1, int perPage = 20}) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.replaceId(ApiEndpoints.placePosts, '$placeId'),
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return extractApiResponseListData<PostModel>(
        response,
        (json) {
          final raw = Map<String, dynamic>.from(json as Map<String, dynamic>);
          final postJson =
              flattenAdditionalInfoForPost(raw, removeContainer: false);
          return PostModel.fromJson(postJson);
        },
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
  Future<List<PostModel>> getPostsByUserId(int userId,
      {int page = 1, int perPage = 20}) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.replaceId(ApiEndpoints.userPosts, '$userId'),
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      return extractApiResponseListData<PostModel>(
        response,
        (json) {
          final raw = Map<String, dynamic>.from(json as Map<String, dynamic>);
          final postJson =
              flattenAdditionalInfoForPost(raw, removeContainer: false);
          return PostModel.fromJson(postJson);
        },
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
  Future<bool> toggleLikePost(int postId) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.postLike.replaceFirst('{post_id}', '$postId'),
      );

      // Response: { success: true, message: "...", data: { "action": "like"/"unlike", "post_id": 17 } }
      final responseData = extractApiResponseData<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      // Parse action field to determine if post is now liked
      final action = responseData['action'] as String?;
      return action == 'like';
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<CommentModel> createComment(int postId, String comment) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.postComment.replaceFirst('{post_id}', '$postId'),
        data: {'comment': comment},
      );

      // Extract response data
      final responseData = extractApiResponseData<Map<String, dynamic>>(
        response,
        (json) => json as Map<String, dynamic>,
      );

      // Check if response contains 'comment' key (nested structure)
      // or if it's the comment data directly
      final commentData = responseData.containsKey('comment')
          ? responseData['comment'] as Map<String, dynamic>
          : responseData;

      return CommentModel.fromJson(commentData);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<PostModel> createPost({
    required int placeId,
    required String content,
    List<String>? imageUrls,
    List<String>? hashtags,
    String? locationDetails,
  }) async {
    try {
      final payload = <String, dynamic>{
        'place_id': placeId,
        'content': content,
      };

      if (imageUrls != null && imageUrls.isNotEmpty) {
        payload['image_urls'] = imageUrls;
      }

      if (hashtags != null || locationDetails != null) {
        final additionalInfo = <String, dynamic>{};
        if (hashtags != null) additionalInfo['hashtags'] = hashtags;
        if (locationDetails != null) {
          additionalInfo['location_details'] = locationDetails;
        }
        payload['additional_info'] = additionalInfo;
      }

      final response = await dioClient.dio.post(
        ApiEndpoints.posts,
        data: payload,
      );

      return extractApiResponseData<PostModel>(
        response,
        (json) {
          final raw = Map<String, dynamic>.from(json as Map<String, dynamic>);
          final postJson =
              flattenAdditionalInfoForPost(raw, removeContainer: false);
          return PostModel.fromJson(postJson);
        },
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
  Future<void> deletePost(int postId) async {
    try {
      final endpoint =
          ApiEndpoints.postDetail.replaceAll('{id}', postId.toString());
      await dioClient.dio.delete(endpoint);
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      throw ServerException('Failed to delete post: $e', 500);
    }
  }

  // @override
  // Future<PostModel> createPost(PostModel post) async {
  //   try {
  //     final response = await dio.post('/posts', data: post.toJson());
  //     return PostModel.fromJson(response.data);
  //   } catch (e) {
  //     throw Exception('Failed to create post: $e');
  //   }
  // }

  // @override
  // Future<PostModel> updatePost(PostModel post) async {
  //   try {
  //     final response = await dio.put('/posts/${post.id}', data: post.toJson());
  //     return PostModel.fromJson(response.data);
  //   } catch (e) {
  //     throw Exception('Failed to update post: $e');
  //   }
  // }

  // @override
  // Future<void> deletePost(int id) async {
  //   try {
  //     await dio.delete('/posts/$id');
  //   } catch (e) {
  //     throw Exception('Failed to delete post: $e');
  //   }
  // }

  Exception _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401)
      return AuthenticationException('Authentication required');
    if (status == 403) return AuthorizationException('Access denied');
    if (status == 404) return ServerException('Not found', 404);
    if (status == 422) {
      return ValidationException(
        data is Map
            ? (data['message'] ?? 'Validation failed')
            : 'Validation failed',
        errors: data is Map && data['errors'] is Map
            ? Map<String, dynamic>.from(data['errors'])
            : null,
      );
    }

    return ServerException(
        data is Map
            ? data['message'] ?? 'Network error occurred'
            : 'Network error occurred',
        status ?? 500);
  }
}
