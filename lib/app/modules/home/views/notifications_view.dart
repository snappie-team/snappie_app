import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../../shared/widgets/index.dart';
import '../controllers/notification_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late NotificationController controller;

  @override
  void initState() {
    super.initState();
    // Create controller if not exists
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(
        socialRepository: Get.isRegistered() ? Get.find() : null,
      ));
    }
    controller = Get.find<NotificationController>();
    controller.initializeIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Notifikasi',
      actions: [
        // Mark all as read button
        Obx(() => controller.unreadCount > 0
            ? IconButton(
                onPressed: () {
                  controller.markAllAsRead();
                  Get.snackbar(
                    'Berhasil',
                    'Semua notifikasi ditandai sudah dibaca',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icon(
                  Icons.done_all,
                  color: AppColors.primary,
                ),
                tooltip: 'Tandai semua dibaca',
              )
            : const SizedBox.shrink()),
      ],
      slivers: [
        Obx(() {
          if (controller.isLoading) {
            return const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (controller.errorMessage.isNotEmpty) {
            return SliverFillRemaining(
              child: ErrorStateWidget(
                message: controller.errorMessage,
                onRetry: controller.refreshNotifications,
              ),
            );
          }

          if (controller.notifications.isEmpty) {
            return const SliverFillRemaining(
              child: NoNotificationsEmptyState(),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Today section
                if (controller.todayNotifications.isNotEmpty) ...[
                  _buildSectionHeader('Hari ini'),
                  const SizedBox(height: 12),
                  ...controller.todayNotifications.map(
                    (notification) => _buildNotificationCard(notification),
                  ),
                  const SizedBox(height: 24),
                ],
                // Earlier section
                if (controller.earlierNotifications.isNotEmpty) ...[
                  _buildSectionHeader('Sebelumnya'),
                  const SizedBox(height: 12),
                  ...controller.earlierNotifications.map(
                    (notification) => _buildNotificationCard(notification),
                  ),
                ],
              ]),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: notification.isRead
            ? Colors.white
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead
            ? null
            : Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar or Icon
          _buildLeadingWidget(notification),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        notification.isRead ? FontWeight.w500 : FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                if (notification.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    notification.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // Action button
          if (notification.actionLabel != null &&
              notification.relatedUserId != null)
            ElevatedButton(
              onPressed: () =>
                  controller.followBack(notification.relatedUserId!),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                notification.actionLabel!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // More button
          PopupMenuButton<String>(
            icon:
                Icon(Icons.more_vert, color: AppColors.textTertiary, size: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (value) {
              switch (value) {
                case 'read':
                  controller.markAsRead(notification.id);
                  break;
                case 'profile':
                  if (notification.relatedUserId != null) {
                    Get.toNamed(
                      AppPages.USER_PROFILE,
                      arguments: {'userId': notification.relatedUserId},
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem<String>(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 18),
                      SizedBox(width: 8),
                      Text('Tandai dibaca'),
                    ],
                  ),
                ),
              if (notification.relatedUserId != null)
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Lihat profil'),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingWidget(NotificationItem notification) {
    if (notification.avatarUrl != null) {
      return AvatarWidget(
        imageUrl: notification.avatarUrl,
        size: AvatarSize.medium,
      );
    }

    // Icon based on type
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.follow:
        iconData = Icons.person_add;
        iconColor = AppColors.primary;
        break;
      case NotificationType.like:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.comment:
        iconData = Icons.chat_bubble;
        iconColor = AppColors.accent;
        break;
      case NotificationType.achievement:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case NotificationType.reward:
        iconData = Icons.card_giftcard;
        iconColor = Colors.green;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = AppColors.textSecondary;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
