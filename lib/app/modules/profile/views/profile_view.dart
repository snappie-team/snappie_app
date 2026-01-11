import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/user_model.dart';
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
        // Tab Bar (Clickable)
        SliverToBoxAdapter(
          child: Container(
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
          ),
        ),

        // Tab Content - wrapped in Obx for reactivity
        Obx(() => SliverList(
              delegate: SliverChildListDelegate(_buildTabContent()),
            )),
      ],
    );
    // ]);
  }

  Widget _buildHeader() {
    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(color: AppColors.border),
      // ),
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
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
                    icon: AppIcon(AppAssets.iconsSvg.addFriend, color: AppColors.primary),
                    backgroundColor: AppColors.backgroundContainer,
                    onPressed: () => Get.toNamed(Routes.INVITE_FRIENDS),
                  ),
                  const SizedBox(width: 8),
                  ButtonWidget(
                    icon: AppIcon(AppAssets.iconsSvg.share, color: AppColors.primary),
                    backgroundColor: AppColors.backgroundContainer,
                    onPressed: () => _showShareProfileModal(),
                  ),
                  const SizedBox(width: 8),
                  ButtonWidget(
                    icon: AppIcon(AppAssets.iconsSvg.setting, color: AppColors.primary),
                    backgroundColor: AppColors.backgroundContainer,
                    onPressed: () => Get.toNamed(Routes.SETTINGS),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Profile Avatar with frame
          FutureBuilder<String?>(
            future: _getSelectedFrameUrl(),
            builder: (context, snapshot) {
              final frameUrl = snapshot.data;
              return Obx(() => AvatarWidget(
                    imageUrl: controller.userAvatar,
                    size: AvatarSize.extraLarge,
                    frameUrl: frameUrl,
                  ));
            },
          ),

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
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
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
          padding: const EdgeInsets.all(12),
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
              return Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada postingan',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai berbagi pengalaman Anda!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

            // Empty state
            if (controller.savedPlaces.isEmpty &&
                controller.savedPosts.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada yang tersimpan',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
                    value: controller.userRank != null
                        ? '#${controller.userRank}'
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
                        Image.asset(
                          AppAssets.images.achievement,
                          height: 100,
                        ),
                      ],
                    ),
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

  Widget _buildSavedSection({
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? assetWidget,
  }) {
    return Container(
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
            onViewAll: onTap,
          ),
          const SizedBox(height: 12),
          assetWidget ?? SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _buildAchievementSection({
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? assetWidget,
  }) {
    return Container(
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
            onViewAll: onTap,
          ),
          const SizedBox(height: 12),
          assetWidget ?? SizedBox.shrink()
        ],
      ),
    );
  }

  // ===== SAVED SECTION WIDGETS =====

  Widget _buildSavedSectionHeader(String title, int count,
      {VoidCallback? onViewAll}) {
    return GestureDetector(
      onTap: onViewAll,
      child: Row(
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
      ),
    );
  }

  Widget _buildSavedPlacesGrid() {
    final places = controller.savedPlaces;
    // Show max 4 places in 2x2 grid
    final displayPlaces = places.take(2).toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: displayPlaces.length,
      itemBuilder: (context, index) {
        final place = displayPlaces[index];
        return _buildSavedPlaceCard(place);
      },
    );
  }

  Widget _buildSavedPlaceCard(SavedPlacePreview place) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: place.imageUrl != null
          ? Image.network(
              place.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
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
    // Show max 4 posts in 2x2 grid
    final displayPosts = posts.take(2).toList();

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: displayPosts.length,
      itemBuilder: (context, index) {
        final post = displayPosts[index];
        return _buildSavedPostCard(post);
      },
    );
  }

  Widget _buildSavedPostCard(SavedPostPreview post) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: post.imageUrl != null
          ? Image.network(
              post.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
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

  Future<String?> _getSelectedFrameUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_frame_url');
  }

  void _showShareProfileModal() {
    final user = controller.userData;
    final username = user?.username ?? '';
    final displayName = user?.name ?? 'User';
    final profileLink = username.isNotEmpty
        ? 'https://snappie.app/u/$username'
        : 'https://snappie.app/profile';

    Get.bottomSheet(
      ShareProfileModal(
        profileLink: profileLink,
        username: username,
        displayName: displayName,
        avatarUrl: user?.imageUrl,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark,
    );
  }
}
