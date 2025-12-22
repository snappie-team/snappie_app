import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:snappie_app/app/data/models/reward_model.dart';
import '../../../core/constants/app_colors.dart';
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
  final GamificationRepository _gamificationRepo = Get.find<GamificationRepository>();
  final AchievementRepository _achievementRepo = Get.find<AchievementRepository>();
  final ProfileController _profileController = Get.find<ProfileController>();

  bool _isLoadingRewards = true;
  bool _isLoadingHistory = true;
  List<UserReward> _rewards = [];
  List<CoinTransaction> _transactions = [];
  int _selectedTab = 1; // 0 = Kupon, 1 = Riwayat (default to Riwayat like mockup)

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
      final userId = _profileController.userData?.id;
      if (userId != null) {
        final result = await _achievementRepo.getUserRewards(userId);
        setState(() => _rewards = result.items ?? []);
        print('✅ Loaded ${_rewards.length} rewards');
      }
    } catch (e) {
      print('❌ Error loading rewards: $e');
    }

    setState(() => _isLoadingRewards = false);
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);

    try {
      final transactions = await _gamificationRepo.getCoinTransactions();
      setState(() => _transactions = transactions);
      print('✅ Loaded ${transactions.length} coin transactions');
    } catch (e) {
      print('❌ Error loading coin transactions: $e');
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundContainer,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Koin',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with user avatar and coins
          _buildHeader(),

          const SizedBox(height: 4),

          // Tab selector
          _buildTabSelector(),

          const SizedBox(height: 4),

          // Content
          Expanded(
            child: _selectedTab == 0 ? _buildKuponContent() : _buildRiwayatContent(),
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 3,
              ),
            ),
            child: Obx(() => AvatarWidget(
              imageUrl: _profileController.userAvatar,
              size: AvatarSize.large,
            )),
          ),

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
                    color: _selectedTab == 0 ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Kupon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
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
                    color: _selectedTab == 1 ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Riwayat',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
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

  Widget _buildKuponContent() {
    if (_isLoadingRewards) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_rewards.isEmpty) {
      return _buildEmptyState(
        icon: Icons.card_giftcard,
        title: 'Belum ada kupon',
        subtitle: 'Kumpulkan koin untuk menukar kupon',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRewards,
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
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _rewards.length,
          itemBuilder: (context, index) {
            final reward = _rewards[index];
            return _buildRewardItem(reward, index == _rewards.length - 1);
          },
        ),
      ),
    );
  }

  Widget _buildRewardItem(UserReward reward, bool isLast) {
    final isRedeemed = reward.status == true;

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
          // Coin icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Text(
              reward.additionalInfo?.redemptionCode ?? 'Kupon #${reward.id}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Status
          if (isRedeemed)
            const Icon(Icons.check_circle, color: Colors.green, size: 24)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Tukar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRiwayatContent() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'Belum ada riwayat',
        subtitle: 'Riwayat transaksi koin akan muncul di sini',
      );
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(_transactions);

    return RefreshIndicator(
      onRefresh: _loadHistory,
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groupedTransactions.entries.map((entry) {
              return _buildDateSection(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Map<String, List<CoinTransaction>> _groupTransactionsByDate(List<CoinTransaction> transactions) {
    final Map<String, List<CoinTransaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      String dateKey;
      
      if (transaction.createdAt != null) {
        final transactionDate = DateTime.parse(transaction.createdAt!);
        final transactionDay = DateTime(transactionDate.year, transactionDate.month, transactionDate.day);
        
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

  Widget _buildDateSection(String dateLabel, List<CoinTransaction> transactions) {
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
              'assets/images/coin.png',
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
}
