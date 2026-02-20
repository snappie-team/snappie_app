import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../data/models/social_model.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../../routes/app_pages.dart';
import '../../shared/widgets/index.dart';

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
    return initialTab == 0
        ? FollowViewType.followers
        : FollowViewType.following;
  }

  // Get title based on view type
  String get _title =>
      _viewType == FollowViewType.followers ? 'Pengikut' : 'Mengikuti';

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

      Logger.debug(
          'Loaded ${_followers.length} followers and ${_following.length} following',
          'Social');
    } catch (e) {
      Logger.error('Error loading follow data', e, null, 'Social');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: _title,
      onRefresh: _loadFollowData,
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
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  // TODO: Add clear.svg icon to assets/icons/
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    // isFollowed dari backend:
    // - Di Followers view: true = kita juga follow mereka (mutual)
    // - Di Following view: true = mereka juga follow kita (mutual)
    final isFollowedFromApi = user!.isFollowed ?? false;

    // Untuk Following page, kita perlu track apakah masih follow atau sudah unfollow
    // Default: di Following page kita PASTI follow mereka (true), di Followers tergantung API
    final currentlyFollowing = _followStatusOverrides[user.id!] ??
        (_viewType == FollowViewType.following ? true : isFollowedFromApi);

    if (_viewType == FollowViewType.followers) {
      // HALAMAN FOLLOWERS: Orang-orang yang follow kita
      if (currentlyFollowing) {
        // Kita sudah follow mereka → Mutual/Teman → Klik untuk UNFOLLOW
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
      } else {
        // Kita belum follow mereka → Tombol "Ikuti" → Klik untuk FOLLOW
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
      }
    } else {
      // HALAMAN FOLLOWING: Orang-orang yang kita follow
      // Di halaman ini, kita PASTI sudah follow mereka (kecuali sudah di-unfollow via override)

      if (!currentlyFollowing) {
        // Sudah di-unfollow → Tombol "Ikuti" atau "Ikuti Balik"
        final buttonText = isFollowedFromApi ? 'Ikuti Balik' : 'Ikuti';
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
          child: Text(buttonText),
        );
      } else if (isFollowedFromApi) {
        // Masih follow & mereka juga follow kita → Mutual/Teman → Klik untuk UNFOLLOW
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
      } else {
        // Masih follow tapi mereka belum follow kita → "Mengikuti" → Klik untuk UNFOLLOW
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
  }

  Future<void> _toggleFollow(FollowUser user) async {
    if (user.id == null) return;

    // Tentukan status saat ini berdasarkan halaman
    final isFollowedFromApi = user.isFollowed ?? false;
    final currentlyFollowing = _followStatusOverrides[user.id!] ??
        (_viewType == FollowViewType.following ? true : isFollowedFromApi);

    try {
      // Call toggle API
      await _socialRepository.followUser(user.id!);

      // Toggle local state
      setState(() {
        _followStatusOverrides[user.id!] = !currentlyFollowing;
      });

      // Pesan setelah toggle
      final newStatus = !currentlyFollowing;
      final message = newStatus
          ? 'Anda sekarang mengikuti ${user.name ?? user.username}'
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
    final title = _viewType == FollowViewType.followers
        ? 'Belum ada pengikut'
        : 'Belum mengikuti siapapun';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          'Tidak ada hasil untuk "$_searchQuery"',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
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
