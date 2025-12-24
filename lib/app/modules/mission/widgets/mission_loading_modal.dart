import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';

/// Modal loading saat proses upload misi
class MissionLoadingModal extends StatelessWidget {
  final String? message;

  const MissionLoadingModal({
    super.key,
    this.message,
  });

  /// Show loading modal
  static void show({String? message}) {
    Get.dialog(
      MissionLoadingModal(message: message),
      barrierDismissible: false,
    );
  }

  /// Hide loading modal
  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
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
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mascot image
            Image.asset(
              AppAssets.images.mission,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(),
                );
              },
            ),
            const SizedBox(height: 20),

            // Loading text
            Text(
              message ?? 'Loading...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
