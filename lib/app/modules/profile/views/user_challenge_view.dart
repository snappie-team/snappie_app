import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/errors/exceptions.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_display_widgets/app_icon.dart';
import 'package:snappie_app/app/modules/shared/widgets/_state_widgets/empty_state_widget.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../../shared/layout/controllers/main_controller.dart';
import '../../../routes/app_pages.dart';
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

  /// Arguments dari navigasi (dari notifikasi)
  Map<String, dynamic>? get _args => Get.arguments as Map<String, dynamic>?;
  bool get _autoShowPopup => _args?['autoShowPopup'] == true;
  Map<String, dynamic>? get _metadata => _args?['metadata'] as Map<String, dynamic>?;

  bool _hasAutoShownPopup = false;
  bool _isLoading = true;
  bool _isClaimLoading = false;
  List<UserAchievement> _challenges = [];

  @override
  void initState() {
    super.initState();
    _profileController.initializeIfNeeded();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);

    try {
      // Ensure profile data is loaded first
      if (_profileController.userData == null) {
        await _profileController.loadUserProfile();
      }
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

    // Auto-show popup dari notifikasi
    if (_autoShowPopup && !_hasAutoShownPopup && _challenges.isNotEmpty) {
      _hasAutoShownPopup = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _autoShowChallengePopup();
      });
    }
  }

  /// Tampilkan detail challenge otomatis dari notifikasi
  void _autoShowChallengePopup() {
    UserAchievement? target;
    if (_metadata != null) {
      final challengeId = _metadata!['challenge_id'] as int?;
      final challengeCode = _metadata!['code'] as String?;
      if (challengeId != null) {
        target = _challenges.cast<UserAchievement?>().firstWhere(
              (c) => c!.id == challengeId,
              orElse: () => null,
            );
      }
      if (target == null && challengeCode != null) {
        target = _challenges.cast<UserAchievement?>().firstWhere(
              (c) => c!.code == challengeCode,
              orElse: () => null,
            );
      }
    }
    // Jika tidak ditemukan dari metadata, tampilkan yang terbaru
    target ??= _challenges.cast<UserAchievement?>().firstWhere(
          (c) => c!.isCompleted == true,
          orElse: () => null,
        );
    if (target != null) {
      _buildDetailChallenge(target);
    }
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

  /// Navigate to the relevant page based on criteria_action
  void _navigateToChallengeAction(String? criteriaAction) {
    // Close bottom sheet first
    if (Get.isBottomSheetOpen == true) Get.back();

    final mainController = Get.find<MainController>();

    switch (criteriaAction?.toLowerCase()) {
      // Explore-related actions → Explore tab
      case 'checkin':
      case 'review':
        Get.until((route) => route.settings.name == AppPages.MAIN);
        mainController.changeTab(1);
        break;
      // Home/feed-related actions → Home tab
      case 'post':
      case 'like':
      case 'comment':
      case 'follow':
        Get.until((route) => route.settings.name == AppPages.MAIN);
        mainController.changeTab(0);
        break;
      // Leaderboard
      case 'top_rank':
        Get.toNamed(AppPages.LEADERBOARD);
        break;
      // Coin/XP → back to profile
      default:
        Get.until((route) => route.settings.name == AppPages.MAIN);
        mainController.changeTab(3);
        break;
    }
  }

  Widget _buildChallengeItem(UserAchievement challenge) {
    final isCompleted = challenge.isCompleted ?? false;
    final isClaimed = challenge.isClaimed ?? false;

    // Tentukan warna background berdasarkan state
    Color bgColor;
    if (isCompleted && isClaimed) {
      bgColor = AppColors.textSecondary.withAlpha(20);
    } else if (isCompleted && !isClaimed) {
      bgColor = AppColors.primaryLight.withAlpha(50);
    } else {
      bgColor = AppColors.warning.withAlpha(25);
    }

    void _onTap() {
      if (isCompleted && !isClaimed) {
        _showClaimConfirmDialog(challenge);
      } else {
        _buildDetailChallenge(challenge);
      }
    }
    
    return GestureDetector(
      onTap: _onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
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
                  // State 3: Sudah diklaim
                  if (isCompleted && isClaimed)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withAlpha(50),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // State 2: Selesai, belum diklaim → tampilkan tombol klaim
                  else if (isCompleted && !isClaimed)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ambil Hadiah',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // State 1: Belum selesai → progress bar
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
                                  AppColors.accent.withAlpha(125)),
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
            if (!isCompleted && !isClaimed)
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

  /// Tampilkan modal konfirmasi sebelum klaim hadiah
  void _showClaimConfirmDialog(UserAchievement challenge) async {
    final coins = challenge.rewardCoins ?? 0;
    final xp = challenge.rewardXp ?? 0;

    // Susun teks reward
    final rewardParts = <String>[];
    if (xp > 0) rewardParts.add('$xp XP');
    if (coins > 0) rewardParts.add('$coins Koin');
    final rewardText = rewardParts.isNotEmpty
        ? 'Klaim ${rewardParts.join(' dan ')} Kamu!'
        : 'Klaim hadiah kamu!';

    final confirmed = await MissionSuccessModal.show(
      title: 'Tantangan Berhasil!',
      description: 'Selesaikan tantangan selanjutnya.\n$rewardText',
    );

    if (confirmed == true) {
      _claimChallenge(challenge);
    }
  }

  /// Klaim hadiah challenge
  Future<void> _claimChallenge(UserAchievement challenge) async {
    if (_isClaimLoading) return;

    setState(() => _isClaimLoading = true);

    try {
      final challengeId = challenge.userAchievementId ?? challenge.id;
      if (challengeId == null) {
        throw Exception('Challenge ID tidak ditemukan');
      }

      final result = await _repository.claimChallenge(challengeId);

      // Update koin dan XP di ProfileController
      final coins = result.challenge?.rewardCoins ?? challenge.rewardCoins ?? 0;
      final xp = result.challenge?.rewardXp ?? challenge.rewardXp ?? 0;
      if (coins > 0) _profileController.addCoins(coins);
      if (xp > 0) _profileController.addExp(xp);

      // Tutup bottom sheet
      if (Get.isBottomSheetOpen == true) Get.back();

      // Tampilkan snackbar sukses
      AppSnackbar.success(
        '+$coins Koin  •  +$xp XP',
        title: 'Hadiah Diklaim! 🎉',
      );

      // Reload daftar challenge
      await _loadChallenges();
    } on ConflictException catch (_) {
      if (Get.isBottomSheetOpen == true) Get.back();
      AppSnackbar.warning(
        'Hadiah tantangan ini sudah pernah diklaim',
        title: 'Sudah Diklaim',
      );
      await _loadChallenges();
    } catch (e) {
      Logger.error('Error claiming challenge', e, null, 'UserChallengesView');
      setState(() => _isClaimLoading = false);
      AppSnackbar.error('Gagal mengklaim hadiah. Silakan coba lagi');
    }
  }

  void _buildDetailChallenge(UserAchievement challenge) {
    final isCompleted = challenge.isCompleted ?? false;
    final isClaimed = challenge.isClaimed ?? false;
    _isClaimLoading = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
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
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        _getChallengeAsset(challenge.criteriaAction),
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
                      ),
                    ),
                  ),

                  // Content
                  Text.rich(
                    TextSpan(
                      text: 'Selesaikan Tantangan ',
                      style: TextStyle(
                        fontSize: FontSize.getSize(FontSizeOption.regular),
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text: challenge.name ?? 'Tantangan',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: ' dengan cara:',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),


                  // Cara Kerja section from additional_info
                  if (challenge.additionalInfo != null &&
                      challenge.additionalInfo!['cara_kerja'] != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._buildCaraKerjaItems(
                            List<String>.from(
                                challenge.additionalInfo!['cara_kerja']),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Action button
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      child: _buildDetailActionButton(
                        challenge: challenge,
                        isCompleted: isCompleted,
                        isClaimed: isClaimed,
                        isLoading: _isClaimLoading,
                        setSheetState: setSheetState,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Tombol aksi di bottom sheet berdasarkan state challenge
  Widget _buildDetailActionButton({
    required UserAchievement challenge,
    required bool isCompleted,
    required bool isClaimed,
    required bool isLoading,
    required StateSetter setSheetState,
  }) {
    // State: Sudah diklaim
    if (isCompleted && isClaimed) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textSecondary.withAlpha(50),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
          elevation: 0,
        ),
        onPressed: null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Sudah Diklaim',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // State: Selesai, belum diklaim → tombol klaim
    if (isCompleted && !isClaimed) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        onPressed: isLoading ? null : () => _showClaimConfirmDialog(challenge),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ambil Hadiah',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      );
    }

    // State: Belum selesai → navigasi ke action
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
        ),
      ),
      onPressed: () => _navigateToChallengeAction(challenge.criteriaAction),
      child: Text(
        _getChallengeActionLabel(challenge.criteriaAction),
        style: TextStyle(
          color: AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildCaraKerjaItems(List<String> steps) {
    return steps.asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '${entry.key + 1}.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            Expanded(
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
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
