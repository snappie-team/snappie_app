import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_display_widgets/app_icon.dart';
import 'package:snappie_app/app/modules/shared/widgets/_state_widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../controllers/profile_controller.dart';

/// Full page view for user challenges
class UserChallengesView extends StatefulWidget {
  const UserChallengesView({super.key});

  @override
  State<UserChallengesView> createState() => _UserChallengesViewState();
}

class _UserChallengesViewState extends State<UserChallengesView> {
  final AchievementRepository _repository = Get.find<AchievementRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();

  bool _isLoading = true;
  List<UserAchievement> _challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);

    try {
      final userId = _profileController.userData?.id;
      if (userId != null) {
        final result = await _repository.getUserChallenges();
        setState(() {
          _challenges = result;
        });
      }
    } catch (e) {
      Logger.error('Error loading challenges', e, null, 'UserChallengesView');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Tantangan',
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
        if (_isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (_challenges.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(),
          )
        else
          ..._buildChallengeSliversBySchedule(),
      ],
    );
  }

  List<Widget> _buildChallengeSliversBySchedule() {
    final List<Widget> slivers = [];

    // Harian (daily)
    if (_getChallengesBySchedule(ResetSchedule.daily).isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: _buildListChallenge('Tantangan Harian', ResetSchedule.daily),
      ));
      slivers.add(const SliverToBoxAdapter(
        child: SizedBox(height: 12),
      ));
    }

    // Mingguan (weekly)
    if (_getChallengesBySchedule(ResetSchedule.weekly).isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: _buildListChallenge('Tantangan Mingguan', ResetSchedule.weekly),
      ));
      slivers.add(const SliverToBoxAdapter(
        child: SizedBox(height: 12),
      ));
    }

    // Sekali Saja (none)
    if (_getChallengesBySchedule(ResetSchedule.none).isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: _buildListChallenge('Tantangan Sekali Saja', ResetSchedule.none),
      ));
    }

    return slivers;
  }

  Widget _buildEmptyState() {
    return const EmptyStateWidget(
      iconData: Icons.flag_outlined,
      title: 'Belum ada tantangan',
      subtitle: 'Tantangan baru akan segera hadir!',
    );
  }

  List<UserAchievement> _getChallengesBySchedule(ResetSchedule schedule) {
    return _challenges.where((c) {
      final resetSchedule = ResetSchedule.fromString(c.resetSchedule);
      return resetSchedule == schedule;
    }).toList();
  }

  Widget _buildListChallenge(String title, ResetSchedule schedule) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._getChallengesBySchedule(schedule)
              .map((challenge) => _buildChallengeItem(challenge)),
        ],
      ),
    );
  }

  /// Returns the appropriate asset path based on criteria_action
  String _getChallengeAsset(String? criteriaAction) {
    switch (criteriaAction?.toLowerCase()) {
      // Content creation → camera
      case 'checkin':
      case 'post':
        return AppAssets.images.camera;
      // Writing review → review
      case 'review':
        return AppAssets.images.review;
      // Social engagement → photo
      case 'like':
      case 'comment':
      case 'follow':
        return AppAssets.images.photo;
      // Rewards & ranking → rating
      case 'coin_earned':
      case 'xp_earned':
      case 'top_rank':
        return AppAssets.images.rating;
      default:
        return AppAssets.images.camera;
    }
  }

  /// Returns the action button label based on criteria_action
  String _getChallengeActionLabel(String? criteriaAction) {
    switch (criteriaAction?.toLowerCase()) {
      case 'checkin':
        return 'Check-in Sekarang';
      case 'review':
        return 'Cari Tempat Favoritmu';
      case 'post':
        return 'Buat Postingan';
      case 'like':
        return 'Jelajahi Postingan';
      case 'comment':
        return 'Berikan Komentar';
      case 'follow':
        return 'Temukan Teman';
      case 'coin_earned':
        return 'Kumpulkan Koin';
      case 'xp_earned':
        return 'Raih XP';
      case 'top_rank':
        return 'Lihat Leaderboard';
      default:
        return 'Mulai Tantangan';
    }
  }

  Widget _buildChallengeItem(UserAchievement challenge) {
    final isCompleted = challenge.isCompleted ?? false;

    return GestureDetector(
      onTap: () => _buildDetailChallenge(challenge),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: challenge.isCompleted == true
              ? AppColors.primaryLight.withAlpha(75)
              : AppColors.warning.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              _getChallengeAsset(challenge.criteriaAction),
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.flag,
                  color: isCompleted ? AppColors.success : AppColors.primary,
                  size: 24,
                );
              },
            ),

            const SizedBox(width: 12),

            // Name, progress, target
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name ?? 'Tantangan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (isCompleted)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: Center(
                        child: Text(
                          'Selesai',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    )
                  else if (challenge.progress != null &&
                      challenge.target != null)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 24,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: (challenge.progress ?? 0) /
                                  (challenge.target ?? 1),
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accent),
                            ),
                          ),
                        ),
                        Text(
                          '${challenge.progress ?? 0}/${challenge.target ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Detail arrow
            if (!isCompleted)
              AppIcon(
                AppAssets.icons.moreOption3,
                color: AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _buildDetailChallenge(UserAchievement challenge) {
    final isCompleted = challenge.isCompleted ?? false;

    Get.bottomSheet(Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  _getChallengeAsset(challenge.criteriaAction),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.flag,
                      color:
                          isCompleted ? AppColors.success : AppColors.primary,
                      size: 50,
                    );
                  },
                ),
              ),
            ),

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Description
                if (challenge.subtitle != null &&
                    challenge.subtitle!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      challenge.subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                if (challenge.description != null &&
                    challenge.description!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      challenge.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // Action button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  // TODO: Navigate to the corresponding action page
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _getChallengeActionLabel(challenge.criteriaAction),
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildSimpleRewardCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
