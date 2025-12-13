import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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

      // Response: { success: true, message: "...", data: true/false }
      final isLiked = extractApiResponseData<bool>(
        response,
        (json) => json as bool,
      );

      return isLiked;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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

      return extractApiResponseData<CommentModel>(
        response,
        (json) => CommentModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
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
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Authentication required');
      } else if (e.response?.statusCode == 403) {
        throw AuthorizationException('Access denied');
      } else if (e.response?.statusCode == 422) {
        throw ValidationException(
          e.response?.data['message'] ?? 'Validation error',
          errors: e.response?.data['errors'],
        );
      } else {
        throw ServerException(
          e.response?.data['message'] ?? 'Network error occurred',
          e.response?.statusCode ?? 500,
        );
      }
    } catch (e) {
      throw ServerException('Unexpected error occurred: $e', 500);
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
}
