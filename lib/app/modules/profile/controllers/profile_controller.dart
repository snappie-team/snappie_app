import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/data/models/leaderboard_model.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/achievement_repository_impl.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';


class ProfileController extends GetxController {
  final AuthService authService;
  final UserRepository userRepository;
  final PostRepository postRepository;
  final AchievementRepository achievementRepository;

  ProfileController({
    required this.authService,
    required this.userRepository,
    required this.postRepository,
    required this.achievementRepository,
    required PlaceRepository placeRepository,
  });

  final Rx<UserModel?> _userData = Rx<UserModel?>(null);
  final _userPosts = <PostModel>[].obs;
  final _savedPlaces = <SavedPlacePreview>[].obs;
  final _savedPosts = <SavedPostPreview>[].obs;
  final _leaderboard = <LeaderboardEntry>[].obs;
  final _userRank = Rxn<int>();
  final _isLoading = false.obs;
  final _isLoadingPosts = false.obs;
  final _isLoadingSaved = false.obs;
  final _isLoadingAchievements = false.obs;
  final _isInitialized = false.obs;
  final _selectedTabIndex = 0.obs;

  UserModel? get userData => _userData.value;
  List<PostModel> get userPosts => _userPosts;
  List<SavedPlacePreview> get savedPlaces => _savedPlaces;
  List<SavedPostPreview> get savedPosts => _savedPosts;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  int? get userRank => _userRank.value;
  bool get isLoading => _isLoading.value;
  bool get isLoadingPosts => _isLoadingPosts.value;
  bool get isLoadingSaved => _isLoadingSaved.value;
  bool get isLoadingAchievements => _isLoadingAchievements.value;
  int get selectedTabIndex => _selectedTabIndex.value;

  // Access user data directly from UserModel
  String get userName => _userData.value?.name ?? 'User';
  String get userNickname => _userData.value?.username ?? '';
  String get userAvatar => _userData.value?.imageUrl ?? '';
  String get userEmail => _userData.value?.email ?? '';
  String get userImageUrl => _userData.value?.imageUrl ?? '';
  int get totalCoins => _userData.value?.totalCoin ?? 0;
  int get totalExp => _userData.value?.totalExp ?? 0;
  int get totalFollowing => _userData.value?.totalFollowing ?? 0;
  int get totalFollowers => _userData.value?.totalFollower ?? 0;
  int get totalCheckins => _userData.value?.totalCheckin ?? 0;
  int get totalPosts => _userData.value?.totalPost ?? 0;
  int get totalArticles => _userData.value?.totalArticle ?? 0;
  int get totalReviews => _userData.value?.totalReview ?? 0;
  int get totalAchievements => _userData.value?.totalAchievement ?? 0;
  int get totalChallenges => _userData.value?.totalChallenge ?? 0;
  
  // Gamification challenge badge counter
  final _completedChallengesCount = 0.obs;
  int get completedChallengesCount => _completedChallengesCount.value;
  
  // Add stats getter for compatibility with profile_view
  Map<String, dynamic> get stats => {
    'total_checkins': totalCheckins,
    'total_reviews': totalReviews,
    'total_posts': totalPosts,
  };

  @override
  void onInit() {
    super.onInit();
    Logger.debug('ProfileController created (not initialized yet)', 'Profile');
    
    // Listen for auth status changes
    ever(authService.isLoggedInObs, (isLoggedIn) {
      if (isLoggedIn && _isInitialized.value) {
        loadUserProfile();
      }
    });
  }
  
