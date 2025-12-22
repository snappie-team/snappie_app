import 'package:get/get.dart';
import 'package:snappie_app/app/routes/api_endpoints.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/social_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../core/services/auth_service.dart';

enum PostFollowState {
  friend,
  following,
  followBack,
  follow,
}

class HomeController extends GetxController {
  final AuthService authService;
  final PostRepository postRepository;
  final SocialRepository socialRepository;
  final UserRepository userRepository;

  HomeController({
    required this.authService,
    required this.postRepository,
    required this.socialRepository,
    required this.userRepository,
  });

  final _posts = <PostModel>[].obs;
  final _selectedPost = Rxn<PostModel>();
  final _selectedImageUrls = Rxn<List<String>>();
  final Rx<UserModel?> _userData = Rx<UserModel?>(null);
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isInitialized = false.obs;
  final _showBanner = true.obs; // State untuk banner visibility

  final _followerIds = <int>[].obs;
  final _followingIds = <int>[].obs;
  final _followingOverrides = <int, bool>{}.obs;

  final _savedPostIds = <int>[].obs;
  final _isTogglingSavedPostIds = <int>[].obs;

  final _likedPostIds = <int>[].obs;
  final _isTogglingLikePostIds = <int>[].obs;

  List<PostModel> get posts => _posts;
  PostModel? get selectedPost => _selectedPost.value;
  List<String>? get selectedImageUrls => _selectedImageUrls.value;
  UserModel? get userData => _userData.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  bool get showBanner => _showBanner.value;

  void hideBanner() => _showBanner.value = false;

  bool isPostSaved(int postId) => _savedPostIds.contains(postId);
  bool isTogglingSavedPost(int postId) =>
      _isTogglingSavedPostIds.contains(postId);

  bool isPostLiked(int postId) => _likedPostIds.contains(postId);
  bool isTogglingLikePost(int postId) =>
      _isTogglingLikePostIds.contains(postId);

  bool _isFollower(int userId) => _followerIds.contains(userId);
  bool _isFollowing(int userId) =>
      _followingOverrides[userId] ?? _followingIds.contains(userId);

  PostFollowState getFollowState(int userId) {
    final follower = _isFollower(userId);
    final following = _isFollowing(userId);

    if (follower && following) return PostFollowState.friend;
    if (following) return PostFollowState.following;
    if (follower) return PostFollowState.followBack;
    return PostFollowState.follow;
  }

  @override
  void onInit() {
    super.onInit();
    // Tidak load data di sini - akan di-trigger dari view
    print('🏠 HomeController created (not initialized yet)');
  }

  /// Initialize data hanya saat tab pertama kali dibuka
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      print('🏠 HomeController initializing...');
      loadHomeData();
    }
  }

  void selectPost(PostModel post) {
    _selectedPost.value = post;
    _selectedImageUrls.value = post.imageUrls;
  }

  Future<void> loadHomeData() async {
    _setLoading(true);
    _errorMessage.value = '';

    try {
      // Load user data from AuthService
      if (authService.isLoggedIn) {
        final userData = authService.userData;
        if (userData != null) {
          _userData.value = userData;
          print('👤 Home: User data loaded - ${userData.name}');
        }
      }

      // Load posts from API
      final loadedPostsFuture = postRepository.getPosts();
      final followDataFuture = socialRepository.getFollowData();
      final savedFuture = userRepository.getUserSaved();

      final loadedPosts = await loadedPostsFuture;
      _posts.assignAll(loadedPosts);

      try {
        final followData = await followDataFuture;
        _hydrateFollowSets(followData);
      } catch (e) {
        print('⚠️ Home: Failed to load follow data: $e');
      }

      try {
        final saved = await savedFuture;
        final ids = (saved.savedPosts ?? const <SavedPostPreview>[])
            .map((e) => e.id)
            .whereType<int>()
            .toList();
        _savedPostIds.assignAll(ids);
      } catch (e) {
        print('⚠️ Home: Failed to load saved posts: $e');
      }

      print('🏠 Home: Loaded ${loadedPosts.length} posts');
    } catch (e) {
      _errorMessage.value = 'Failed to load posts: $e';
      print('❌ Error loading home data: $e');
    }

    _setLoading(false);
  }

  void _hydrateFollowSets(SocialFollowData data) {
    final followers = (data.followers ?? const <FollowEntry>[])
        .map((e) => e.followerId ?? e.follower?.id)
        .whereType<int>()
        .toSet()
        .toList();

    final following = (data.following ?? const <FollowEntry>[])
        .map((e) => e.followingId ?? e.following?.id)
        .whereType<int>()
        .toSet()
        .toList();

    _followerIds.assignAll(followers);
    _followingIds.assignAll(following);
    _followingOverrides.clear();
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }

  Future<void> toggleLikePost(int postId) async {
    if (_isTogglingLikePostIds.contains(postId)) return;

    _isTogglingLikePostIds.add(postId);
    final currentlyLiked = _likedPostIds.contains(postId);

    // Optimistic update
    if (currentlyLiked) {
      _likedPostIds.remove(postId);
    } else {
      _likedPostIds.add(postId);
    }

    // Update local post model count optimistically
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newCount = (post.likesCount ?? 0) + (currentlyLiked ? -1 : 1);
      _posts[postIndex] = post.copyWith(likesCount: newCount);
    }

    try {
      final isLiked = await postRepository.toggleLikePost(postId);

      // Sync with backend result
      if (isLiked && !_likedPostIds.contains(postId)) {
        _likedPostIds.add(postId);
      } else if (!isLiked && _likedPostIds.contains(postId)) {
        _likedPostIds.remove(postId);
      }
    } catch (e) {
      // Revert on failure
      if (currentlyLiked) {
        _likedPostIds.add(postId);
      } else {
        _likedPostIds.remove(postId);
      }

      // Revert count
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final revertCount = (post.likesCount ?? 0) + (currentlyLiked ? 1 : -1);
        _posts[postIndex] = post.copyWith(likesCount: revertCount);
      }

      rethrow;
    } finally {
      _isTogglingLikePostIds.remove(postId);
    }
  }

  void commentPost(int postId) {
    // TODO: Implement comment functionality
    Get.snackbar(
      'Comment',
      'Comment feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void sharePost(int postId) {
    // TODO: Implement share functionality
    Get.snackbar(
      'Shared',
      'Post shared successfully!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> toggleFollowUser(int userId) async {
    final current = _isFollowing(userId);

    // Optimistic update
    _followingOverrides[userId] = !current;

    try {
      await socialRepository.followUser(userId);
    } catch (e) {
      // Revert on failure
      _followingOverrides[userId] = current;
      rethrow;
    }
  }

  Future<void> toggleSavePost(int postId) async {
    if (_isTogglingSavedPostIds.contains(postId)) return;

    _isTogglingSavedPostIds.add(postId);
    final currentlySaved = _savedPostIds.contains(postId);

    // Optimistic update
    if (currentlySaved) {
      _savedPostIds.remove(postId);
    } else {
      _savedPostIds.add(postId);
    }

    try {
      final updated = await userRepository.toggleSavedPost(_savedPostIds);
      _savedPostIds.assignAll(updated);
    } catch (e) {
      // Revert on failure
      if (currentlySaved) {
        _savedPostIds.add(postId);
      } else {
        _savedPostIds.remove(postId);
      }
      rethrow;
    } finally {
      _isTogglingSavedPostIds.remove(postId);
    }
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
}
