import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/font_size.dart';

/// Generic processing/loading modal with a mascot/asset.
class ProcessingModal extends StatelessWidget {
  final String message;

  const ProcessingModal({
    super.key,
    required this.message,
  });

  /// Show the modal
  static void show({String message = 'Mohon tunggu...'}) {
    Get.dialog(
      ProcessingModal(message: message),
      barrierDismissible: false,
    );
  }

  /// Hide the modal
  static void hide() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asset Loading
              Image.asset(
                AppAssets.images.loading,
                height: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: FontSize.getSize(FontSizeOption.medium),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtext or actual indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF2994A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
