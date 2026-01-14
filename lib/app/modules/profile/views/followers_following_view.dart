import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../data/models/social_model.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../../routes/app_pages.dart';
import '../../shared/widgets/index.dart';
import '../../shared/widgets/_display_widgets/app_icon.dart';

/// View type enum
enum FollowViewType { followers, following }

/// View for displaying followers or following list (conditional, not tabbed)
class FollowersFollowingView extends StatefulWidget {
  const FollowersFollowingView({super.key});

  @override
  State<FollowersFollowingView> createState() => _FollowersFollowingViewState();
}

class _FollowersFollowingViewState extends State<FollowersFollowingView> {
  final SocialRepository _socialRepository = Get.find<SocialRepository>();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _searchQuery = '';
  List<FollowEntry> _followers = [];
  List<FollowEntry> _following = [];
  
  // Local state to track follow status changes (userId -> isFollowed)
  final Map<int, bool> _followStatusOverrides = {};

  // Get view type from arguments (0 = followers, 1 = following)
  FollowViewType get _viewType {
    final initialTab = Get.arguments?['initialTab'] ?? 0;
    return initialTab == 0 ? FollowViewType.followers : FollowViewType.following;
  }

  // Get title based on view type
  String get _title => _viewType == FollowViewType.followers ? 'Pengikut' : 'Mengikuti';

  // Get list based on view type
  List<FollowEntry> get _currentList => 
      _viewType == FollowViewType.followers ? _followers : _following;

  // Get filtered list based on search query
  List<FollowEntry> get _filteredList {
    if (_searchQuery.isEmpty) return _currentList;
    
    final query = _searchQuery.toLowerCase();
    return _currentList.where((entry) {
      final user = _viewType == FollowViewType.followers 
          ? entry.follower 
          : entry.following;
      final name = user?.name?.toLowerCase() ?? '';
      final username = user?.username?.toLowerCase() ?? '';
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFollowData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFollowData() async {
    setState(() => _isLoading = true);

    try {
      final followData = await _socialRepository.getFollowData();
      
      _followers = followData.followers ?? [];
      _following = followData.following ?? [];

      Logger.debug('Loaded ${_followers.length} followers and ${_following.length} following', 'Social');
    } catch (e) {
      Logger.error('Error loading follow data', e, null, 'Social');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: _title,
      slivers: [
        SliverToBoxAdapter(
          child: _buildSearchBar(),
        ),
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _buildListSliver(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: 'Cari',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: AppIcon(AppAssets.icons.search, color: AppColors.textSecondary, size: 24),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  // TODO: Add clear.svg icon to assets/iconsvg/
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildListSliver() {
    if (_currentList.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    // Show no results state when search has no matches
    if (_filteredList.isEmpty && _searchQuery.isNotEmpty) {
      return SliverFillRemaining(
        child: _buildNoResultsState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = _filteredList[index];
          // Use appropriate nested data based on view type
          final user = _viewType == FollowViewType.followers 
              ? entry.follower 
              : entry.following;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildUserTile(user, entry),
          );
        },
        childCount: _filteredList.length,
      ),
    );
  }

  Widget _buildUserTile(FollowUser? user, FollowEntry entry) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: AvatarWidget(
          imageUrl: user?.imageUrl ?? 'avatar_f1_hdpi.png',
          size: AvatarSize.medium,
        ),
        title: Text(
          user?.username ?? 'User',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: user?.name != null
            ? Text(
                '${user!.name}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              )
            : null,
        trailing: _buildFollowButton(user),
        onTap: () => _navigateToUserProfile(user),
      ),
    );
  }

  Widget _buildFollowButton(FollowUser? user) {
    if (user?.id == null) return const SizedBox.shrink();
    
    // Check local override first, then fall back to API value
    final isFollowed = _followStatusOverrides[user!.id!] ?? user.isFollowed ?? false;
    
    if (isFollowed) {
      // isFollowed = true means mutual follow → "Teman"
      return OutlinedButton(
        onPressed: () => _toggleFollow(user),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.accent),
          foregroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Teman'),
      );
    }
    
    // isFollowed = false
    if (_viewType == FollowViewType.followers) {
      // Di halaman Followers: mereka follow kita, tapi kita belum follow mereka → "Ikuti"
      return ElevatedButton(
        onPressed: () => _toggleFollow(user),
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.textOnPrimary,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Ikuti'),
      );
    } else {
      // Di halaman Following: kita follow mereka, tapi mereka belum follow kita → "Mengikuti"
      return OutlinedButton(
        onPressed: () => _toggleFollow(user),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.accent),
          foregroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text('Mengikuti'),
      );
    }
  }

  Future<void> _toggleFollow(FollowUser user) async {
    if (user.id == null) return;
    
    // Get current follow status
    final currentStatus = _followStatusOverrides[user.id!] ?? user.isFollowed ?? false;
    
    try {
      // Call toggle API
      await _socialRepository.followUser(user.id!);
      
      // Toggle local state
      setState(() {
        _followStatusOverrides[user.id!] = !currentStatus;
      });
      
      final message = !currentStatus
          ? 'Anda sekarang berteman dengan ${user.name ?? user.username}'
          : 'Anda berhenti mengikuti ${user.name ?? user.username}';
      
      Get.snackbar(
        'Berhasil',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'FollowersFollowingView'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildEmptyState() {
    final icon = _viewType == FollowViewType.followers 
        ? Icons.people_outline 
        : Icons.person_add_outlined;
    final title = _viewType == FollowViewType.followers 
        ? 'Belum ada pengikut' 
        : 'Belum mengikuti siapapun';
    final subtitle = _viewType == FollowViewType.followers 
        ? 'Bagikan profil Anda untuk mendapatkan pengikut' 
        : 'Temukan dan ikuti pengguna lain';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ada hasil untuk "$_searchQuery"',
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

  void _navigateToUserProfile(FollowUser? user) {
    if (user?.id == null) return;
    
    Get.toNamed(
      AppPages.USER_PROFILE,
      arguments: {'userId': user!.id},
    );
  }
}
