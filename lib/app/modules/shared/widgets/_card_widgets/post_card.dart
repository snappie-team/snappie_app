import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/modules/home/controllers/home_controller.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/post_model.dart';
import '../../../../data/models/comment_model.dart';
import '../../../../routes/app_pages.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Local reactive state for like and comment
  late RxInt _likesCount;
  late RxInt _commentsCount;
  late RxBool _isLiked;
  late RxBool _isTogglingLike;
  late RxList<CommentModel> _comments;

  PostModel get post => widget.post;

  @override
  void initState() {
    super.initState();
    _initializeLocalState();
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-initialize if post data changed (e.g., from parent refresh)
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.likesCount != widget.post.likesCount ||
        oldWidget.post.commentsCount != widget.post.commentsCount) {
      _initializeLocalState();
    }
  }

  void _initializeLocalState() {
    _likesCount = (post.likesCount ?? 0).obs;
    _commentsCount = (post.commentsCount ?? 0).obs;
    _comments = (post.comments ?? <CommentModel>[]).obs;
    _isTogglingLike = false.obs;

    // Check if current user has liked this post
    final authService = Get.find<AuthService>();
    final currentUserId = authService.userData?.id;
    final hasLiked =
        post.likes?.any((like) => like.userId == currentUserId) ?? false;
    _isLiked = hasLiked.obs;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildPostContent(),
          const SizedBox(height: 12),
          if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
            _buildPostImage(context),
          const SizedBox(height: 12),
          _buildPostActions(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    final username = post.user?.name ?? 'Unknown';
    final avatarUrl = post.user?.imageUrl;
    final placeName = post.place?.name ?? 'Unknown Place';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: avatarUrl,
            size: AvatarSize.medium,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: _openPlace,
                  child: Text(
                    placeName,
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
          _buildFollowButton(),
          _buildMoreButton(),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    final authService = Get.find<AuthService>();
    final currentUserId = authService.userData?.id;
    final isOwner = post.userId == currentUserId;

    return PopupMenuButton<String>(
      icon: AppIcon(
        AppAssets.icons.moreDots,
        color: AppColors.textSecondary,
        size: 18,
      ),
      offset: const Offset(-48, 0), // Muncul di kiri button
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.textSecondary)
      ),
      color: AppColors.backgroundContainer,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'profile':
            _viewProfile();
            break;
          case 'report':
            _showReportModal();
            break;
          case 'delete':
            _confirmDeletePostModal();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!isOwner) ...[
          PopupMenuItem<String>(
              value: 'profile',
              child: Text('Lihat Profil',
                  style: TextStyle(color: AppColors.textSecondary))),
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: 'report',
            child: Text('Laporkan',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
        if (isOwner) ...[
          // const PopupMenuDivider(),
          PopupMenuItem<String>(
              value: 'delete',
              child: Text('Hapus Post',
                  style: TextStyle(color: AppColors.textSecondary))),
        ],
      ],
    );
  }

  void _viewProfile() {
    final userId = post.userId;
    if (userId == null) return;

    // Navigate to user profile
    Get.toNamed(AppPages.USER_PROFILE, arguments: {'userId': userId});
  }

  void _showReportModal() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Laporkan Post', style: TextStyle(color: AppColors.error)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur laporan sedang dalam pengembangan.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kami akan segera menambahkan fitur ini untuk membantu menjaga komunitas Snappie tetap aman.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Tutup',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePostModal() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.images.delete,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                'Hapus Postingan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Yakin ingin menghapus postingan?',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _deletePost();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: const Text(
                        'Ya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _deletePost() async {
    final postId = post.id;
    if (postId == null) return;

    try {
      final postRepository = Get.find<PostRepository>();
      await postRepository.deletePost(postId);

      // Refresh home feed
      try {
        final homeController = Get.find<HomeController>();
        homeController.removePost(postId);
      } catch (e) {
        Logger.warning('HomeController not found, skipping sync', 'PostCard');
      }

      Get.snackbar(
        'Berhasil',
        'Post berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Logger.error('Failed to delete post', e, null, 'PostCard');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menghapus post, silakan coba lagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            post.content ?? '',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(context, post),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                post.createdAt != null
                    ? TimeFormatter.formatTimeAgo(post.createdAt!)
                    : 'Unknown',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: FontSize.getSize(FontSizeOption.small),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Spacer(),
              RectangleButtonWidget(
                text: 'Lihat Tempat',
                size: RectangleButtonSize.small,
                backgroundColor: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
                onPressed: _openPlace,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, PostModel? post) {
    double imageHeight = 300;
    final imageUrls = post?.imageUrls ?? [];
    Logger.debug('imageUrls: $imageUrls', 'PostCard');

    // If no images, show placeholder
    if (imageUrls.isEmpty) {
      return Container(
        height: imageHeight,
        width: double.infinity,
        color: AppColors.background,
        child: Center(
          child: Icon(
            Icons.restaurant,
            color: AppColors.textTertiary,
            size: imageHeight * 0.3,
          ),
        ),
      );
    }

    // If only one image, show it without carousel
    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () {
          FullscreenImageViewer.show(
            context: context,
            imageUrls: imageUrls,
            initialIndex: 0,
          );
        },
        child: Container(
          height: imageHeight,
          width: double.infinity,
          child: ClipRRect(
            child: Image.network(
              imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.textTertiary,
                      size: imageHeight * 0.3,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Multiple images - show carousel
    final PageController pageController = PageController();
    final RxInt currentImageIndex = 0.obs;

    return Container(
      height: imageHeight,
      child: PageView.builder(
        controller: pageController,
        itemCount: imageUrls.length,
        onPageChanged: (index) => currentImageIndex.value = index,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              FullscreenImageViewer.show(
                context: context,
                imageUrls: imageUrls,
                initialIndex: index,
              );
            },
            child: Container(
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: imageHeight,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.background,
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              color: AppColors.textTertiary,
                              size: imageHeight * 0.3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Image counter overlay
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}/${imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildLikeButton(),
              const SizedBox(width: 20),
              _buildCommentButton(),
              const SizedBox(width: 20),
              _buildShareButton(),
            ],
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    final postId = post.id;

    if (postId == null) return const SizedBox.shrink();

    return Obx(() {
      final isLiked = _isLiked.value;
      final likesCount = _likesCount.value;

      return GestureDetector(
        onTap: _handleLike,
        child: Row(
          children: [
            AppIcon(
              isLiked
                  ? AppAssets.icons.loveActive
                  : AppAssets.icons.loveInactive,
              size: 24,
              color: AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(
              '$likesCount',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentButton() {
    return Obx(() {
      final commentsCount = _commentsCount.value;

      return GestureDetector(
        onTap: _showComments,
        child: Row(
          children: [
            AppIcon(
              AppAssets.icons.comment,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              '$commentsCount',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: _showShare,
      child: AppIcon(
        AppAssets.icons.share,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }

  Widget _buildFollowButton() {
    final authService = Get.find<AuthService>();

    final userId = post.userId;
    final currentUserId = authService.userData?.id;

    if (userId == null || currentUserId == null || userId == currentUserId) {
      return const SizedBox.shrink();
    }

    // Try to get HomeController for follow state (optional)
    try {
      final controller = Get.find<HomeController>();
      return Obx(() {
        final state = controller.getFollowState(userId);
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
          type: isOutline ? ButtonType.outline : ButtonType.primary,
          backgroundColor: isOutline ? null : AppColors.accent,
          textColor: isOutline ? AppColors.accent : AppColors.textOnPrimary,
          borderColor: isOutline ? AppColors.accent : null,
          size: RectangleButtonSize.small,
          borderRadius: BorderRadius.circular(24),
          onPressed: _handleFollow,
        );
      });
    } catch (e) {
      // HomeController not available, hide follow button
      return const SizedBox.shrink();
    }
  }

  Widget _buildSaveButton() {
    final postId = post.id;

    if (postId == null) return const SizedBox.shrink();

    // Try to get HomeController for save state (optional)
    try {
      final controller = Get.find<HomeController>();
      return Obx(() {
        final isSaved = controller.isPostSaved(postId);
        final isLoading = controller.isTogglingSavedPost(postId);

        if (isLoading) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        return GestureDetector(
          onTap: _savePost,
          child: AppIcon(
            isSaved
                ? AppAssets.icons.saveActive
                : AppAssets.icons.saveInactive,
            color: AppColors.accent,
            size: 24,
          ),
        );
      });
    } catch (e) {
      // HomeController not available, show default bookmark
      return GestureDetector(
        onTap: _savePost,
        child: AppIcon(
          AppAssets.icons.saveInactive,
          color: AppColors.accent,
          size: 24,
        ),
      );
    }
  }

  void _handleLike() async {
    final postId = post.id;
    if (postId == null || _isTogglingLike.value) return;

    _isTogglingLike.value = true;
    final wasLiked = _isLiked.value;
    final originalCount = _likesCount.value;

    // Optimistic update - update local state immediately
    _isLiked.value = !wasLiked;
    _likesCount.value += wasLiked ? -1 : 1;

    try {
      final postRepository = Get.find<PostRepository>();
      await postRepository.toggleLikePost(postId);

      // Fetch updated post to get accurate count from backend
      final updatedPost = await postRepository.getPostById(postId);

      // Update with actual backend data
      _likesCount.value = updatedPost.likesCount ?? 0;

      // Check if current user has liked (from backend data)
      final authService = Get.find<AuthService>();
      final currentUserId = authService.userData?.id;
      _isLiked.value =
          updatedPost.likes?.any((like) => like.userId == currentUserId) ??
              false;

      // Also sync with HomeController if available (for consistency when switching tabs)
      try {
        final homeController = Get.find<HomeController>();
        homeController.updatePost(updatedPost);
      } catch (e) {
        // HomeController not available, skip sync
      }
    } catch (e) {
      // Revert on failure
      _isLiked.value = wasLiked;
      _likesCount.value = originalCount;

      Logger.error('Failed to toggle like', e, null, 'PostCard');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyukai post, silakan coba lagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isTogglingLike.value = false;
    }
  }

  void _showComments() {
    final TextEditingController commentController = TextEditingController();

    Get.bottomSheet(
      SafeArea(
        top: true,
        bottom: true,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
          ),
          child: Container(
            height: Get.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Obx(
                  () => Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: Center(
                      child: Text(
                        'Komentar (${_commentsCount.value})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Obx(
                    () => _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppIcon(
                                  AppAssets.icons.comment,
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
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AvatarWidget(
                                      imageUrl: comment.user?.imageUrl,
                                      size: AvatarSize.small,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                    ? TimeFormatter
                                                        .formatTimeAgo(
                                                            comment.createdAt!)
                                                    : '',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
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
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    top: false,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Tulis komentar...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              maxLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _addComment(value.trim());
                                  commentController.clear();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              if (commentController.text.trim().isNotEmpty) {
                                _addComment(commentController.text.trim());
                                commentController.clear();
                              }
                            },
                            child: Text(
                              'Kirim',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
      enableDrag: true,
    );
  }

  void _showShare() async {
    final userName = post.user?.name ?? 'Seseorang';
    final content = post.content ?? '';
    final postId = post.id;
    final placeName = post.place?.name;

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

  void _handleFollow() async {
    final userId = post.userId;
    if (userId == null) return;

    try {
      final controller = Get.find<HomeController>();
      await controller.toggleFollowUser(userId);
      Get.snackbar(
        'Berhasil',
        'Status mengikuti diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat mengikuti: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _savePost() {
    final postId = post.id;
    if (postId == null) return;

    try {
      final controller = Get.find<HomeController>();
      controller.toggleSavePost(postId).then((_) {
        Get.snackbar(
          'Berhasil',
          controller.isPostSaved(postId)
              ? 'Postingan disimpan'
              : 'Postingan dihapus dari tersimpan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }).catchError((e) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat menyimpan: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      });
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Fitur simpan tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _addComment(String comment) async {
    final postId = post.id;
    if (postId == null || comment.trim().isEmpty) return;

    try {
      final postRepository = Get.find<PostRepository>();

      // Create comment
      await postRepository.createComment(postId, comment);

      // Fetch updated post data to get latest comments and count
      final updatedPost = await postRepository.getPostById(postId);

      // Update local reactive state - this will update UI immediately
      _comments.value = updatedPost.comments ?? [];
      _commentsCount.value = updatedPost.commentsCount ?? 0;

      // Also sync with HomeController if available
      try {
        final homeController = Get.find<HomeController>();
        homeController.updatePost(updatedPost);
      } catch (e) {
        Logger.warning('HomeController not found, skipping sync', 'PostCard');
      }

      Get.snackbar(
        'Berhasil',
        'Komentar berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Logger.error('Failed to add comment', e, null, 'PostCard');
      Get.snackbar(
        'Gagal',
        'Tidak dapat menambahkan komentar, silakan coba lagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openPlace() async {
    final placeId = post.place?.id;

    if (placeId == null) return;

    try {
      // Show loading
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Fetch full place data
      final placeRepository = Get.find<PlaceRepository>();
      final place = await placeRepository.getPlaceById(placeId);

      // Close loading
      Get.back();

      // Navigate to place detail
      Get.toNamed(AppPages.PLACE_DETAIL, arguments: place);
    } catch (e) {
      // Close loading if open
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        'Error',
        'Gagal memuat detail tempat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
