import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../_display_widgets/avatar_widget.dart';
import '../_display_widgets/app_icon.dart';

/// Reusable bottom sheet to share user profile with QR card + action bar.
class ShareProfileModal extends StatelessWidget {
  final String profileLink;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? frameUrl;
  final VoidCallback? onClose;
  final VoidCallback? onSave;
  final VoidCallback? onShareMore;

  const ShareProfileModal({
    super.key,
    required this.profileLink,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.frameUrl,
    this.onClose,
    this.onSave,
    this.onShareMore,
  });

  @override
  Widget build(BuildContext context) {
    final hasUsername = username.isNotEmpty;
    final handle = hasUsername ? username : 'Profil Snappie';

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQrCard(handle),
            const SizedBox(height: 32),
            _buildActionBar(handle),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(String handle) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.textPrimary, width: 2),
            ),
            child: QrImageView(
              data: profileLink,
              version: QrVersions.auto,
              backgroundColor: Colors.white,
              eyeStyle: QrEyeStyle(
                color: AppColors.textPrimary,
                eyeShape: QrEyeShape.square,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: AppColors.textPrimary,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      handle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AvatarWidget(
                imageUrl: avatarUrl ?? 'avatar_f1_hdpi.png',
                size: AvatarSize.large,
                frameUrl: frameUrl,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(String handle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ikuti saya di Snappie!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onClose ?? () => Get.back(),
                icon: AppIcon(AppAssets.icons.close,
                    color: AppColors.textSecondary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildShareActionButton(
                icon: Icons.download_rounded,
                label: 'Simpan',
                onTap: onSave ??
                    () {
                      Get.back();
                      Get.snackbar(
                        'Segera',
                        'Fitur simpan QR akan segera hadir',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
              ),
              const SizedBox(width: 24),
              _buildShareActionButton(
                icon: Icons.more_vert,
                label: 'Lainnya',
                onTap: onShareMore ??
                    () {
                      Get.back();
                      Share.share(profileLink,
                          subject: 'Ikuti saya di Snappie');
                    },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              // color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
