import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/repositories/place_repository_impl.dart';
import '../../../routes/app_pages.dart';
import '../../shared/widgets/index.dart';

/// Post Detail View - Full screen view for a single post
/// Menerima postId dari arguments: {'postId': int}
class PostDetailView extends StatefulWidget {
  const PostDetailView({super.key});

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  final _postRepository = Get.find<PostRepository>();
  final _authService = Get.find<AuthService>();

  late int _postId;

  bool _isLoading = true;
  bool _isLoadingComments = false;
  String _errorMessage = '';

  PostModel? _post;
  List<CommentModel> _comments = [];

  final TextEditingController _commentController = TextEditingController();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _postId = args?['postId'] ?? 0;

    if (_postId == 0) {
      setState(() {
        _errorMessage = 'Post ID tidak valid';
        _isLoading = false;
      });
    } else {
      _loadPost();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final post = await _postRepository.getPostById(_postId);

      setState(() {
        _post = post;
        _comments = post.comments ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat post';
        _isLoading = false;
      });
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
          'Postingan',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: _sharePost,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _post != null ? _buildCommentInput() : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
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
              onPressed: _loadPost,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadPost,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            _buildPostHeader(),

            // Post Content
            _buildPostContent(),

            // Post Images
            if (_post?.imageUrls != null && _post!.imageUrls!.isNotEmpty)
              _buildPostImages(),

            // Post Stats & Actions
            _buildPostActions(),

            const Divider(height: 1),

            // Comments Section
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(_post?.userId),
            child: AvatarWidget(
              imageUrl: _post?.user?.imageUrl,
              size: AvatarSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _navigateToUserProfile(_post?.userId),
                  child: Text(
                    _post?.user?.name ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_post?.place != null)
                  GestureDetector(
                    onTap: () => _navigateToPlace(_post?.placeId),
                    child: Text(
                      _post?.place?.name ?? '',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _post?.createdAt != null
                ? TimeFormatter.formatTimeAgo(_post!.createdAt!)
                : '',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    if (_post?.content == null || _post!.content!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        _post!.content!,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildPostImages() {
    final imageUrls = _post!.imageUrls!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: _imagePageController,
              itemCount: imageUrls.length,
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openFullscreenImage(index),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.backgroundContainer,
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColors.textSecondary,
                          size: 64,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Image indicator
          if (imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? AppColors.primary
                          : AppColors.backgroundContainer,
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostActions() {
    final currentUserId = _authService.userData?.id;
    final isLiked =
        _post?.likes?.any((like) => like.userId == currentUserId) ?? false;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Like button
          GestureDetector(
            onTap: _toggleLike,
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_post?.likesCount ?? 0}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Comment count
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 6),
              Text(
                '${_post?.commentsCount ?? 0}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          // View place button
          if (_post?.placeId != null)
            TextButton(
              onPressed: () => _navigateToPlace(_post?.placeId),
              child: Text(
                'Lihat Tempat',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar (${_comments.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada komentar',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jadilah yang pertama berkomentar!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._comments.map((comment) => _buildCommentItem(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _navigateToUserProfile(comment.userId),
            child: AvatarWidget(
              imageUrl: comment.user?.imageUrl,
              size: AvatarSize.small,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.user?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.createdAt != null
                          ? TimeFormatter.formatTimeAgo(comment.createdAt!)
                          : '',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.comment ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: _authService.userData?.imageUrl,
            size: AvatarSize.small,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.backgroundContainer),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.backgroundContainer),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
              ),
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submitComment,
            icon: Icon(Icons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _navigateToUserProfile(int? userId) {
    if (userId == null) return;
    Get.toNamed(AppPages.USER_PROFILE, arguments: {'userId': userId});
  }

  Future<void> _navigateToPlace(int? placeId) async {
    if (placeId == null) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final placeRepository = Get.find<PlaceRepository>();
      final place = await placeRepository.getPlaceById(placeId);

      Get.back();
      Get.toNamed(AppPages.PLACE_DETAIL, arguments: place);
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Error',
        'Gagal memuat detail tempat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _openFullscreenImage(int index) {
    // TODO: Implement fullscreen image viewer
  }

  void _toggleLike() async {
    final postId = _post?.id;
    if (postId == null) return;

    try {
      setState(() => _isLoading = true);

      final postRepository = Get.find<PostRepository>();
      final isLiked = await postRepository.toggleLikePost(postId);

      // Reload post to get updated like count and state
      await _loadPost();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyukai post',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _submitComment() async {
    final comment = _commentController.text.trim();
    final postId = _post?.id;

    if (comment.isEmpty || postId == null) return;

    try {
      await _postRepository.createComment(postId, comment);
      _commentController.clear();

      // Reload post to get updated comments
      await _loadPost();

      Get.snackbar(
        'Berhasil',
        'Komentar berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menambahkan komentar',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _sharePost() async {
    if (_post == null) return;

    final userName = _post!.user?.name ?? 'Seseorang';
    final content = _post!.content ?? '';
    final postId = _post!.id;
    final placeName = _post!.place?.name;

    String shareText = '📝 $userName membagikan di Snappie\n';
    if (content.isNotEmpty) {
      shareText += '\n$content\n';
    }
    if (placeName != null) {
      shareText += '\n📍 Lokasi: $placeName';
    }
    if (postId != null) {
      shareText += '\n\nLihat selengkapnya:\nhttps://snappie.app/post/$postId';
    }
    shareText += '\n\nTemukan di Snappie App! 📱';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'Lihat postingan ini dari $userName',
      ),
    );
  }
}
