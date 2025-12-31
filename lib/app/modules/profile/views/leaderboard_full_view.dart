import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/data/models/leaderboard_model.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../controllers/profile_controller.dart';
import '../../shared/widgets/index.dart';

/// Leaderboard page with weekly/monthly tabs
class LeaderboardFullView extends StatefulWidget {
  const LeaderboardFullView({super.key});

  @override
  State<LeaderboardFullView> createState() => _LeaderboardFullViewState();
}

class _LeaderboardFullViewState extends State<LeaderboardFullView> {
  final ProfileController _profileController = Get.find<ProfileController>();

  bool _isLoading = true;
  List<LeaderboardEntry> _leaderboardData = [];
  int _selectedTab = 0; // 0 = weekly, 1 = monthly

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedTab == 0) {
        await _profileController.loadWeeklyLeaderboard();
      } else {
        await _profileController.loadMonthlyLeaderboard();
      }
      
      // Make a copy of the list to ensure state updates correctly
      final entries = List<LeaderboardEntry>.from(_profileController.leaderboard);
      Logger.debug('Loaded ${entries.length} leaderboard entries for ${_selectedTab == 0 ? "weekly" : "monthly"}', 'Leaderboard');
      
      setState(() => _leaderboardData = entries);
    } catch (e) {
      Logger.error('Error loading leaderboard', e, null, 'Leaderboard');
      setState(() => _leaderboardData = []);
    }

    setState(() => _isLoading = false);
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
      _loadLeaderboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Papan Peringkat',
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
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_leaderboardData.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(),
          )
        else
          _buildLeaderboardContent(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.backgroundContainer,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // User avatar
          Obx(() => AvatarWidget(
            imageUrl: _profileController.userAvatar,
            size: AvatarSize.large,
          )),
          
          const SizedBox(width: 16),
          
          // User XP and rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Obx(() => Text(
                  '${_profileController.totalExp} XP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 4),
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _profileController.userData?.username ?? '',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Peringkat ${_profileController.userRank ?? '-'}',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
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
                    'Minggu Ini',
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
                    'Bulan Ini',
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Data peringkat ${_selectedTab == 0 ? 'mingguan' : 'bulanan'} belum tersedia',
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

  Widget _buildLeaderboardContent() {
    return RefreshIndicator(
      onRefresh: _loadLeaderboard,
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
            children: [
              // Top 3 Section (show even if less than 3)
              if (_leaderboardData.isNotEmpty) _buildTop3Section(),
              
              const SizedBox(height: 16),

              // Remaining rankings (position 4+)
              _buildRankingList(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTop3Section() {
    final top3 = _leaderboardData.take(3).toList();
    
    if (top3.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Text(
          'Juara Teratas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        
        // Top 3 avatars - 2nd, 1st, 3rd order
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd place (left) - show placeholder if no entry
            if (top3.length > 1)
              _buildTopRankItem(top3[1], 2)
            else
              const SizedBox(width: 80),
            
            // 1st place (center, bigger)
            if (top3.isNotEmpty)
              _buildTopRankItem(top3[0], 1),
            
            // 3rd place (right) - show placeholder if no entry
            if (top3.length > 2)
              _buildTopRankItem(top3[2], 3)
            else
              const SizedBox(width: 80),
          ],
        ),
      ],
    );
  }

  Widget _buildTopRankItem(LeaderboardEntry entry, int position) {
    // Crown color based on position
    Color crownColor;
    switch (position) {
      case 1:
        crownColor = Colors.amber;
        break;
      case 2:
        crownColor = Colors.grey[400]!;
        break;
      case 3:
        crownColor = Colors.brown[300]!;
        break;
      default:
        crownColor = Colors.transparent;
    }

    // Size based on position
    final isFirst = position == 1;
    final avatarSize = isFirst ? AvatarSize.large : AvatarSize.medium;
    final crownSize = isFirst ? 28.0 : 22.0;
    final borderWidth = isFirst ? 3.0 : 2.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown
        Icon(
          Icons.workspace_premium,
          color: crownColor,
          size: crownSize,
        ),
        const SizedBox(height: 4),
        
        // Avatar with border
        Container(
          padding: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: crownColor,
              width: borderWidth,
            ),
          ),
          child: AvatarWidget(
            imageUrl: entry.imageUrl ?? 'avatar_f1_hdpi.png',
            size: avatarSize,
          ),
        ),
        const SizedBox(height: 8),
        
        // Username
        SizedBox(
          width: 85,
          child: Text(
            entry.username ?? entry.name ?? 'Unknown',
            style: TextStyle(
              fontSize: isFirst ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        
        // XP
        Text(
          '${entry.totalExp ?? 0} XP',
          style: TextStyle(
            fontSize: isFirst ? 13 : 12,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingList() {
    // Skip top 3, show rest
    final remainingEntries = _leaderboardData.length > 3 
        ? _leaderboardData.sublist(3) 
        : <LeaderboardEntry>[];
    
    if (remainingEntries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peringkat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        ...remainingEntries.asMap().entries.map((mapEntry) {
          final index = mapEntry.key;
          final entry = mapEntry.value;
          final isLast = index == remainingEntries.length - 1;
          return _buildRankingItem(entry, isLast);
        }),
      ],
    );
  }

  Widget _buildRankingItem(LeaderboardEntry entry, bool isLast) {
    final isCurrentUser = entry.userId == _profileController.userData?.id;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: AppColors.backgroundContainer,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 32,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Avatar
          AvatarWidget(
            imageUrl: entry.imageUrl ?? 'avatar_f1_hdpi.png',
            size: AvatarSize.small,
          ),
          
          const SizedBox(width: 12),
          
          // Username
          Expanded(
            child: Text(
              entry.username ?? entry.name ?? 'Unknown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // XP
          Text(
            '${entry.totalExp ?? 0} XP',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
