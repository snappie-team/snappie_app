import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/widgets/index.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger lazy initialization saat view pertama kali di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeIfNeeded();
    });

    return ScaffoldFrame(
      controller: controller,
      headerHeight: 45,
      headerContent: _buildHeader(),
      slivers: [
        // Promotional Banner
        Obx(() => controller.showBanner
            ? SliverToBoxAdapter(
                child: PromotionalBanner(
                  title: 'Ayo Beraksi!',
                  subtitle: 'Raih XP, Koin, dan hadiah eksklusif lainnya dengan menyelesaikan misi!',
                  imageAsset: Image.asset(AppAssets.images.target),
                  size: BannerSize.compact,
                  onTap: () => Get.toNamed(AppPages.CHALLENGES),
                  showCloseButton: true,
                  onClose: () => controller.hideBanner(),
                ),
              )
            : const SliverToBoxAdapter(child: SizedBox.shrink())),

        // Posts Timeline
        Obx(() {
          if (controller.isLoading && controller.posts.isEmpty) {
            return const LoadingStateWidget(
              isSliver: true,
            );
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = controller.posts[index];
                return PostCard(
                  post: post,
                );
              },
              childCount: controller.posts.length,
            ),
          );
        }),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppPages.CREATE_POST),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: AppColors.border),
      // ),
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              'Hello, ${controller.userData?.name ?? 'User'}!',
              style: TextStyle(
                color: AppColors.textOnPrimary,
                fontSize: FontSize.getSize(FontSizeOption.xl),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ButtonWidget(
            icon: Icons.person_add_outlined,
            backgroundColor: AppColors.background,
            onPressed: () => Get.toNamed(AppPages.INVITE_FRIENDS),
          ),
          const SizedBox(width: 8),
          ButtonWidget(
            icon: Icons.notifications_outlined,
            backgroundColor: AppColors.background,
            onPressed: () => Get.toNamed(AppPages.NOTIFICATIONS),
            hasNotification: true, // TODO: ganti dengan logika sebenarnya
          ),
        ],
      ),
    );
  }
}
