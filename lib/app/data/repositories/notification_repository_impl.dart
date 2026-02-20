import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../datasources/remote/notification_remote_datasource.dart';
import '../models/notification_model.dart';

/// Notification Repository
/// Handles notification data operations
class NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepository({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  /// Get paginated notifications
  /// Throws: [ServerException], [NetworkException], [AuthenticationException]
  Future<NotificationResponse> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    return await remoteDataSource.getNotifications(
      page: page,
      perPage: perPage,
    );
  }

  /// Get unread notification count
  /// Returns 0 on error (non-throwing for badge usage)
  Future<int> getUnreadCount() async {
    try {
      if (!await networkInfo.isConnected) return 0;
      return await remoteDataSource.getUnreadCount();
    } catch (_) {
      return 0;
    }
  }

  /// Mark a notification as read
  /// Throws: [ServerException], [NetworkException]
  Future<void> markAsRead(int notificationId) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    await remoteDataSource.markAsRead(notificationId);
  }

  /// Mark all notifications as read
  /// Throws: [ServerException], [NetworkException]
  Future<void> markAllAsRead() async {
    if (!await networkInfo.isConnected) {
      throw NetworkException('No internet connection');
    }

    await remoteDataSource.markAllAsRead();
  }
}
