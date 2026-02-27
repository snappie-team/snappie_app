import 'package:get/get.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/social_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/repositories/social_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/articles_repository_impl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../data/models/articles_model.dart';

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
  final ArticlesRepository? articlesRepository;

  HomeController({
    required this.authService,
    required this.postRepository,
    required this.socialRepository,
    required this.userRepository,
    this.articlesRepository,
  });

  final _posts = <PostModel>[].obs;
  final _selectedPost = Rxn<PostModel>();
  final _selectedImageUrls = Rxn<List<String>>();
  final Rx<UserModel?> _userData = Rx<UserModel?>(null);
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _isInitialized = false.obs;
  final _showBanner = true.obs;
  final _articles = <ArticlesModel>[].obs;

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
  List<ArticlesModel> get articles => _articles;

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
    Logger.debug('HomeController created (not initialized yet)', 'Home');
  }

  /// Initialize data hanya saat tab pertama kali dibuka
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      Logger.debug('HomeController initializing...', 'Home');
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
          Logger.debug('Home: User data loaded - ${userData.name}', 'Home');
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
        Logger.warning('Home: Failed to load follow data: $e', 'Home');
      }

      try {
        final saved = await savedFuture;
        final ids = (saved.savedPosts ?? const <SavedPostPreview>[])
            .map((e) => e.id)
            .whereType<int>()
            .toList();
        _savedPostIds.assignAll(ids);
      } catch (e) {
        Logger.warning('Home: Failed to load saved posts: $e', 'Home');
      }

      // Initialize liked posts from loaded posts
      try {
        final currentUserId = _userData.value?.id;
        if (currentUserId != null) {
          final likedIds = loadedPosts
              .where((post) =>
                  post.likes?.any((like) => like.userId == currentUserId) ??
                  false)
              .map((post) => post.id)
              .whereType<int>()
              .toList();
          _likedPostIds.assignAll(likedIds);
          Logger.debug(
              'Home: Initialized ${likedIds.length} liked posts', 'Home');
        }
      } catch (e) {
        Logger.warning('Home: Failed to load liked posts: $e', 'Home');
      }

      Logger.info('Home: Loaded ${loadedPosts.length} posts', 'Home');

      // Load articles for carousel (non-blocking)
      _loadArticles();
    } catch (e) {
      _errorMessage.value =
          ErrorHandler.getReadableMessage(e, tag: 'HomeController');
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

  Future<void> _loadArticles() async {
    if (articlesRepository == null) return;
    try {
      final loaded = await articlesRepository!.getArticles();
      _articles.assignAll(loaded);
      Logger.debug(
          'Home: Loaded ${loaded.length} articles for carousel', 'Home');
    } catch (e) {
      Logger.warning('Home: Failed to load articles: $e', 'Home');
    }
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

      Logger.error('Failed to toggle like', e, null, 'Home');
      throw Exception('Gagal menyukai post, silakan coba lagi');
    } finally {
      _isTogglingLikePostIds.remove(postId);
    }
  }

  void commentPost(int postId) {
    // TODO: Implement comment functionality
    AppSnackbar.info('Comment feature coming soon!', title: 'Comment');
  }

  /// Update a specific post in the list
  void updatePost(PostModel updatedPost) {
    final postIndex = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (postIndex != -1) {
      _posts[postIndex] = updatedPost;
      Logger.debug('Post ${updatedPost.id} updated in list', 'Home');
    }
  }

  void sharePost(int postId) {
    // TODO: Implement share functionality
    AppSnackbar.info('Post shared successfully!', title: 'Shared');
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

  /// Remove a post from the local list (after delete)
  void removePost(int postId) {
    _posts.removeWhere((post) => post.id == postId);
    _savedPostIds.remove(postId);
    _likedPostIds.remove(postId);
    Logger.debug('Post $postId removed from home feed', 'Home');
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
}
