import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/localization/locale_keys.g.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  _buildOnboardingPage(
                    imagePath: AppAssets.images.onboarding1,
                    title: tr(LocaleKeys.onboarding_page1_title),
                    description: tr(LocaleKeys.onboarding_page1_description),
                  ),
                  _buildOnboardingPage(
                    imagePath: AppAssets.images.onboarding2,
                    title: tr(LocaleKeys.onboarding_page2_title),
                    description: tr(LocaleKeys.onboarding_page2_description),
                  ),
                  _buildOnboardingPage(
                    imagePath: AppAssets.images.onboarding3,
                    title: tr(LocaleKeys.onboarding_page3_title),
                    description: tr(LocaleKeys.onboarding_page3_description),
                  ),
                ],
              ),
            ),
            _buildBottomSection(),
              ],
            ),
            // Language Toggle - positioned at top-right
            _buildLanguageToggle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Image.asset(
            imagePath,
            height: 300,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 48),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Page indicators
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.totalPages,
                  (index) => _buildIndicator(
                    isActive: index == controller.currentPage.value,
                  ),
                ),
              )),
          const SizedBox(height: 32),
          // Buttons
          Obx(() {
            final isFirstPage = controller.currentPage.value == 0;
            final isLastPage = controller.currentPage.value == controller.totalPages - 1;

            return Row(
              children: [
                // Back button (hide on first page)
                if (!isFirstPage)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previousPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.accent,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        tr(LocaleKeys.onboarding_back),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (!isFirstPage) const SizedBox(width: 16),
                // Next/Finish button
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      isLastPage
                          ? tr(LocaleKeys.onboarding_get_started)
                          : tr(LocaleKeys.onboarding_next),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIndicator({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.accent : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageButton(context, 'ID', 'id'),
            const SizedBox(width: 8),
            _buildLanguageButton(context, 'EN', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String label, String languageCode) {
    final currentLocale = context.locale.languageCode;
    final isSelected = currentLocale == languageCode;

    return GestureDetector(
      onTap: () async {
        final newLocale = Locale(languageCode);
        await context.setLocale(newLocale);
        Get.updateLocale(newLocale);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade400,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
