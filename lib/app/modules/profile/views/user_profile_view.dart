import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/achievement_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../shared/widgets/index.dart';
import '../../home/controllers/home_controller.dart';

/// Read-only profile view untuk user lain
/// Menerima userId dari arguments: {'userId': int}
class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  // Dependencies
  final _userRepository = Get.find<UserRepository>();
  final _postRepository = Get.find<PostRepository>();
  final _achievementRepository = Get.find<AchievementRepository>();
  final _authService = Get.find<AuthService>();

  // User ID from arguments
  late int _userId;

  // State variables
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  String _errorMessage = '';

  String _userName = '';
  String _userUsername = '';
  String _userImageUrl = '';
  String? _userFrameUrl;
  int _totalPosts = 0;
  int _totalFollowers = 0;
  int _totalFollowing = 0;
  int? _userRank;

  // User posts
  List<PostModel> _userPosts = [];

  @override
  void initState() {
    super.initState();
    // Get userId from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    _userId = args?['userId'] ?? 0;

    if (_userId == 0) {
      setState(() {
        _errorMessage = 'User ID tidak valid';
        _isLoading = false;
      });
    } else {
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Get user profile by ID
      final user = await _userRepository.getUserById(_userId);
      if (!mounted) return;

      // DEBUG: Trace user data
      debugPrint('[getUserById] user: $user');
      debugPrint('[getUserById] userSettings: ${user.userSettings}');
      debugPrint('[getUserById] frameUrl: ${user.userSettings?.frameUrl}');

      setState(() {
        _userName = user.name ?? '';
        _userUsername = user.username ?? '';
        _userImageUrl = user.imageUrl ?? '';
        _userFrameUrl = user.userSettings?.frameUrl;
        _totalPosts = user.totalPost ?? 0;
        _totalFollowers = user.totalFollower ?? 0;
        _totalFollowing = user.totalFollowing ?? 0;
        _isLoading = false;
      });

      _loadUserRank();

      // Load user posts
      _loadUserPosts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat profil';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      if (!mounted) return;
      setState(() => _isLoadingPosts = true);

      final posts = await _postRepository.getPostsByUserId(_userId);
      if (!mounted) return;

      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _loadUserRank() async {
    try {
      final entries = await _achievementRepository.getMonthlyLeaderboard();
      final userEntry = entries.firstWhereOrNull((e) => e.userId == _userId);
      if (!mounted) return;
      setState(() => _userRank = userEntry?.rank);
    } catch (e) {
      if (!mounted) return;
      setState(() => _userRank = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: _buildErrorState(),
      );
    }

    return ScaffoldFrame.detail(
      title: 'Profil',
      onRefresh: _loadUserProfile,
      slivers: [
        _isLoading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : SliverToBoxAdapter(
                child: _buildContent(),
              ),
      ],
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadUserProfile,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        _buildPostsSection(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Peringkat ${_userRank ?? '-'}',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildFollowButton(),
            ],
          ),

          const SizedBox(height: 16),

          // Avatar
          AvatarWidget(
            imageUrl:
                _userImageUrl.isNotEmpty ? _userImageUrl : 'avatar_f1_hdpi.png',
            size: AvatarSize.extraLarge,
            frameUrl: _userFrameUrl,
          ),

          const SizedBox(height: 12),

          // Name
          Text(
            _userName,
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Username
          Text(
            '@$_userUsername',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 12),

          // Stats row
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildStatColumn('$_totalPosts', 'Postingan'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildStatColumn('$_totalFollowers', 'Pengikut'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderLight,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Expanded(
                  child: _buildStatColumn('$_totalFollowing', 'Mengikuti'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    final currentUserId = _authService.userData?.id;
    if (currentUserId == null || currentUserId == _userId) {
      return const SizedBox.shrink();
    }

    try {
      final controller = Get.find<HomeController>();
      return Obx(() {
        final state = controller.getFollowState(_userId);
        final isOutline = state == PostFollowState.friend ||
            state == PostFollowState.following;

        final label = switch (state) {
          PostFollowState.friend => 'Teman',
          PostFollowState.following => 'Mengikuti',
          PostFollowState.followBack => 'Ikuti Balik',
          PostFollowState.follow => 'Ikuti',
        };

        return RectangleButtonWidget(
          text: label,
          textStyle: TextStyle(
            fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
            fontWeight: FontWeight.bold,
          ),
          type: ButtonType.primary,
          backgroundColor:
              isOutline ? AppColors.backgroundContainer : AppColors.accent,
          textColor: isOutline ? AppColors.accent : AppColors.textOnPrimary,
          borderColor: isOutline ? AppColors.accent : null,
          size: RectangleButtonSize.small,
          borderRadius: BorderRadius.circular(24),
          onPressed: _handleFollow,
        );
      });
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  void _handleFollow() async {
    try {
      final controller = Get.find<HomeController>();
      await controller.toggleFollowUser(_userId);
      Get.snackbar(
        'Berhasil',
        'Status mengikuti diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengikuti: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textPrimary,
      );
    }
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection() {
    return Container(
      color: AppColors.backgroundContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posts content
          _isLoadingPosts
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : _userPosts.isEmpty
                  ? _buildEmptyPosts()
                  : _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyPosts() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada postingan',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    return Column(
      children: _userPosts.map((post) {
        return PostCard(
          post: post,
          isOthersProfile: true,
        );
      }).toList(),
    );
  }
}
