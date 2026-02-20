import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification types matching backend enum
enum NotificationType {
  follow,
  like,
  comment,
  achievement,
  reward,
  system;

  /// Get icon name for this notification type
  String get iconName {
    switch (this) {
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

/// Notification model from API
@JsonSerializable()
class NotificationModel {
  final int? id;
  final String? type;
  final String? title;
  final String? subtitle;

  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @JsonKey(name: 'action_label')
  final String? actionLabel;

  @JsonKey(name: 'related_user_id')
  final int? relatedUserId;

  @JsonKey(name: 'related_post_id')
  final int? relatedPostId;

  @JsonKey(name: 'related_place_id')
  final int? relatedPlaceId;

  @JsonKey(name: 'is_read')
  final bool isRead;

  final Map<String, dynamic>? metadata;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.type,
    this.title,
    this.subtitle,
    this.avatarUrl,
    this.actionLabel,
    this.relatedUserId,
    this.relatedPostId,
    this.relatedPlaceId,
    this.isRead = false,
    this.metadata,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  /// Get the notification type as enum
  NotificationType get notificationType {
    switch (type) {
      case 'follow':
        return NotificationType.follow;
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'achievement':
        return NotificationType.achievement;
      case 'reward':
        return NotificationType.reward;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  /// Create a copy with updated read status
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      avatarUrl: avatarUrl,
      actionLabel: actionLabel,
      relatedUserId: relatedUserId,
      relatedPostId: relatedPostId,
      relatedPlaceId: relatedPlaceId,
      isRead: isRead ?? this.isRead,
      metadata: metadata,
      createdAt: createdAt,
    );
  }
}

/// Paginated notification response
@JsonSerializable()
class NotificationResponse {
  final List<NotificationModel>? notifications;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  final NotificationPagination? pagination;

  NotificationResponse({
    this.notifications,
    this.unreadCount = 0,
    this.pagination,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

/// Pagination info
@JsonSerializable()
class NotificationPagination {
  @JsonKey(name: 'current_page')
  final int currentPage;

  @JsonKey(name: 'per_page')
  final int perPage;

  final int total;

  @JsonKey(name: 'last_page')
  final int lastPage;

  NotificationPagination({
    this.currentPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage = 1,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) =>
      _$NotificationPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPaginationToJson(this);
}
