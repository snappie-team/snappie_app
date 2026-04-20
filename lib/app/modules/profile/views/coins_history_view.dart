import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/data/models/reward_model.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/gamification_model.dart';
import '../../../data/repositories/gamification_repository_impl.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../controllers/profile_controller.dart';
import '../../shared/widgets/index.dart';
import '../../../core/services/analytics_service.dart';

/// Coins page with Kupon and Riwayat tabs
class CoinsHistoryView extends StatefulWidget {
  const CoinsHistoryView({super.key});

  @override
  State<CoinsHistoryView> createState() => _CoinsHistoryViewState();
}

class _CoinsHistoryViewState extends State<CoinsHistoryView> {
  final GamificationRepository _gamificationRepo =
      Get.find<GamificationRepository>();
  final AchievementRepository _achievementRepo =
      Get.find<AchievementRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();

  bool _isLoadingRewards = true;
  bool _isLoadingHistory = true;
  List<UserReward> _rewards = [];
  List<CoinTransaction> _transactions = [];
  int _selectedTab =
      1; // 0 = Kupon, 1 = Riwayat (default to Riwayat like mockup)

  @override
  void initState() {
    super.initState();
    Get.find<AnalyticsService>().logScreenView(screenName: 'coupon_page');
    // Ensure Indonesian locale data is loaded for DateFormat with 'id'
    initializeDateFormatting('id');
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadRewards(),
      _loadHistory(),
    ]);
  }

  Future<void> _loadRewards() async {
    setState(() => _isLoadingRewards = true);

    try {
      final result = await _achievementRepo.getAvailableRewards();
      setState(() => _rewards = result);
      Logger.debug('Loaded ${_rewards.length} available rewards', 'Coins');
    } catch (e) {
      Logger.error('Error loading available rewards', e, null, 'Coins');
    }

    setState(() => _isLoadingRewards = false);
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final transactions = await _gamificationRepo.getCoinTransactions();
      setState(() => _transactions = transactions);
      Logger.debug('Loaded ${transactions.length} coin transactions', 'Coins');
    } catch (e) {
      Logger.error('Error loading coin transactions', e, null, 'Coins');
    }

    setState(() => _isLoadingHistory = false);
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Koin',
      onRefresh: _loadData,
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        SliverToBoxAdapter(
          child: _buildTabSelector(),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 4),
        ),
        if (_selectedTab == 0)
          ..._buildKuponContentSlivers()
        else
          ..._buildRiwayatContentSlivers(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundContainer,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User avatar with teal border
          Obx(() => AvatarWidget(
                imageUrl: _profileController.userAvatar,
                size: AvatarSize.extraLarge,
              )),

          const SizedBox(height: 16),

          // Total coins
          Obx(() => Text(
                '${_profileController.totalCoins} Koin',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),

          const SizedBox(height: 4),

          // Username
          Obx(() => Text(
                _profileController.userData?.username ?? '',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: AppColors.backgroundContainer,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabChanged(0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Kupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _onTabChanged(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Riwayat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 1
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKuponContentSlivers() {
    if (_isLoadingRewards) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_rewards.isEmpty) {
      return [
        SliverFillRemaining(
            child: Center(
          child: Text(
            'Belum ada kupon tersedia', // TODO: use local keys
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        )),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _rewards.asMap().entries.map((entry) {
              final index = entry.key;
              final reward = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildRewardItem(reward, index == _rewards.length - 1),
              );
            }).toList(),
          ),
        ),
      ),
    ];
  }

  Widget _buildRewardItem(UserReward reward, bool isLast) {
    final canRedeem = reward.canRedeem ?? false;
    final alreadyRedeemed = reward.isRedeemed == true;
    // Voucher tidak aktif atau stock habis → grey out, kecuali sudah ditukar
    final isUnavailable = !alreadyRedeemed &&
        (reward.status == false || (reward.stock != null && reward.stock! <= 0));
    // Koin tidak cukup tapi voucher masih aktif → card berwarna, tombol Tukar disabled
    final hasEnoughCoins = (reward.coinRequirement ?? 0) <= _profileController.totalCoins;

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnavailable
            ? Colors.grey.withAlpha(30)
            : AppColors.warning.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnavailable
              ? Colors.grey.withAlpha(60)
              : AppColors.warning.withAlpha(60),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section: Text left, Image right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name ?? 'Kupon #${reward.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.accent,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (reward.description != null &&
                        reward.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        reward.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Reward image
              SizedBox(
                width: 72,
                height: 72,
                child: reward.imageUrl != null && reward.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: reward.imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Image.asset(
                          AppAssets.images.coupon,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.asset(
                        AppAssets.images.coupon,
                        fit: BoxFit.contain,
                      ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final boxWidth = constraints.constrainWidth();
                const dashWidth = 4.0;
                const dashHeight = 1.0;
                final dashCount = (boxWidth / (2 * dashWidth)).floor();
                return Flex(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: Axis.horizontal,
                  children: List.generate(dashCount, (_) {
                    return SizedBox(
                      width: dashWidth,
                      height: dashHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),

          // Bottom section: Coin cost left, Detail button right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Coin requirement
              Row(
                children: [
                  // Image.asset(
                  //   AppAssets.images.coin,
                  //   width: 18,
                  //   height: 18,
                  // ),
                  // const SizedBox(width: 4),
                  Text(
                    '${reward.coinRequirement ?? 0} Koin',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              // Detail button
              Builder(
                builder: (context) {
                  final isButtonDisabled = reward.isExpired == true || isUnavailable;
                  return OutlinedButton(
                    onPressed: isButtonDisabled ? null : () => _showRewardDetail(reward),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isButtonDisabled ? Colors.grey : AppColors.accent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _getRewardButtonLabel(reward),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isButtonDisabled ? Colors.grey : AppColors.accent,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    if (isUnavailable) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: card,
      );
    }

    return card;
  }

  String _getRewardButtonLabel(UserReward reward) {
    if (reward.isExpired == true) return 'Kedaluwarsa';
    if (reward.isUsed == true) return 'Lihat Kupon';
    if (reward.isRedeemed == true) return 'Pakai';
    return 'Detail';
  }

  void _showRewardDetail(UserReward reward) {
    final coinReq = reward.coinRequirement ?? 0;
    bool isLoading = false;

    // Determine phase:
    // Phase 1: Not redeemed → show "Tukar"
    // Phase 2: Redeemed but not used → show "Pakai"
    // Phase 3: Used (show code) or Expired → show "Selesai/Habis"
    bool isRedeemed = reward.isRedeemed ?? false;
    bool isUsed = reward.isUsed ?? false;
    bool isExpired = reward.isExpired ?? false;
    String? redemptionCode = reward.redemptionCode;
    String? expiresAt = reward.expiresAt;
    int? userRewardId = reward.userRewardId;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final hasEnoughCoins = coinReq <= _profileController.totalCoins;
          final canRedeem = !isRedeemed && hasEnoughCoins && (reward.stock ?? 0) > 0;

          // Determine header title and button
          String headerTitle;
          String buttonLabel;
          Color buttonColor;
          bool buttonEnabled;
          VoidCallback? buttonAction;

          if (isExpired) {
            // Expired: disabled
            headerTitle = 'Kupon';
            buttonLabel = 'Kedaluwarsa';
            buttonColor = AppColors.textSecondary.withAlpha(50);
            buttonEnabled = false;
            buttonAction = null;
          } else if (isUsed) {
            // Already used: show coupon sheet with existing code
            headerTitle = 'Kupon Kamu';
            buttonLabel = 'Lihat Kupon';
            buttonColor = AppColors.primary;
            buttonEnabled = true;
            buttonAction = () {
              if (Get.isBottomSheetOpen == true) Get.back();
              _showCouponSheet(
                reward.name ?? 'Kupon',
                redemptionCode ?? '',
                expiresAt,
              );
            };
          } else if (isRedeemed) {
            // Phase 2: Pakai
            headerTitle = 'Kupon Kamu';
            buttonLabel = 'Pakai';
            buttonColor = AppColors.primary;
            buttonEnabled = !isLoading;
            buttonAction = () async {
              if (userRewardId == null) return;
              setSheetState(() => isLoading = true);
              try {
                final result = await _achievementRepo.useReward(userRewardId!);
                final code = result['redemption_code'] as String?;
                final expiry = result['expires_at'] as String?;
                await _loadRewards();
                // Close detail sheet then open coupon sheet
                if (Get.isBottomSheetOpen == true) Get.back();
                if (code != null) {
                  _showCouponSheet(reward.name ?? 'Kupon', code, expiry);
                }
              } catch (e) {
                setSheetState(() => isLoading = false);
                Logger.error('Error using reward', e, null, 'Coins');
                AppSnackbar.error('Gagal memakai kupon. Silakan coba lagi');
              }
            };
          } else {
            // Phase 1: Tukar
            headerTitle = 'Tukar Kupon';
            buttonLabel = 'Tukar';
            buttonColor = AppColors.accent;
            buttonEnabled = canRedeem && !isLoading;
            buttonAction = () async {
              setSheetState(() => isLoading = true);
              try {
                final userRewardResult = await _achievementRepo.redeemReward(reward.id!);
                _profileController.subtractCoins(coinReq);
                setSheetState(() {
                  isRedeemed = true;
                  userRewardId = userRewardResult.id;
                  isLoading = false;
                });
                AppSnackbar.success(
                  'Kupon ${reward.name ?? ''} berhasil ditukar!',
                  title: 'Berhasil',
                );
                await _loadRewards();
              } catch (e) {
                setSheetState(() => isLoading = false);
                Logger.error('Error redeeming reward', e, null, 'Coins');
                AppSnackbar.error('Gagal menukar kupon. Silakan coba lagi');
              }
            };
          }

          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Title + Close
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        headerTitle,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppColors.textSecondary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // Reward image
                        Center(
                          child: SizedBox(
                            width: 140,
                            height: 140,
                            child: reward.imageUrl != null &&
                                    reward.imageUrl!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: reward.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorWidget: (_, __, ___) => Image.asset(
                                      AppAssets.images.coupon,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : Image.asset(
                                    AppAssets.images.coupon,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Reward name
                        Center(
                          child: Text(
                            reward.name ?? 'Kupon',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Stock info (only in phase 1)
                        if (!isRedeemed && reward.stock != null)
                          Center(
                            child: Text(
                              'Tersisa ${reward.stock} Kupon',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Description section
                        if (reward.description != null &&
                            reward.description!.isNotEmpty) ...[
                          Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (reward.additionalInfo?.deskripsi != null &&
                              reward.additionalInfo!.deskripsi!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              reward.additionalInfo!.deskripsi!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                        ],

                        // Cara Pakai section
                        if (reward.additionalInfo?.caraPakai != null &&
                            reward.additionalInfo!.caraPakai!.isNotEmpty) ...[
                          Text(
                            'Cara Pakai',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...reward.additionalInfo!.caraPakai!
                              .asMap()
                              .entries
                              .map((entry) => _buildNumberedItem(
                                  entry.key + 1, entry.value)),
                          const SizedBox(height: 16),
                        ],

                        // Syarat dan Ketentuan section
                        if (reward.additionalInfo?.syaratKetentuan != null &&
                            reward.additionalInfo!.syaratKetentuan!
                                .isNotEmpty) ...[
                          Text(
                            'Syarat dan Ketentuan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ...reward.additionalInfo!.syaratKetentuan!
                              .asMap()
                              .entries
                              .map((entry) => _buildNumberedItem(
                                  entry.key + 1, entry.value)),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom: Action button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundContainer,
                    border: Border(
                      top: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Phase 1: Show coin cost info
                      if (!isRedeemed) ...[
                        if (!hasEnoughCoins)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Koin kamu belum cukup untuk menukar kupon ini',
                              style: TextStyle(
                                fontSize: FontSize.getSize(
                                    FontSizeOption.mediumSmall),
                                color: AppColors.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text.rich(
                              maxLines: 2,
                              TextSpan(
                                text:
                                    'Tukar ${reward.name ?? 'Kupon'} dengan ',
                                style: TextStyle(
                                  fontSize: FontSize.getSize(
                                      FontSizeOption.mediumSmall),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: '$coinReq Koin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],

                      // Phase 2: Show "Pakai" info
                      if (isRedeemed && !isUsed && !isExpired)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Tekan "Pakai" untuk mengaktifkan kode kupon',
                            style: TextStyle(
                              fontSize:
                                  FontSize.getSize(FontSizeOption.mediumSmall),
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: buttonEnabled ? buttonAction : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            disabledBackgroundColor:
                                AppColors.textSecondary.withAlpha(50),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            AppColors.textOnPrimary),
                                  ),
                                )
                              : Text(
                                  buttonLabel,
                                  style: TextStyle(
                                    color: buttonEnabled
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontSize: FontSize.getSize(
                                        FontSizeOption.medium),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showCouponSheet(String rewardName, String code, String? expiresAt) {
    Timer? countdownTimer;
    Duration remaining = Duration.zero;

    if (expiresAt != null) {
      try {
        final expiryDate = DateTime.parse(expiresAt);
        remaining = expiryDate.difference(DateTime.now());
        if (remaining.isNegative) remaining = Duration.zero;
      } catch (_) {}
    }

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
            if (remaining.inSeconds > 0) {
              setSheetState(() {
                remaining = remaining - const Duration(seconds: 1);
              });
            } else {
              countdownTimer?.cancel();
            }
          });

          final hours = remaining.inHours;
          final minutes = remaining.inMinutes % 60;
          final seconds = remaining.inSeconds % 60;
          final countdownText = hours > 0
              ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
              : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

          return Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kode Kupon untuk $rewardName',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Code box
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.textSecondary.withAlpha(80),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: code));
                          AppSnackbar.success('Kode kupon disalin',
                              title: 'Berhasil');
                        },
                        child: Text(
                          'Salin',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (expiresAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Berlaku sampai:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    countdownText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: remaining.inSeconds > 0
                          ? AppColors.accent
                          : AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.getSize(FontSizeOption.medium),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    ).then((_) {
      countdownTimer?.cancel();
    });
  }

  String _formatExpiryDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildNumberedItem(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$number.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
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
  }

  List<Widget> _buildRiwayatContentSlivers() {
    if (_isLoadingHistory) {
      return [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_transactions.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'Belum ada riwayat koin', // TODO: use local keys
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
        ),
      ];
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(_transactions);

    return [
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groupedTransactions.entries.map((entry) {
              return _buildDateSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    ];
  }

  Map<String, List<CoinTransaction>> _groupTransactionsByDate(
      List<CoinTransaction> transactions) {
    final Map<String, List<CoinTransaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      String dateKey;

      if (transaction.createdAt != null) {
        final transactionDate = DateTime.parse(transaction.createdAt!);
        final transactionDay = DateTime(
            transactionDate.year, transactionDate.month, transactionDate.day);

        if (transactionDay == today) {
          dateKey = 'Hari ini';
        } else if (transactionDay == yesterday) {
          dateKey = 'Kemarin';
        } else {
          dateKey = DateFormat('d MMMM yyyy', 'id').format(transactionDate);
        }
      } else {
        dateKey = 'Lainnya';
      }

      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  Widget _buildDateSection(
      String dateLabel, List<CoinTransaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Text(
            dateLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Transactions for this date
        ...transactions.asMap().entries.map((entry) {
          final index = entry.key;
          final transaction = entry.value;
          final isLast = index == transactions.length - 1;
          return _buildTransactionItem(transaction, isLast);
        }),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionItem(CoinTransaction transaction, bool isLast) {
    final isPositive = (transaction.amount ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.backgroundContainer,
                  width: 1,
                ),
              ),
      ),
      child: Row(
        children: [
          // Coin icon (gold coin image)
          Container(
            width: 48,
            height: 48,
            child: Image.asset(
              AppAssets.images.coin,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction description
          Expanded(
            child: Text(
              _getTransactionTitle(transaction),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Amount
          Text(
            '${isPositive ? '+' : ''}${transaction.amount} Koin',
            style: TextStyle(
              color: isPositive ? AppColors.accent : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionTitle(CoinTransaction transaction) {
    final type = transaction.type;
    final isPositive = (transaction.amount ?? 0) > 0;

    if (type == null) {
      return isPositive ? 'Berhasil mendapatkan Koin' : 'Menggunakan Koin';
    }

    // Map type to Indonesian labels
    switch (type.toLowerCase()) {
      case 'review':
        return 'Berhasil mendapatkan Koin';
      case 'checkin':
        return 'Berhasil mendapatkan Koin';
      case 'post':
        return 'Berhasil mendapatkan Koin';
      case 'redeem':
        return 'Menukar Kupon';
      case 'bonus':
        return 'Bonus Koin';
      default:
        return isPositive ? 'Berhasil mendapatkan Koin' : 'Menggunakan Koin';
    }
  }
}
