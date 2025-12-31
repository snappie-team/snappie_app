import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_state_widgets/empty_state_widget.dart';
import '../../../core/constants/app_colors.dart';
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
      print('❌ Error loading challenges: $e');
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
        else ..._buildChallengeSliversBySchedule(),
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

  Widget _buildChallengeItem(UserAchievement challenge) {
    final isCompleted = challenge.isCompleted ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: challenge.isCompleted == true
            ? AppColors.background
            : AppColors.accentLight,
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
          // Icon from iconUrl or default
          challenge.iconUrl != null && challenge.iconUrl!.isNotEmpty
              ? Image.network(
                  challenge.iconUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.flag,
                      color:
                          isCompleted ? AppColors.success : AppColors.primary,
                      size: 24,
                    );
                  },
                )
              : Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.successSurface
                        : AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.flag,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    size: 24,
                  ),
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
                if (isCompleted)
                  Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  )
                else if (challenge.progress != null && challenge.target != null) ...[
                  Text(
                    'Progress: ${challenge.progress ?? 0}/${challenge.target ?? 0}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: (challenge.progress ?? 0) /
                                (challenge.target ?? 1),
                            backgroundColor: AppColors.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 16,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Detail arrow
          GestureDetector(
            onTap: () => _buildDetailChallenge(challenge),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        ],
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
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successSurface
                      : AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: challenge.iconUrl != null &&
                        challenge.iconUrl!.isNotEmpty
                    ? Image.network(
                        challenge.iconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.flag,
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.primary,
                            size: 50,
                          );
                        },
                      )
                    : Icon(
                        Icons.flag,
                        color:
                            isCompleted ? AppColors.success : AppColors.primary,
                        size: 50,
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (challenge.description != null &&
                      challenge.description!.isNotEmpty) ...[
                    Text(
                      challenge.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Progress section
                  if (!isCompleted &&
                      challenge.progress != null &&
                      challenge.target != null) ...[
                    Text(
                      'Progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (challenge.progress ?? 0) /
                                  (challenge.target ?? 1),
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${challenge.progress ?? 0}/${challenge.target ?? 0}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Rewards section
                  if (challenge.rewardCoins != null ||
                      challenge.rewardXp != null) ...[
                    Text(
                      'Hadiah',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (challenge.rewardCoins != null)
                          Expanded(
                            child: _buildSimpleRewardCard(
                              icon: Icons.monetization_on,
                              label: 'Coins',
                              value: challenge.rewardCoins.toString(),
                              color: AppColors.accent,
                            ),
                          ),
                        if (challenge.rewardCoins != null &&
                            challenge.rewardXp != null)
                          const SizedBox(width: 12),
                        if (challenge.rewardXp != null)
                          Expanded(
                            child: _buildSimpleRewardCard(
                              icon: Icons.star,
                              label: 'XP',
                              value: challenge.rewardXp.toString(),
                              color: AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Tutup',
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