  /// Initialize data hanya saat tab pertama kali dibuka
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      Logger.debug('ProfileController initializing...', 'Profile');
      _loadAllData();
    }
  }

  /// Load all profile data sequentially
  Future<void> _loadAllData() async {
    // First load user profile to get userId
    await loadUserProfile();
    
    // Then load posts, saved items, and leaderboard in parallel
    await Future.wait([
      loadUserPosts(),
      loadSavedItems(),
      loadLeaderboard(),
    ]);
  }

  Future<void> loadUserProfile() async {
    _setLoading(true);
    
    try {
      // Fetch fresh user data from API via repository
      final userData = await userRepository.getUserProfile();
      _userData.value = userData;
      
      Logger.info('User profile loaded from API: ${userData.name}', 'Profile');
      Logger.debug('   - Image: ${userData.imageUrl}', 'Profile');
      Logger.debug('   - Email: ${userData.email}', 'Profile');
      Logger.debug('   - XP: ${userData.totalExp}', 'Profile');
      Logger.debug('   - Coins: ${userData.totalCoin}', 'Profile');
      Logger.debug('   - Checkins: ${userData.totalCheckin}', 'Profile');
      Logger.debug('   - Reviews: ${userData.totalReview}', 'Profile');
      Logger.debug('   - Posts: ${userData.totalPost}', 'Profile');
    } catch (e) {
      Logger.error('Error loading user profile', e, null, 'Profile');
      _userData.value = null;
    }
    
    _setLoading(false);
  }

  Future<void> loadUserPosts() async {
    final userId = _userData.value?.id;
    if (userId == null) {
      Logger.warning('Cannot load posts: User ID not available', 'Profile');
      return;
    }
    
    _isLoadingPosts.value = true;
    
    try {
      final posts = await postRepository.getPostsByUserId(
        userId,
        perPage: 50,
      );
      _userPosts.assignAll(posts);
      Logger.info('User posts loaded: ${posts.length} posts', 'Profile');
    } catch (e) {
      Logger.error('Error loading user posts', e, null, 'Profile');
      _userPosts.clear();
    }
    
    _isLoadingPosts.value = false;
  }

  Future<void> loadSavedItems() async {
    _isLoadingSaved.value = true;
    
    try {
      // Get saved items with preview data directly from API
      final userSaved = await userRepository.getUserSaved();
      
      // Directly assign - no need to fetch individual items anymore!
      _savedPlaces.assignAll(userSaved.savedPlaces ?? []);
      _savedPosts.assignAll(userSaved.savedPosts ?? []);
      
      Logger.info('Loaded ${_savedPlaces.length} saved places, ${_savedPosts.length} saved posts', 'Profile');
    } catch (e) {
      Logger.error('Error loading saved items', e, null, 'Profile');
      _savedPlaces.clear();
      _savedPosts.clear();
    }
    
    _isLoadingSaved.value = false;
  }

  Future<void> loadLeaderboard() async {
    await loadMonthlyLeaderboard();
    await loadWeeklyLeaderboard();
  }

  Future<void> loadWeeklyLeaderboard() async {
    _isLoadingAchievements.value = true;
    
    try {
      final entries = await achievementRepository.getWeeklyLeaderboard();
      _leaderboard.assignAll(entries);
      
      // Find current user's rank
      final userId = _userData.value?.id;
      if (userId != null) {
        final userEntry = entries.firstWhereOrNull((e) => e.userId == userId);
        _userRank.value = userEntry?.rank;
      }
      
      Logger.info('Weekly Leaderboard loaded: ${entries.length} entries, user rank: ${_userRank.value}', 'Profile');
    } catch (e) {
      Logger.error('Error loading weekly leaderboard', e, null, 'Profile');
      _leaderboard.clear();
      _userRank.value = null;
    }
    
    _isLoadingAchievements.value = false;
  }

  Future<void> loadMonthlyLeaderboard() async {
    _isLoadingAchievements.value = true;
    
    try {
      final entries = await achievementRepository.getMonthlyLeaderboard();
      _leaderboard.assignAll(entries);
      
      // Find current user's rank
      final userId = _userData.value?.id;
      if (userId != null) {
        final userEntry = entries.firstWhereOrNull((e) => e.userId == userId);
        _userRank.value = userEntry?.rank;
      }
      
      Logger.info('Monthly Leaderboard loaded: ${entries.length} entries, user rank: ${_userRank.value}', 'Profile');
    } catch (e) {
      Logger.error('Error loading monthly leaderboard', e, null, 'Profile');
      _leaderboard.clear();
      _userRank.value = null;
    }
    
    _isLoadingAchievements.value = false;
  }

  Future<void> refreshProfile() async {
    await _loadAllData();
  }

  Future<void> refreshData() async {
    await refreshProfile();
  }

  void setSelectedTabIndex(int index) {
    _selectedTabIndex.value = index;
  }

  void editProfile() {
    // TODO: Implement edit profile functionality
    Get.snackbar(
      'Edit Profile',
      'Edit profile feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> logout() async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      );
      
      if (confirmed == true) {
        // Show loading
        Get.dialog(
          Center(
            child: CircularProgressIndicator(),
          ),
          barrierDismissible: false,
        );
        
        // Call logout API
        await authService.logout();
        
        // Close loading dialog
        Get.back();
        
        // Show success message
        Get.snackbar(
          'Logout Berhasil',
          'Anda telah keluar dari aplikasi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Navigate back to login screen
        Get.offAllNamed(AppPages.LOGIN);
      }
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'ProfileController'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void viewAchievements() {
    // TODO: Implement view achievements functionality
    Get.snackbar(
      'Achievements',
      'View achievements feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void viewHistory() {
    // TODO: Implement view history functionality
    Get.snackbar(
      'History',
      'View history feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Increment completed challenges badge counter
  void incrementCompletedChallenges(int count) {
    _completedChallengesCount.value += count;
    Logger.debug('Profile: Completed challenges badge incremented by $count, total: ${_completedChallengesCount.value}', 'Profile');
  }

  /// Reset completed challenges badge (called when user opens challenges page)
  void resetCompletedChallengesBadge() {
    _completedChallengesCount.value = 0;
    Logger.debug('Profile: Completed challenges badge reset', 'Profile');
  }

  /// Load challenges data in background
  Future<void> loadChallenges() async {
    final userId = _userData.value?.id;
    if (userId == null) return;
    
    try {
      // Refresh user challenges data
      await achievementRepository.getChallenges(userId);
      Logger.debug('Profile: Challenges data refreshed', 'Profile');
    } catch (e) {
      Logger.error('Error loading challenges', e, null, 'Profile');
    }
  }

  /// Add coins to user balance
  Future<void> addCoins(int amount) async {
    if (_userData.value != null) {
      _userData.value = UserModel()
        ..id = _userData.value!.id
        ..name = _userData.value!.name
        ..username = _userData.value!.username
        ..email = _userData.value!.email
        ..imageUrl = _userData.value!.imageUrl
        ..totalCoin = (_userData.value!.totalCoin ?? 0) + amount
        ..totalExp = _userData.value!.totalExp
        ..totalFollowing = _userData.value!.totalFollowing
        ..totalFollower = _userData.value!.totalFollower
        ..totalCheckin = _userData.value!.totalCheckin
        ..totalPost = _userData.value!.totalPost
        ..totalArticle = _userData.value!.totalArticle
        ..totalReview = _userData.value!.totalReview
        ..totalAchievement = _userData.value!.totalAchievement
        ..totalChallenge = _userData.value!.totalChallenge;
      
      Logger.debug('Profile: Added $amount coins, new total: ${_userData.value!.totalCoin}', 'Profile');
    }
  }

  /// Add XP to user balance
  Future<void> addExp(int amount) async {
    if (_userData.value != null) {
      _userData.value = UserModel()
        ..id = _userData.value!.id
        ..name = _userData.value!.name
        ..username = _userData.value!.username
        ..email = _userData.value!.email
        ..imageUrl = _userData.value!.imageUrl
        ..totalCoin = _userData.value!.totalCoin
        ..totalExp = (_userData.value!.totalExp ?? 0) + amount
        ..totalFollowing = _userData.value!.totalFollowing
        ..totalFollower = _userData.value!.totalFollower
        ..totalCheckin = _userData.value!.totalCheckin
        ..totalPost = _userData.value!.totalPost
        ..totalArticle = _userData.value!.totalArticle
        ..totalReview = _userData.value!.totalReview
        ..totalAchievement = _userData.value!.totalAchievement
        ..totalChallenge = _userData.value!.totalChallenge;
      
      Logger.debug('Profile: Added $amount XP, new total: ${_userData.value!.totalExp}', 'Profile');
    }
  }
}
