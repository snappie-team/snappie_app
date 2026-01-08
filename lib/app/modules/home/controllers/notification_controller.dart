import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/repositories/social_repository_impl.dart';

/// Notification types
enum NotificationType {
  follow,
  like,
  comment,
  achievement,
  reward,
  system,
}

/// Notification model (local, no API yet)
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String? subtitle;
  final String? avatarUrl;
  final String? actionLabel;
  final int? relatedUserId;
  final int? relatedPostId;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.actionLabel,
    this.relatedUserId,
    this.relatedPostId,
    required this.createdAt,
    this.isRead = false,
  });

  /// Get icon based on notification type
  String get iconName {
    switch (type) {
      case NotificationType.follow:
        return 'person_add';
      case NotificationType.like:
        return 'favorite';
      case NotificationType.comment:
        return 'chat_bubble';
      case NotificationType.achievement:
        return 'emoji_events';
      case NotificationType.reward:
        return 'card_giftcard';
      case NotificationType.system:
        return 'info';
    }
  }
}

/// Notification Controller
/// Currently uses dummy data - ready for API integration
class NotificationController extends GetxController {
  final SocialRepository? socialRepository;

  NotificationController({this.socialRepository});

  final _notifications = <NotificationItem>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isInitialized = false.obs;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  /// Get today's notifications
  List<NotificationItem> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _notifications.where((n) => n.createdAt.isAfter(today)).toList();
  }

  /// Get earlier notifications
  List<NotificationItem> get earlierNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _notifications.where((n) => n.createdAt.isBefore(today)).toList();
  }

  /// Unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

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

  /// Load notifications
  /// TODO: Replace with API call when ready
  Future<void> loadNotifications() async {
    _isLoading.value = true;
    _errorMessage.value = '';

    try {
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate dummy data for now
      final dummyNotifications = _generateDummyNotifications();
      _notifications.assignAll(dummyNotifications);

      Logger.info(
          'Loaded ${dummyNotifications.length} notifications', 'Notification');
    } catch (e) {
      _errorMessage.value = 'Gagal memuat notifikasi';
      Logger.error('Failed to load notifications', e, null, 'Notification');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = NotificationItem(
        id: notification.id,
        type: notification.type,
        title: notification.title,
        subtitle: notification.subtitle,
        avatarUrl: notification.avatarUrl,
        actionLabel: notification.actionLabel,
        relatedUserId: notification.relatedUserId,
        relatedPostId: notification.relatedPostId,
        createdAt: notification.createdAt,
        isRead: true,
      );
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    final updated = _notifications
        .map((n) => NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              subtitle: n.subtitle,
              avatarUrl: n.avatarUrl,
              actionLabel: n.actionLabel,
              relatedUserId: n.relatedUserId,
              relatedPostId: n.relatedPostId,
              createdAt: n.createdAt,
              isRead: true,
            ))
        .toList();
    _notifications.assignAll(updated);
  }

  /// Handle follow back action
  Future<void> followBack(int userId) async {
    try {
      if (socialRepository != null) {
        await socialRepository!.followUser(userId);
        Get.snackbar(
          'Berhasil',
          'Kamu sudah mengikuti pengguna ini',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Logger.error('Failed to follow back', e, null, 'Notification');
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengikuti pengguna',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Generate dummy notifications for development
  List<NotificationItem> _generateDummyNotifications() {
    final now = DateTime.now();

    return [
      // Today
      NotificationItem(
        id: '1',
        type: NotificationType.follow,
        title: 'm.tafif mengikuti anda',
        avatarUrl: 'avatar_m1_hdpi.png',
        actionLabel: 'Ikuti Balik',
        relatedUserId: 101,
        createdAt: now.subtract(const Duration(minutes: 30)),
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.like,
        title: 'sarah_food menyukai postingan anda',
        subtitle: '"Nasi goreng enak banget di sini!"',
        avatarUrl: 'avatar_f1_hdpi.png',
        relatedUserId: 102,
        relatedPostId: 201,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.comment,
        title: 'john_doe berkomentar di postingan anda',
        subtitle: '"Wah keren banget tempatnya!"',
        avatarUrl: 'avatar_m2_hdpi.png',
        relatedUserId: 103,
        relatedPostId: 201,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.achievement,
        title: 'Selamat! Kamu mendapat badge "Food Explorer"',
        subtitle: 'Kunjungi 10 tempat berbeda',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      // Yesterday
      NotificationItem(
        id: '5',
        type: NotificationType.follow,
        title: 'culinary_hunter mengikuti anda',
        avatarUrl: 'avatar_m3_hdpi.png',
        actionLabel: 'Ikuti Balik',
        relatedUserId: 104,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      NotificationItem(
        id: '6',
        type: NotificationType.reward,
        title: 'Kamu mendapat 50 koin!',
        subtitle: 'Bonus harian login',
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
        isRead: true,
      ),
      // Earlier
      NotificationItem(
        id: '7',
        type: NotificationType.like,
        title: 'foodie_id dan 5 lainnya menyukai postingan anda',
        avatarUrl: 'avatar_f2_hdpi.png',
        relatedPostId: 200,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      NotificationItem(
        id: '8',
        type: NotificationType.system,
        title: 'Update terbaru tersedia',
        subtitle: 'Fitur baru: Pilih bingkai foto',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }
}
