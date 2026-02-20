import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../controllers/notification_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/notification_repository_impl.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../shared/widgets/index.dart';
import '../../shared/layout/controllers/main_controller.dart';

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
                  subtitle:
                      'Raih XP, Koin, dan hadiah eksklusif lainnya dengan menyelesaikan misi!',
                  imageAsset: Image.asset(AppAssets.images.target),
                  size: BannerSize.compact,
                  onTap: () => Get.toNamed(AppPages.CHALLENGES),
                  showCloseButton: true,
                  onClose: () => controller.hideBanner(),
                ),
              )
            : const SliverToBoxAdapter(child: SizedBox.shrink())),

        // Posts Timeline (before carousel)
        Obx(() {
          if (controller.isLoading && controller.posts.isEmpty) {
            return const LoadingStateWidget(
              isSliver: true,
            );
          }

          final posts = controller.posts;
          // Show first 3 posts before the carousel
          const int carouselPosition = 3;
          final int beforeCount =
              posts.length < carouselPosition ? posts.length : carouselPosition;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => PostCard(post: posts[index]),
              childCount: beforeCount,
            ),
          );
        }),

        // Article Carousel (after 3rd post, only once)
        Obx(() {
          final articles = controller.articles;
          final hasPosts = controller.posts.length >= 3;
          if (articles.isEmpty || !hasPosts) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverToBoxAdapter(
            child: ArticleCarouselWidget(articles: articles),
          );
        }),

        // Posts Timeline (after carousel)
        Obx(() {
          final posts = controller.posts;
          const int carouselPosition = 3;
          if (posts.length <= carouselPosition) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  PostCard(post: posts[carouselPosition + index]),
              childCount: posts.length - carouselPosition,
            ),
          );
        }),
      ],
      // TODO: Remove test FABs after snackbar verification
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Test Snackbar FABs ──
          // FloatingActionButton.small(
          //   heroTag: 'test_success',
          //   onPressed: () => AppSnackbar.success('Ini contoh snackbar sukses'),
          //   backgroundColor: AppColors.success,
          //   child: const Icon(Icons.check, color: Colors.white, size: 20),
          // ),
          // const SizedBox(height: 8),
          // FloatingActionButton.small(
          //   heroTag: 'test_error',
          //   onPressed: () => AppSnackbar.error('Ini contoh snackbar error'),
          //   backgroundColor: AppColors.error,
          //   child: const Icon(Icons.close, color: Colors.white, size: 20),
          // ),
          // const SizedBox(height: 8),
          // FloatingActionButton.small(
          //   heroTag: 'test_warning',
          //   onPressed: () => AppSnackbar.warning('Ini contoh snackbar warning'),
          //   backgroundColor: AppColors.warning,
          //   child:
          //       const Icon(Icons.warning_amber, color: Colors.white, size: 20),
          // ),
          // const SizedBox(height: 8),
          // FloatingActionButton.small(
          //   heroTag: 'test_info',
          //   onPressed: () => AppSnackbar.info('Ini contoh snackbar info'),
          //   backgroundColor: AppColors.primary,
          //   child:
          //       const Icon(Icons.info_outline, color: Colors.white, size: 20),
          // ),
          // const SizedBox(height: 8),
          // FloatingActionButton.small(
          //   heroTag: 'test_tour',
          //   onPressed: () {
          //     try {
          //       Get.find<MainController>().debugShowOnboarding();
          //     } catch (e) {
          //       AppSnackbar.error('MainController tidak ditemukan');
          //     }
          //   },
          //   backgroundColor: Colors.amber,
          //   child:
          //       const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          // ),
          // const SizedBox(height: 12),
          // ── Original Create Post FAB ──
          FloatingActionButton(
            heroTag: 'create_post',
            onPressed: () => Get.toNamed(AppPages.CREATE_POST),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            shape: CircleBorder(),
            elevation: 4,
            child: AppIcon(AppAssets.icons.create,
                size: 28, color: AppColors.textOnPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Initialize notification controller for badge
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController(
        notificationRepository: Get.isRegistered<NotificationRepository>()
            ? Get.find<NotificationRepository>()
            : null,
        socialRepository: Get.isRegistered<SocialRepository>()
            ? Get.find<SocialRepository>()
            : null,
      ));
    }
    final notifController = Get.find<NotificationController>();
    notifController.fetchUnreadCount();

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
            child: Obx(() => Text(
                  'Hello, ${controller.userData?.name ?? 'User'}!',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: FontSize.getSize(FontSizeOption.xl),
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ),
          ButtonWidget(
            key: Key('home_invite_button'),
            icon: AppIcon(AppAssets.icons.addFriend, color: AppColors.primary),
            backgroundColor: AppColors.backgroundContainer,
            onPressed: () => Get.toNamed(AppPages.INVITE_FRIENDS),
          ),
          const SizedBox(width: 8),
          Obx(() => ButtonWidget(
                key: Key('home_notification_button'),
                icon: AppIcon(AppAssets.icons.notification,
                    color: AppColors.primary),
                backgroundColor: AppColors.backgroundContainer,
                onPressed: () => Get.toNamed(AppPages.NOTIFICATIONS),
                hasNotification: Get.isRegistered<NotificationController>()
                    ? Get.find<NotificationController>().hasUnread
                    : false,
              )),
        ],
      ),
    );
  }
}
