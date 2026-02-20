import 'package:dio/dio.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../routes/api_endpoints.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationResponse> getNotifications({int page = 1, int perPage = 20});
  Future<int> getUnreadCount();
  Future<void> markAsRead(int notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient dioClient;

  NotificationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      Logger.debug(
        'getNotifications response: status=${response.statusCode}',
        'NotificationRemoteDataSource',
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        final responseData = data['data'] as Map<String, dynamic>;
        return NotificationResponse.fromJson(responseData);
      }

      throw ServerException(
        data is Map ? data['message'] ?? 'Failed to load notifications' : 'Failed to load notifications',
        response.statusCode ?? 500,
      );
    } on DioException catch (e) {
      Logger.error('getNotifications dio error', e, null, 'NotificationRemoteDataSource');
      throw _mapDioException(e);
    } catch (e) {
      if (e is ServerException) rethrow;
      Logger.error('getNotifications unexpected error', e, null, 'NotificationRemoteDataSource');
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.dio.get(
        ApiEndpoints.notificationsUnreadCount,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return (data['data'] as Map<String, dynamic>)['unread_count'] as int? ?? 0;
      }

      return 0;
    } on DioException catch (e) {
      Logger.error('getUnreadCount dio error', e, null, 'NotificationRemoteDataSource');
      throw _mapDioException(e);
    } catch (e) {
      Logger.error('getUnreadCount unexpected error', e, null, 'NotificationRemoteDataSource');
      return 0;
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.notificationMarkRead
            .replaceAll('{notification_id}', '$notificationId'),
      );
    } on DioException catch (e) {
      Logger.error('markAsRead dio error', e, null, 'NotificationRemoteDataSource');
      throw _mapDioException(e);
    } catch (e) {
      Logger.error('markAsRead unexpected error', e, null, 'NotificationRemoteDataSource');
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.notificationsReadAll,
      );
    } on DioException catch (e) {
      Logger.error('markAllAsRead dio error', e, null, 'NotificationRemoteDataSource');
      throw _mapDioException(e);
    } catch (e) {
      Logger.error('markAllAsRead unexpected error', e, null, 'NotificationRemoteDataSource');
      throw ServerException('Unexpected error occurred: $e', 500);
    }
  }

  Exception _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    if (status == 401) return AuthenticationException('Authentication required');
    if (status == 403) return AuthorizationException('Access denied');
    if (status == 404) return ServerException('Not found', 404);

    return ServerException(
      data is Map ? data['message'] ?? 'Network error occurred' : 'Network error occurred',
      status ?? 500,
    );
  }
}
