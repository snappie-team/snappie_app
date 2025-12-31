import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

/// Tipe kegagalan misi
enum MissionFailureType {
  /// Misi gagal (general)
  failed,

  /// Jaringan terputus
  networkError,

  /// Sudah pernah menyelesaikan misi (409 Conflict)
  alreadyCompleted,
}

/// Modal gagal untuk misi
class MissionFailedModal extends StatelessWidget {
  final MissionFailureType failureType;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const MissionFailedModal({
    super.key,
    required this.failureType,
    this.onRetry,
    this.onClose,
  });

  static Future<bool?> show({
    MissionFailureType failureType = MissionFailureType.failed,
  }) {
    return Get.dialog<bool>(
      MissionFailedModal(
        failureType: failureType,
        onRetry: failureType != MissionFailureType.alreadyCompleted
            ? () => Get.back(result: true)
            : null,
        onClose: () => Get.back(result: false),
      ),
      barrierDismissible: false,
    );
  }

  String get _title {
    switch (failureType) {
      case MissionFailureType.failed:
        return 'Ups, Misi Gagal!';
      case MissionFailureType.networkError:
        return 'Ups, Jaringan Terputus!';
      case MissionFailureType.alreadyCompleted:
        return 'Misi Sudah Selesai!';
    }
  }

  String get _description {
    switch (failureType) {
      case MissionFailureType.failed:
        return 'Jangan khawatir, kamu bisa coba lagi.\nSemangat!';
      case MissionFailureType.networkError:
        return 'Jangan khawatir, kamu bisa coba lagi.\nSemangat!';
      case MissionFailureType.alreadyCompleted:
        return 'Kamu sudah menyelesaikan misi ini bulan ini.\nCoba lagi bulan depan ya!';
    }
  }

  Color get _primaryColor {
    switch (failureType) {
      case MissionFailureType.alreadyCompleted:
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  IconData get _icon {
    switch (failureType) {
      case MissionFailureType.alreadyCompleted:
        return Icons.check_circle_outline;
      default:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot image or icon
            Image.asset(
              failureType == MissionFailureType.alreadyCompleted
                  ? AppAssets.images.mission // Could use different image
                  : AppAssets.images.mission,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: failureType == MissionFailureType.alreadyCompleted
                        ? AppColors.warningContainer
                        : AppColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _icon,
                    size: 48,
                    color: _primaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              _title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              _description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            if (failureType == MissionFailureType.alreadyCompleted) ...[
              // Only show "Kembali" button for already completed
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClose,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Show "Coba Lagi" button for other failures
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
