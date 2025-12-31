import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/_dialog_widgets/share_profile_modal.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import '../../shared/widgets/index.dart';

/// Invite Friends page - Find by name and share profile
class InviteFriendsView extends StatelessWidget {
  const InviteFriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    return ScaffoldFrame.detail(
      title: 'Tambah Teman',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Option 1: Search by name
              _buildOptionCard(
                onTap: () => Get.to(() => const _AddFriendsSearchView()),
                leading: Image.asset(
                  AppAssets.images.find,
                  width: 56,
                  height: 56,
                ),
                title: 'Cari berdasarkan nama',
              ),

              const SizedBox(height: 12),

              // Option 2: Share profile link
              _buildOptionCard(
                onTap: () => _showShareProfileModal(profileController),
                leading: Image.asset(
                  AppAssets.images.friends,
                  width: 56,
                  height: 56,
                ),
                title: 'Bagikan profil tautan',
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required VoidCallback onTap,
    required Widget leading,
    required String title,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            SizedBox(
              width: 68,
              child: leading,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showShareProfileModal(ProfileController controller) {
    final user = controller.userData;
    final username = user?.username ?? '';
    final displayName = user?.name ?? 'User';
    final profileLink = username.isNotEmpty
        ? 'https://snappie.app/u/$username'
        : 'https://snappie.app/profile';

    Get.bottomSheet(
      ShareProfileModal(
        profileLink: profileLink,
        username: username,
        displayName: displayName,
        avatarUrl: user?.imageUrl,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlayDark,
    );
  }
}

/// Search page for finding friends by name
class _AddFriendsSearchView extends StatefulWidget {
  const _AddFriendsSearchView();

  @override
  State<_AddFriendsSearchView> createState() => _AddFriendsSearchViewState();
}

class _AddFriendsSearchViewState extends State<_AddFriendsSearchView> {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final SocialRepository _socialRepository = Get.find<SocialRepository>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  bool _isSearching = false;
  List<UserSearchItem> _searchResults = [];
  
  // Local state to track follow status changes (userId -> isFollowed)
  final Map<int, bool> _followStatusOverrides = {};

  @override
  void initState() {
    super.initState();
    // Auto focus on search field when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final result = await _userRepository.searchUsers(query);
      setState(() => _searchResults = result.users ?? []);
      Logger.debug('Found ${_searchResults.length} users for query: $query', 'Search');
    } catch (e) {
      Logger.error('Error searching users', e, null, 'Search');
      setState(() => _searchResults = []);
    }

    setState(() => _isSearching = false);
  }

  Future<void> _toggleFollow(UserSearchItem user) async {
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
        'Gagal memproses permintaan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _navigateToUserProfile(UserSearchItem user) {
    if (user.id == null) return;
    
    Get.toNamed(
      AppPages.USER_PROFILE,
      arguments: {'userId': user.id},
    );
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
          'Tambah Teman',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Results
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _performSearch(value);
        },
        decoration: InputDecoration(
          hintText: 'Nama atau username',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.backgroundContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: AppColors.primary, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        title: 'Cari Teman',
        subtitle: 'Masukkan nama atau username untuk mencari teman',
      );
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_search,
        title: 'Tidak ditemukan',
        subtitle: 'Tidak ada pengguna dengan nama "$_searchQuery"',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(UserSearchItem user) {
    return Container(
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
          imageUrl: user.imageUrl ?? 'avatar_f1_hdpi.png',
          size: AvatarSize.medium,
        ),
        title: Text(
          user.username ?? 'User',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: user.name != null
            ? Text(
                user.name!,
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

  Widget _buildFollowButton(UserSearchItem user) {
    if (user.id == null) return const SizedBox.shrink();
    
    // Check local override first, then fall back to API value
    final isFollowed = _followStatusOverrides[user.id!] ?? user.isFollowed ?? false;
    
    if (isFollowed) {
      // Already following → "Mengikuti" button (outlined)
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
    
    // Not following → "Ikuti" button (filled)
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

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
}
