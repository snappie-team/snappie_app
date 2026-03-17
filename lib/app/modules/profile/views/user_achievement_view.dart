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
  Map<String, dynamic>? get _metadata =>
      _args?['metadata'] as Map<String, dynamic>?;

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
      final result =
          await _repository.getUserAchievements(userId: _externalUserId);
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
    final completedAchievements =
        _achievements.where((a) => a.isCompleted == true).toList();
    final hasCompleted = completedAchievements.isNotEmpty;
    final latestBadge = hasCompleted ? completedAchievements.first : null;
    final badgeAssetPath = _assetForAction(latestBadge?.criteriaAction);

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
                    onPressed:
                        hasCompleted ? _shareAchievement : () => Get.back(),
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
              child: badgeAssetPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        badgeAssetPath,
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
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.72,
                ),
                itemCount: _displayAchievements.length,
                itemBuilder: (context, index) {
                  return _buildAchievementItem(_displayAchievements[index]);
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

  /// Mengelompokkan _achievements berdasarkan [criteriaAction], lalu:
  /// - Jika ada yang completed → ambil level tertinggi yang completed
  /// - Jika belum ada yang completed → ambil level terendah (tampil terkunci)
  List<UserAchievement> get _displayAchievements {
    final Map<String, List<UserAchievement>> groups = {};
    for (final a in _achievements) {
      final key = a.criteriaAction ?? 'unknown';
      groups.putIfAbsent(key, () => []).add(a);
    }

    final result = <UserAchievement>[];
    for (final group in groups.values) {
      // Sort ascending by level
      final sorted = [
        ...group
      ]..sort((a, b) => _extractLevel(a.code).compareTo(_extractLevel(b.code)));

      final completed = sorted.where((a) => a.isCompleted == true).toList();
      if (completed.isNotEmpty) {
        // Tampilkan level tertinggi yang sudah completed
        result.add(completed.last);
      } else {
        // Belum ada yang completed — tampilkan level terendah sebagai terkunci
        result.add(sorted.first);
      }
    }
    return result;
  }

  /// Returns the local asset path based on [criteriaAction].
  /// Mapping:
  ///   checkin → love, review → streak, post → mvp,
  ///   xp/exp  → xp,   coin   → coin
  /// Falls back to null when no mapping is found.
  String? _assetForAction(String? criteriaAction) {
    final action = criteriaAction?.toLowerCase() ?? '';
    if (action.contains('checkin')) {
      return 'assets/images/achievement/achievement_love_m.png';
    } else if (action.contains('review')) {
      return 'assets/images/achievement/achievement_streak_m.png';
    } else if (action.contains('post')) {
      return 'assets/images/achievement/achievement_mvp_m.png';
    } else if (action.contains('xp') || action.contains('exp')) {
      return 'assets/images/achievement/achievement_xp_m.png';
    } else if (action.contains('coin')) {
      return 'assets/images/achievement/achievement_coin_m.png';
    }
    return null;
  }

  /// Extracts the numeric level from the achievement [code].
  /// e.g. "checkin_2" → 2, "post_3" → 3, "checkin" → 1 (default).
  int _extractLevel(String? code) {
    if (code == null) return 1;
    final match = RegExp(r'_(\d+)$').firstMatch(code);
    if (match != null) return int.tryParse(match.group(1) ?? '1') ?? 1;
    return 1;
  }

  /// Wraps [child] with a circular radial-gradient aura — same style as
  /// [AchievementPopupWidget._buildAchievementIcon].
  /// level 1 → no aura, level 2 → soft gold, level 3 → orange.
  Widget _buildAuraWidget({required Widget child, required int level}) {
    if (level <= 1) return child;

    // Color per level
    final List<Color> colors = switch (level) {
      1 => [
          const Color(0xFFFFD700).withOpacity(0.35), // soft gold center
          const Color(0xFFFFC107).withOpacity(0.12), // fading gold
          Colors.transparent,
        ],
      2 => [
          const Color(0xFFFF8C00).withOpacity(0.55), // orange center
          const Color(0xFFFFB300).withOpacity(0.22), // amber mid
          Colors.transparent,
        ],
      _ => [
          const Color(0xFFE65100).withOpacity(0.70), // deep orange center
          const Color(0xFFFF6D00).withOpacity(0.35), // vivid orange mid
          Colors.transparent,
        ],
    };

    // Stack: gradient fills the same bounds as child via Positioned.fill
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: colors,
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildAchievementItem(UserAchievement userAchievement) {
    final isCompleted = userAchievement.isCompleted ?? false;
    final assetPath = _assetForAction(userAchievement.criteriaAction);
    final level = _extractLevel(userAchievement.code);

    // Jika belum completed: tampilkan ikon terkunci, tanpa aura
    if (!isCompleted) {
      return GestureDetector(
        onTap: null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.images.unlocked,
                fit: BoxFit.contain,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 8),
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
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Completed: tampilkan badge asset dengan aura sesuai level
    final badgeImage = assetPath != null
        ? Image.asset(assetPath, fit: BoxFit.contain, width: 100, height: 100)
        : Image.asset(AppAssets.images.achievement,
            fit: BoxFit.contain, width: 100, height: 100);

    final imageWidget = _buildAuraWidget(child: badgeImage, level: level);

    return GestureDetector(
      onTap: () => _showAchievementDetail(userAchievement),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageWidget,
            const SizedBox(height: 8),
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
