import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/gamification_response_model.dart';
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

  /// Arguments dari navigasi (dari notifikasi)
  Map<String, dynamic>? get _args => Get.arguments as Map<String, dynamic>?;
  int? get _externalUserId => _args?['userId'] as int?;
  bool get _autoShowPopup => _args?['autoShowPopup'] == true;
  Map<String, dynamic>? get _metadata => _args?['metadata'] as Map<String, dynamic>?;

  bool _hasAutoShownPopup = false;

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
      final result = await _repository.getUserAchievements(userId: _externalUserId);
      setState(() {
        _achievements = result;
      });
    } catch (e) {
      Logger.error(
          'Error loading achievements', e, null, 'UserAchievementView');
    }

    setState(() => _isLoading = false);

    // Auto-show popup dari notifikasi
    if (_autoShowPopup && !_hasAutoShownPopup && _achievements.isNotEmpty) {
      _hasAutoShownPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _autoShowAchievementPopup();
      });
    }
  }

  /// Tampilkan popup achievement otomatis dari notifikasi
  void _autoShowAchievementPopup() {
    // Cari achievement berdasarkan metadata dari notifikasi
    UserAchievement? target;
    if (_metadata != null) {
      final achievementId = _metadata!['achievement_id'] as int?;
      final achievementCode = _metadata!['code'] as String?;
      if (achievementId != null) {
        target = _achievements.cast<UserAchievement?>().firstWhere(
              (a) => a!.id == achievementId,
              orElse: () => null,
            );
      }
      if (target == null && achievementCode != null) {
        target = _achievements.cast<UserAchievement?>().firstWhere(
              (a) => a!.code == achievementCode,
              orElse: () => null,
            );
      }
    }
    // Jika tidak ditemukan dari metadata, tampilkan yang terbaru completed
    target ??= _achievements.cast<UserAchievement?>().firstWhere(
          (a) => a!.isCompleted == true,
          orElse: () => null,
        );
    if (target != null) {
      _showAchievementDetail(target);
    }
  }

  Widget _buildCTASection() {
    // Ambil achievement terbaru yang sudah completed
    final completedAchievements = _achievements
        .where((a) => a.isCompleted == true)
        .toList();
    final hasCompleted = completedAchievements.isNotEmpty;
    final latestBadge = hasCompleted ? completedAchievements.first : null;
    final badgeIconUrl = latestBadge?.iconUrl;

    // Cari achievement yang belum selesai dengan progress tertinggi
    final nextAchievement = !hasCompleted
        ? _achievements.cast<UserAchievement?>().firstWhere(
              (a) => a!.isCompleted != true,
              orElse: () => null,
            )
        : null;

    final ctaTitle = hasCompleted
        ? 'Penghargaan Baru: ${latestBadge!.name}'
        : 'Selesaikan penghargaan pertamamu!';
    final ctaButtonLabel = hasCompleted ? 'Bagikan' : 'Mulai Sekarang';
    final ctaButtonIcon = hasCompleted ? Icons.share : Icons.arrow_forward;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.warning.withAlpha(25),
              AppColors.textOnPrimary,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ctaTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  if (nextAchievement != null && !hasCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${nextAchievement.name} — ${nextAchievement.progress ?? 0}/${nextAchievement.target ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: hasCompleted
                        ? _shareAchievement
                        : () => Get.back(),
                    icon: Icon(ctaButtonIcon, size: 16),
                    label: Text(ctaButtonLabel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Badge terbaru atau icon default
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: (badgeIconUrl != null && badgeIconUrl.isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/achievement/$badgeIconUrl.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.emoji_events,
                      color: AppColors.accent,
                      size: 36,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareAchievement() {
    final username = _profileController.userData?.username ?? '';
    final completed = _achievements.where((a) => a.isCompleted == true).length;
    final message =
        'Saya sudah mengumpulkan $completed penghargaan di Snappie! \uD83C\uDFC6\n\nIkuti saya: @$username';
    Share.share(message, subject: 'Pencapaian Snappie');
  }

  @override
  Widget build(BuildContext context) {
    final isOtherUser = _externalUserId != null;
    return ScaffoldFrame.detail(
      title: isOtherUser ? 'Penghargaan' : 'Penghargaan Saya',
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 12),
        ),
        SliverToBoxAdapter(
          child: _buildCTASection(),
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
    final iconUrl = userAchievement.iconUrl;

    // Build the achievement image widget
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

    return GestureDetector(
      onTap: isUnlocked ? () => _showAchievementDetail(userAchievement) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Achievement icon with locked/unlocked visual state
            imageWidget,

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
                  color:
                      isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(UserAchievement userAchievement) {
    final summary = AchievementSummary(
      id: userAchievement.id,
      code: userAchievement.code,
      name: userAchievement.name,
      subtitle: userAchievement.subtitle,
      description: userAchievement.description,
      type: userAchievement.type,
      iconUrl: userAchievement.iconUrl,
      criteriaAction: userAchievement.criteriaAction,
      criteriaTarget: userAchievement.criteriaTarget,
      rewardCoins: userAchievement.rewardCoins,
      rewardXp: userAchievement.rewardXp,
      completedAt: userAchievement.completedAt,
    );

    Get.dialog(
      AchievementPopupWidget(achievement: summary),
      barrierDismissible: true,
      useSafeArea: false,
    );
  }
}
