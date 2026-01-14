import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../_display_widgets/avatar_widget.dart';
import '../_display_widgets/app_icon.dart';

/// Reusable notification card widget for displaying user notifications
/// Can be used in notifications list, activity feeds, etc.
class NotificationCardWidget extends StatelessWidget {
  const NotificationCardWidget({
    super.key,
    required this.avatar,
    required this.title,
    required this.buttonLabel,
    required this.onButtonTap,
    required this.onMoreTap,
  });

  final String avatar;
  final String title;
  final String buttonLabel;
  final VoidCallback onButtonTap;
  final VoidCallback onMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarWidget(imageUrl: avatar, size: AvatarSize.large),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onButtonTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            onPressed: onMoreTap,
            icon: AppIcon(AppAssets.icons.moreDots, color: Colors.grey, size: 24),
          ),
        ],
      ),
    );
  }
}
