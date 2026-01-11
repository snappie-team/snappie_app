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
import '../../widgets/lazy_indexed_child.dart';
import '../../widgets/index.dart';

class MainLayout extends GetView<MainController> {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex,
        children: [
          // Lazy load setiap tab - build hanya saat pertama kali dibuka
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(
                isActive: controller.currentIndex == 0,
                inactiveIcon: AppIcon(AppAssets.iconsSvg.home),
                activeIcon: AppIcon(AppAssets.iconsSvg.homeActive, color: AppColors.primary),
                label: 'Beranda',
                onTap: () => controller.changeTab(0),
              ),
              NavItem(
                isActive: controller.currentIndex == 1,
                inactiveIcon: AppIcon(AppAssets.iconsSvg.explore),
                activeIcon: AppIcon(AppAssets.iconsSvg.exploreActive, color: AppColors.primary),
                label: 'Jelajahi',
                onTap: () => controller.changeTab(1),
              ),
              NavItem(
                isActive: controller.currentIndex == 2,
                inactiveIcon: AppIcon(AppAssets.iconsSvg.article),
                activeIcon: AppIcon(AppAssets.iconsSvg.articleActive, color: AppColors.primary),
                label: 'Artikel',
                onTap: () => controller.changeTab(2),
              ),
              NavItem(
                isActive: controller.currentIndex == 3,
                inactiveIcon: AppIcon(AppAssets.iconsSvg.profile),
                activeIcon: AppIcon(AppAssets.iconsSvg.profileActive, color: AppColors.primary),
                label: 'Akun',
                onTap: () => controller.changeTab(3),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
