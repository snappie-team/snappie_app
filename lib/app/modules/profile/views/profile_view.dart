import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../../../core/services/deep_link_service.dart';
import '../controllers/profile_controller.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/achievement_model.dart';
import '../../shared/widgets/index.dart';

// Route aliases for cleaner navigation
typedef Routes = AppPages;

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger lazy initialization saat view pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeIfNeeded();
    });

    return ScaffoldFrame(
      controller: controller,
      headerHeight: 340,
      headerContent: _buildHeader(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildTabBar(),
        ),
        Obx(() => SliverList(
              delegate: SliverChildListDelegate(_buildTabContent()),
            )),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      _buildTopBar(),

      const SizedBox(height: 16),

      // Profile Avatar with frame (reactive)
      Obx(() => AvatarWidget(
            imageUrl: controller.userAvatar,
            size: AvatarSize.extraLarge,
            frameUrl: controller.selectedFrameUrl.value,
          )),

      const SizedBox(height: 8),

      // User Name
      Obx(() => Text(
            controller.userName,
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )),

      // User Email
      Obx(() => Text(
            controller.userNickname,
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )),

      const SizedBox(height: 8),

      Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Obx(() => _buildStatColumn(
                    '${controller.totalPosts}',
                    'Postingan',
                  )),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            Expanded(
              child: Obx(() => _buildStatColumn(
                    '${controller.totalFollowers}',
                    'Pengikut',
                    onTap: () => Get.toNamed(
                      Routes.FOLLOWERS_FOLLOWING,
                      arguments: {'initialTab': 0},
                    ),
                  )),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            Expanded(
              child: Obx(() => _buildStatColumn(
                    '${controller.totalFollowing}',
                    'Mengikuti',
                    onTap: () => Get.toNamed(
                      Routes.FOLLOWERS_FOLLOWING,
                      arguments: {'initialTab': 1},
                    ),
                  )),
            ),
          ],
        ),
      ),

      const SizedBox(height: 8),
    ]);
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Obx(() => GestureDetector(
                    onTap: () => Get.toNamed(Routes.LEADERBOARD),
                    child: Container(
                      width: 75,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundContainer,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                          child: Text(
                        '${controller.totalExp} XP',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  )),
              const SizedBox(width: 4),
              Obx(() => GestureDetector(
                  onTap: () => Get.toNamed(Routes.COINS_HISTORY),
                  child: Container(
                    width: 75,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                        child: Text(
                      '${controller.totalCoins} Koin',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ))),
            ],
          ),
          Row(
            children: [
              ButtonWidget(
                icon: AppIcon(AppAssets.icons.addFriend,
                    color: AppColors.primary),
                backgroundColor: AppColors.backgroundContainer,
                onPressed: () => Get.toNamed(Routes.INVITE_FRIENDS),
              ),
              const SizedBox(width: 8),
              ButtonWidget(
                icon: AppIcon(AppAssets.icons.share, color: AppColors.primary),
                backgroundColor: AppColors.backgroundContainer,
                onPressed: () => _showShareProfileModal(),
              ),
              const SizedBox(width: 8),
              ButtonWidget(
                icon:
                    AppIcon(AppAssets.icons.setting, color: AppColors.primary),
                backgroundColor: AppColors.backgroundContainer,
                onPressed: () => Get.toNamed(Routes.SETTINGS),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.backgroundContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabItem('Postingan Saya', 0),
            _buildTabItem('Tersimpan', 1),
            _buildTabItem('Pencapaian', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // border: Border.all(color: AppColors.accent),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.xl3),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.medium),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    return Obx(() {
      bool isSelected = controller.selectedTabIndex == index;
      return GestureDetector(
        onTap: () {
          controller.setSelectedTabIndex(index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(24)),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: FontSize.getSize(FontSizeOption.regular),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildTabContent() {
    switch (controller.selectedTabIndex) {
      case 0: // Postingan Saya
        return [
          Obx(() {
            // Loading state
            if (controller.isLoadingPosts) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Empty state
            if (controller.userPosts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(64.0),
                child: Center(
                  child: Text(
                    'Belum ada postingan',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            // Posts list
            return Column(
              children: controller.userPosts.map((post) {
                return PostCard(
                  post: post,
                );
              }).toList(),
            );
          }),
        ];
      case 1: // Tersimpan
        return [
          Obx(() {
            // Loading state
            if (controller.isLoadingSaved) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Saved content
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSavedSection(
                    title: 'Tempat',
                    value: '${controller.savedPlaces.length}',
                    onTap: () {
                      Get.toNamed(Routes.SAVED_PLACES);
                    },
                    assetWidget: _buildSavedPlacesGrid(),
                  ),
                  const SizedBox(height: 4),
                  _buildSavedSection(
                    title: 'Postingan',
                    value: '${controller.savedPosts.length}',
                    onTap: () {
                      Get.toNamed(Routes.SAVED_POSTS);
                    },
                    assetWidget: _buildSavedPostsGrid(),
                  ),
                ],
              ),
            );
          }),
        ];
      case 2: // Pencapaian
        return [
          Obx(() {
            // Loading state
            if (controller.isLoadingAchievements) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Achievement content
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Papan Peringkat Section
                  _buildAchievementSection(
                    title: 'Papan Peringkat',
                    value: controller.weeklyUserRank != null
                        ? '${controller.weeklyUserRank}'
                        : '-',
                    onTap: () {
                      Get.toNamed(Routes.LEADERBOARD);
                    },
                    assetWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.images.achievement,
                          height: 100,
                        ),
                        Image.asset(
                          AppAssets.images.leaderboard,
                          height: 100,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Koin & Kupon Section
                  _buildAchievementSection(
                    title: 'Koin & Kupon',
                    value: '${controller.totalCoins}',
                    onTap: () {
                      Get.toNamed(Routes.COINS_HISTORY);
                    },
                    assetWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.images.coins,
                          height: 100,
                        ),
                        Image.asset(
                          AppAssets.images.coupon,
                          height: 100,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Penghargaan Saya Section
                  _buildAchievementSection(
                    title: 'Penghargaan Saya',
                    value: '${controller.totalAchievements}',
                    onTap: () {
                      Get.toNamed(Routes.ACHIEVEMENTS);
                    },
                    assetWidget: _buildAchievementBadgesRow(),
                  ),

                  const SizedBox(height: 4),

                  // Tantangan Section
                  _buildAchievementSection(
                    title: 'Tantangan',
                    value: '${controller.totalChallenges}',
                    onTap: () {
                      Get.toNamed(Routes.CHALLENGES);
                    },
                    assetWidget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAssets.images.challenge(isFemale: false),
                          height: 100,
                        ),
                        Image.asset(
                          AppAssets.images.challenge(isFemale: true),
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ];
      default:
        return [];
    }
  }

  // ===== ACHIEVEMENT BADGE WIDGETS =====

  /// Menampilkan 3 badge achievement terbaru (seperti user_profile_view)
  Widget _buildAchievementBadgesRow() {
    final achievements = controller.userAchievements
        .where((a) => a.isCompleted == true)
        .toList();
    if (achievements.isEmpty) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.images.achievement,
            height: 100,
          ),
          Image.asset(
            AppAssets.images.leaderboard,
            height: 100,
          ),
          Image.asset(
            AppAssets.images.achievement,
            height: 100,
          ),
        ],
      );
    }

    // Ambil 3 achievement terbaru
    final displayAchievements = achievements.take(3).toList();

    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: displayAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementBadgeItem(displayAchievements[index]);
      },
    );
  }

  Widget _buildAchievementBadgeItem(UserAchievement achievement) {
    final isUnlocked = achievement.isCompleted ?? false;
    final iconUrl = achievement.iconUrl;

    final imageWidget = (iconUrl != null && iconUrl.isNotEmpty)
        ? Image.asset(
            'assets/images/achievement/$iconUrl.png',
            fit: BoxFit.cover,
            width: 100,
          )
        : Image.asset(
            AppAssets.images.unlocked,
            fit: BoxFit.cover,
            width: 75,
          );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          imageWidget,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${achievement.name}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSection({
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? assetWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSavedSectionHeader(
              title,
              value.isNotEmpty ? int.tryParse(value) ?? 0 : 0,
            ),
            const SizedBox(height: 12),
            if (value == '0' || value == '-' || value.isEmpty)
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Belum ada data',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              assetWidget ?? const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementSection({
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? assetWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildSavedSectionHeader(
              title,
              value.isNotEmpty ? int.tryParse(value) ?? 0 : 0,
            ),
            const SizedBox(height: 12),
            assetWidget ?? SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  // ===== SAVED SECTION WIDGETS =====

  Widget _buildSavedSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title ($count)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildSavedPlacesGrid() {
    final places = controller.savedPlaces;
    // Show max 5 places in horizontal scroll
    final displayPlaces = places.take(5).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayPlaces.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final place = displayPlaces[index];
          return SizedBox(
            width: 100,
            child: _buildSavedPlaceCard(place),
          );
        },
      ),
    );
  }

  Widget _buildSavedPlaceCard(SavedPlacePreview place) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: place.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: place.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundContainer,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.backgroundContainer,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : Container(
              color: AppColors.backgroundContainer,
              child: Icon(
                Icons.place,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
    );
  }

  Widget _buildSavedPostsGrid() {
    final posts = controller.savedPosts;
    // Show max 5 posts in horizontal scroll
    final displayPosts = posts.take(5).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayPosts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final post = displayPosts[index];
          return SizedBox(
            width: 100,
            child: _buildSavedPostCard(post),
          );
        },
      ),
    );
  }

  Widget _buildSavedPostCard(SavedPostPreview post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: post.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: post.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.backgroundContainer,
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.backgroundContainer,
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : Container(
              color: AppColors.backgroundContainer,
              child: Icon(
                Icons.article,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
    );
  }

  void _showShareProfileModal() {
    final user = controller.userData;
    final username = user?.username ?? '';
    final displayName = user?.name ?? 'User';
    final profileLink = username.isNotEmpty
        ? DeepLinkService.profileUrl(username)
        : 'https://snappie-team.github.io';

    Get.bottomSheet(
      ShareProfileModal(
        profileLink: profileLink,
        username: username,
        displayName: displayName,
        avatarUrl: user?.imageUrl,
        frameUrl: controller.selectedFrameUrl.value,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark,
    );
  }
}
