import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../controllers/profile_controller.dart';

/// Full page view for user achievements
class UserAchievementView extends StatefulWidget {
  const UserAchievementView({super.key});

  @override
  State<UserAchievementView> createState() => _UserAchievementViewState();
}

class _UserAchievementViewState extends State<UserAchievementView> {
  final AchievementRepository _repository = Get.find<AchievementRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();

  bool _isLoading = true;
  List<UserAchievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    try {
      final userId = _profileController.userData?.id;
      if (userId != null) {
        final result = await _repository.getUserAchievements();
        setState(() {
          _achievements = result;
        });
      }
    } catch (e) {
      print('❌ Error loading achievements: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Penghargaan Saya',
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
        SliverToBoxAdapter(
          child: PromotionalBanner(
            title: 'Penghargaan Baru',
            subtitle: 'Lihat penghargaan yang telah Anda kumpulkan',
          ),
        ),
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_achievements.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(),
          )
        else
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemCount: _achievements.length,
                itemBuilder: (context, index) {
                  return _buildAchievementItem(_achievements[index]);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      iconData: Icons.emoji_events_outlined,
      title: 'Belum ada penghargaan',
      subtitle: 'Selesaikan tantangan untuk mendapat penghargaan!',
    );
  }

  Widget _buildAchievementItem(UserAchievement userAchievement) {
    final isUnlocked = userAchievement.isCompleted ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: AppColors.primary)
      ),
      // : const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Trophy icon
          isUnlocked
              ? Image.network(
                  userAchievement.iconUrl ?? '',
                  fit: BoxFit.cover,
                  width: 75,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppAssets.images.unlocked,
                      fit: BoxFit.cover,
                      width: 80,
                    );
                  },
                )
              : Image.asset(
                  AppAssets.images.unlocked,
                  fit: BoxFit.cover,
                  width: 80,
                ),

          const SizedBox(height: 12),

          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${userAchievement.name}',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
