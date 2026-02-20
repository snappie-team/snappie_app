import 'package:get/get.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository_impl.dart';
import '../../../data/repositories/social_repository_impl.dart';

/// Re-export NotificationType from model for backward compatibility
export '../../../data/models/notification_model.dart'
    show NotificationType, NotificationModel;

/// Notification Controller
/// Connects to real notification API endpoints
class NotificationController extends GetxController {
  final NotificationRepository? notificationRepository;
  final SocialRepository? socialRepository;

  NotificationController({
    this.notificationRepository,
    this.socialRepository,
  });

  final _notifications = <NotificationModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isInitialized = false.obs;
  final _unreadCount = 0.obs;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  int get unreadCount => _unreadCount.value;
  bool get hasUnread => _unreadCount.value > 0;

  /// Get today's notifications
  List<NotificationModel> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.createdAt != null && n.createdAt!.isAfter(today))
        .toList();
  }

  /// Get earlier notifications
  List<NotificationModel> get earlierNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _notifications
        .where((n) => n.createdAt != null && n.createdAt!.isBefore(today))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    Logger.debug('NotificationController created', 'Notification');
  }

  /// Initialize notifications data
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      Logger.debug('NotificationController initializing...', 'Notification');
      loadNotifications();
    }
  }

  /// Load notifications from API
  Future<void> loadNotifications() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      if (notificationRepository == null) {
        _errorMessage.value = 'Notification service not available';
        Logger.warning('NotificationRepository not injected', 'Notification');
        return;
      }

      final response = await notificationRepository!.getNotifications();

      _notifications.assignAll(response.notifications ?? []);
      _unreadCount.value = response.unreadCount;

      Logger.info(
        'Loaded ${_notifications.length} notifications (${_unreadCount.value} unread)',
        'Notification',
      );
    } catch (e) {
      _errorMessage.value = 'Gagal memuat notifikasi';
      Logger.error('Failed to load notifications', e, null, 'Notification');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    _isInitialized.value = false;
    _isInitialized.value = true;
    await loadNotifications();
  }

  /// Fetch only the unread count (lightweight, for badge)
  Future<void> fetchUnreadCount() async {
    try {
      if (notificationRepository == null) return;
      _unreadCount.value = await notificationRepository!.getUnreadCount();
    } catch (e) {
      Logger.error('Failed to fetch unread count', e, null, 'Notification');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount.value = _notifications.where((n) => !n.isRead).length;
    }

    try {
      await notificationRepository?.markAsRead(notificationId);
    } catch (e) {
      Logger.error('Failed to mark as read', e, null, 'Notification');
      // Revert optimistic update on error
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: false);
        _unreadCount.value = _notifications.where((n) => !n.isRead).length;
      }
    }
  }

  /// Mark all as read
  Future<void> markAllAsRead() async {
    // Optimistic update
    final previousNotifications = List<NotificationModel>.from(_notifications);
    final previousUnread = _unreadCount.value;

    final updated =
        _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _notifications.assignAll(updated);
    _unreadCount.value = 0;

    try {
      await notificationRepository?.markAllAsRead();
    } catch (e) {
      Logger.error('Failed to mark all as read', e, null, 'Notification');
      // Revert on error
      _notifications.assignAll(previousNotifications);
      _unreadCount.value = previousUnread;
    }
  }

  /// Handle follow back action
  Future<void> followBack(int userId) async {
    try {
      if (socialRepository != null) {
        await socialRepository!.followUser(userId);
        AppSnackbar.success('Kamu sudah mengikuti pengguna ini');
      }
    } catch (e) {
      Logger.error('Failed to follow back', e, null, 'Notification');
      AppSnackbar.error('Tidak dapat mengikuti pengguna');
    }
  }
}
