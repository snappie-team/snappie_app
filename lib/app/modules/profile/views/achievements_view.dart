import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_state_widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../controllers/profile_controller.dart';

/// Full page view for user achievements
class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  final AchievementRepository _repository = Get.find<AchievementRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();
  
  bool _isLoading = true;
  List<Achievement> _achievements = [];

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
        final result = await _repository.getAchievements(userId);
        setState(() {
          _achievements = result.items ?? [];
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
        SliverToBoxAdapter(
          child: _buildHeaderSection(),
        ),
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_achievements.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildAchievementItem(_achievements[index]),
                childCount: _achievements.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          // Trophy icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: AppColors.accent,
              size: 48,
            ),
          ),          
          const SizedBox(height: 16),
          
          Text(
            'Total Penghargaan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${_achievements.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Terus kumpulkan penghargaan!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      iconData: Icons.emoji_events_outlined,
      title: 'Belum ada penghargaan',
      subtitle: 'Selesaikan tantangan untuk mendapat penghargaan!',
    );
  }

  Widget _buildAchievementItem(Achievement achievement) {
    final isUnlocked = achievement.status ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? AppColors.accentContainer.withOpacity(0.8)
                  : AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_events,
              color: isUnlocked ? AppColors.accent : AppColors.textTertiary,
              size: 28,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Penghargaan #${achievement.achievementId}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (achievement.additionalInfo?.progress != null)
                  Text(
                    'Progress: ${achievement.additionalInfo!.progress}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  isUnlocked ? 'Terbuka' : 'Terkunci',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUnlocked ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // Status
          Icon(
            isUnlocked ? Icons.check_circle : Icons.lock,
            color: isUnlocked ? Colors.green : Colors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }
}
