import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/mission_controller.dart';
import '../../shared/widgets/_dialog_widgets/mission_loading_modal.dart';
import '../../shared/widgets/_dialog_widgets/mission_success_modal.dart';
import '../../shared/widgets/_dialog_widgets/mission_failed_modal.dart';
import '../../shared/widgets/_dialog_widgets/mission_next_modal.dart';

/// Halaman preview foto sebelum submit
class MissionPhotoPreviewView extends GetView<MissionController> {
  const MissionPhotoPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            _buildTopBar(),

            // Preview image
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.grey[900],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Obx(() {
                    final imagePath = controller.capturedImagePath.value;
                    if (imagePath != null && File(imagePath).existsSync()) {
                      return Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      );
                    }
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 64,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada gambar',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          TextButton.icon(
            onPressed: () {
              controller.clearCapturedImage();
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 20,
            ),
            label: Text(
              'Kembali',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  controller.isSubmitting.value ? null : () => _submitPhoto(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Kumpulkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
        ),
      )),
    );
  }

  Future<void> _submitPhoto() async {
    // Show loading modal
    MissionLoadingModal.show(message: 'Loading...');

    final success = await controller.submitPhoto();

    // Hide loading modal
    MissionLoadingModal.hide();

    if (success) {
      // Pop back to MissionPhotoView first - this will trigger its dispose
      // and free camera resources before showing modals
      Get.back();
      
      // Small delay to ensure camera is disposed
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Show success modal
      final claimResult = await MissionSuccessModal.show(
        title: 'Misi Berhasil!',
        description:
            'Selamat, Anda telah menyelesaikan misi.\nKlaim ${controller.expReward} XP dan ${controller.coinReward} Koin Kamu!',
      );

      if (claimResult == true) {
        // Show next mission modal
        final continueNext = await MissionNextModal.show(
          title: 'Misi Selanjutnya!',
          description:
              'Berikan ulasanmu di tempat ini\ndan dapatkan hadiahnya!',
        );

        if (continueNext == true) {
          controller.nextStep();
          Get.offNamed(AppPages.MISSION_REVIEW);
        } else {
          // Return to place detail
          Get.until((route) => route.settings.name == AppPages.PLACE_DETAIL);
        }
      }
    } else {
      // Show failed modal
      final retry = await MissionFailedModal.show(
        failureType: MissionFailureType.failed,
      );

      if (retry == true) {
        // Retry submission
        _submitPhoto();
      }
    }
  }
}
