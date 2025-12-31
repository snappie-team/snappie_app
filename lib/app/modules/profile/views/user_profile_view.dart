import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../shared/widgets/index.dart';

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

  // User ID from arguments
  late int _userId;

  // State variables
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  String _errorMessage = '';
  
  String _userName = '';
  String _userUsername = '';
  String _userImageUrl = '';
  int _totalPosts = 0;
  int _totalCoins = 0;
  int _totalExp = 0;
  int _totalFollowers = 0;
  int _totalFollowing = 0;

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
      
      setState(() {
        _userName = user.name ?? '';
        _userUsername = user.username ?? '';
        _userImageUrl = user.imageUrl ?? '';
        _totalPosts = user.totalPost ?? 0;
        _totalCoins = user.totalCoin ?? 0;
        _totalExp = user.totalExp ?? 0;
        _totalFollowers = user.totalFollower ?? 0;
        _totalFollowing = user.totalFollowing ?? 0;
        _isLoading = false;
      });

      // Load user posts
      _loadUserPosts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat profil';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPosts() async {
    try {
      setState(() => _isLoadingPosts = true);
      
      final posts = await _postRepository.getPostsByUserId(_userId);
      
      setState(() {
        _userPosts = posts;
        _isLoadingPosts = false;
      });
    } catch (e) {
      setState(() => _isLoadingPosts = false);
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
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        
        // Posts list
        SliverToBoxAdapter(
          child: _buildPostsSection(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // XP & Coins row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$_totalExp XP',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$_totalCoins Koin',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Avatar
          AvatarWidget(
            imageUrl: _userImageUrl.isNotEmpty ? _userImageUrl : 'avatar_f1_hdpi.png',
            size: AvatarSize.extraLarge,
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
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Postingan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
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
        );
      }).toList(),
    );
  }
}
