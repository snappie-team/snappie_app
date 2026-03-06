import 'package:dio/dio.dart';
import 'package:snappie_app/app/core/utils/api_response.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../routes/api_endpoints.dart';
import '../../../core/helpers/api_response_helper.dart';
import '../../models/social_model.dart';

abstract class SocialRemoteDataSource {
  /// Get follow data (followers and following) for a user
  /// If [userId] is provided, fetches data for that user; otherwise for current user
  Future<SocialFollowData> getFollowData({int? userId});
  
  /// Follow a user by their ID
  Future<void> followUser(int userId);
}

class SocialRemoteDataSourceImpl implements SocialRemoteDataSource {
  final DioClient dioClient;
  SocialRemoteDataSourceImpl(this.dioClient);

  @override
  Future<SocialFollowData> getFollowData({int? userId}) async {
    try {
      final resp = await dioClient.dio.get(
        ApiEndpoints.socialFollow,
        data: userId != null ? {'user_id': userId} : null,
      );
      final data = extractApiResponseData<SocialFollowData>(
        resp,
        (json) => SocialFollowData.fromJson(json),
      );
      return data;
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to get follow data: $e', 500);
    }
  }

  @override
  Future<void> followUser(int userId) async {
    try {
      final endpoint = ApiEndpoints.socialFollowUser.replaceAll('{user_id}', userId.toString());
      await dioClient.dio.post(endpoint);
    } on ApiResponseException catch (e) {
      throw ServerException(e.message, e.statusCode ?? 500);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException('Failed to follow user: $e', 500);
    }
  }

  ServerException _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      return ServerException('Unauthorized', 401);
    }
    if (e.response?.statusCode == 404) {
      return ServerException('Not found', 404);
    }
    final message = e.response?.data?['message'] ?? 'Network error';
    return ServerException(message, e.response?.statusCode ?? 500);
  }
}
