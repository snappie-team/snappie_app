import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../home/views/home_view.dart';
import '../../../explore/views/explore_view.dart';
import '../../../articles/views/articles_view.dart';
import '../../../profile/views/profile_view.dart';
import '../controllers/main_controller.dart';
import '../widgets/nav_item.dart';
import '../widgets/tab_tour_overlay.dart';
import '../../widgets/lazy_indexed_child.dart';
import '../../widgets/index.dart';

class MainLayout extends GetView<MainController> {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Obx(() => IndexedStack(
                index: controller.currentIndex,
                children: [
                  LazyIndexedChild(
                    builder: () => const HomeView(),
                    isActive: controller.currentIndex == 0,
                  ),
                  LazyIndexedChild(
                    builder: () => const ExploreView(),
                    isActive: controller.currentIndex == 1,
                  ),
                  LazyIndexedChild(
                    builder: () => const ArticlesView(),
                    isActive: controller.currentIndex == 2,
                  ),
                  LazyIndexedChild(
                    builder: () => const ProfileView(),
                    isActive: controller.currentIndex == 3,
                  ),
                ],
              )),

          // Tab tour overlay (coach marks after registration)
          Obx(() => controller.showTabTour.value
              ? TabTourOverlay(
                  currentStep: controller.currentTourStep.value,
                  onNext: controller.nextTourStep,
                  onBack: controller.previousTourStep,
                  onSkip: controller.skipTour,
                )
              : const SizedBox.shrink()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: NavItem(
                      key: Key('bottom_nav_home'),
                      isActive: controller.currentIndex == 0,
                      inactiveIcon: AppIcon(AppAssets.icons.home),
                      activeIcon: AppIcon(AppAssets.icons.homeActive,
                          color: AppColors.primary),
                      label: 'Beranda',
                      onTap: () => controller.changeTab(0),
                    ),
                  ),
                  Expanded(
                    child: NavItem(
                      key: Key('bottom_nav_explore'),
                      isActive: controller.currentIndex == 1,
                      inactiveIcon: AppIcon(AppAssets.icons.explore),
                      activeIcon: AppIcon(AppAssets.icons.exploreActive,
                          color: AppColors.primary),
                      label: 'Jelajahi',
                      onTap: () => controller.changeTab(1),
                    ),
                  ),
                  Expanded(
                    child: NavItem(
                      key: Key('bottom_nav_articles'),
                      isActive: controller.currentIndex == 2,
                      inactiveIcon: AppIcon(AppAssets.icons.article),
                      activeIcon: AppIcon(AppAssets.icons.articleActive,
                          color: AppColors.primary),
                      label: 'Artikel',
                      onTap: () => controller.changeTab(2),
                    ),
                  ),
                  Expanded(
                    child: NavItem(
                      key: Key('bottom_nav_profile'),
                      isActive: controller.currentIndex == 3,
                      inactiveIcon: AppIcon(AppAssets.icons.profile),
                      activeIcon: AppIcon(AppAssets.icons.profileActive,
                          color: AppColors.primary),
                      label: 'Akun',
                      onTap: () => controller.changeTab(3),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
