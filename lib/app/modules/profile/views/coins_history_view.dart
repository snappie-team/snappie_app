import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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

    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canRedeem
            ? AppColors.warning.withAlpha(30)
            : Colors.grey.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canRedeem
              ? AppColors.warning.withAlpha(60)
              : Colors.grey.withAlpha(60),
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
                    ? Image.network(
                        reward.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Image.asset(
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
              OutlinedButton(
                onPressed: canRedeem ? () => _showRewardDetail(reward) : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Detail',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!canRedeem) {
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

  void _showRewardDetail(UserReward reward) {
    final coinReq = reward.coinRequirement ?? 0;
    final canRedeem = reward.canRedeem ?? false;

    Get.bottomSheet(
      Container(
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
                    'Tukar Kupon',
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
                            ? Image.network(
                                reward.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
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

                    // Stock info
                    if (reward.stock != null)
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
                      const SizedBox(height: 6),
                      Text(
                        reward.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Cara Pakai section
                    Text(
                      'Cara Pakai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildNumberedItem(1, 'Tukar kupon dengan $coinReq Koin.'),
                    _buildNumberedItem(
                        2, 'Tekan "Pakai" saat akan melakukan pembayaran.'),
                    _buildNumberedItem(
                        3, 'Berikan kode kupon yang muncul saat pembayaran.'),

                    const SizedBox(height: 16),

                    // Syarat dan Ketentuan section
                    Text(
                      'Syarat dan Ketentuan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildNumberedItem(1,
                        'Kupon berlaku selama 3 hari setelah penukaran dengan koin.'),
                    _buildNumberedItem(2,
                        'Kode kupon yang muncul setelah tekan "Pakai" hanya berlaku selama 1 jam.'),
                    _buildNumberedItem(3,
                        'Kode kupon hanya dapat digunakan 1 kali saat pembayaran.'),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Bottom: Coin cost + Tukar button
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tukar ${reward.name ?? 'Kupon'} dengan ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$coinReq Koin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canRedeem
                          ? () {
                              // TODO: Call redeem API
                              Navigator.pop(context);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor: AppColors.border,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      child: Text(
                        'Tukar',
                        style: TextStyle(
                          color: canRedeem
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 16,
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
      ),
      isScrollControlled: true,
    );
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
