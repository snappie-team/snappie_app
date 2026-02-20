import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
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
  final bool? isOthersProfile;

  const PostCard({
    super.key,
    required this.post,
    this.isOthersProfile = false,
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
        color: AppColors.backgroundContainer,
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
    final username = post.user?.username ?? 'Unknown';
    final avatarUrl = post.user?.imageUrl;
    final placeName = post.place?.name ?? 'Unknown Place';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: avatarUrl,
            size: AvatarSize.medium,
            frameUrl: post.user?.frameUrl,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.getSize(FontSizeOption.regular),
                  ),
                ),
                Text(
                  placeName,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!(widget.isOthersProfile ?? false)) ...[
            _buildFollowButton(),
            _buildMoreButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    final authService = Get.find<AuthService>();
    final currentUserId = authService.userData?.id;
    final isOwner = post.userId == currentUserId;

    PopupMenuButton<String> buildMenu({PostFollowState? followState}) {
      final canShowUnfollow = followState == PostFollowState.friend ||
          followState == PostFollowState.following;

      Widget menuText(String text) {
        return SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }

      PopupMenuItem<String> menuItem({
        required String value,
        required String text,
      }) {
        return PopupMenuItem<String>(
          value: value,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: menuText(text),
        );
      }

      return PopupMenuButton<String>(
        icon: AppIcon(
          AppAssets.icons.moreDots,
          color: AppColors.textSecondary,
          size: 16,
        ),
        offset: const Offset(-48, 0),
        constraints: const BoxConstraints(
          minWidth: 140,
          maxWidth: 160,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: AppColors.textSecondary),
        ),
        color: AppColors.backgroundContainer,
        elevation: 8,
        onSelected: (value) {
          switch (value) {
            case 'profile':
              _viewProfile();
              break;
            case 'delete':
              _confirmDeletePostModal();
              break;
            case 'follow':
              _handleFollow();
              break;
            case 'report':
              _showReportModal();
              break;
          }
        },
        itemBuilder: (context) => [
          menuItem(value: 'profile', text: 'Lihat Profil'),
          if (isOwner) ...[
            const PopupMenuDivider(height: 8),
            menuItem(value: 'delete', text: 'Hapus'),
          ] else if (canShowUnfollow) ...[
            const PopupMenuDivider(height: 8),
            menuItem(value: 'follow', text: 'Berhenti mengikuti'),
          ],
        ],
      );
    }

    if (isOwner) return buildMenu();

    final userId = post.userId;
    if (userId == null) return buildMenu();

    try {
      final controller = Get.find<HomeController>();
      return Obx(
          () => buildMenu(followState: controller.getFollowState(userId)));
    } catch (e) {
      return buildMenu();
    }
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
                fontSize: FontSize.getSize(FontSizeOption.medium),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kami akan segera menambahkan fitur ini untuk membantu menjaga komunitas Snappie tetap aman.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: FontSize.getSize(FontSizeOption.medium),
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
        backgroundColor: AppColors.backgroundContainer,
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
                  fontSize: FontSize.getSize(FontSizeOption.large),
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Yakin ingin menghapus postingan?',
                style: TextStyle(
                  fontSize: FontSize.getSize(FontSizeOption.medium),
                  color: AppColors.textSecondary,
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
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: FontSize.getSize(FontSizeOption.regular),
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
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Text(
                        'Ya',
                        style: TextStyle(
                          fontSize: FontSize.getSize(FontSizeOption.regular),
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

      AppSnackbar.success('Post berhasil dihapus');
    } catch (e) {
      Logger.error('Failed to delete post', e, null, 'PostCard');
      AppSnackbar.error('Tidak dapat menghapus post, silakan coba lagi');
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
            style: TextStyle(
              fontSize: FontSize.getSize(FontSizeOption.regular),
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
                  color: AppColors.textTertiary,
                  fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
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
            postOverlay: post,
            initialIndex: 0,
            postActionsBuilder: (_) => _buildOverlayPostActions(),
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
                postOverlay: post,
                postActionsBuilder: (_) => _buildOverlayPostActions(),
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
                        color:
                            AppColors.withOpacity(AppColors.textPrimary, 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${index + 1}/${imageUrls.length}',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: FontSize.getSize(FontSizeOption.xxSmall),
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

  Widget _buildOverlayPostActions() {
    return Row(
      children: [
        Expanded(child: Center(child: _buildLikeButton())),
        Expanded(child: Center(child: _buildCommentButton())),
        Expanded(child: Center(child: _buildShareButton())),
        Expanded(child: Center(child: _buildSaveButton())),
      ],
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
                fontSize: FontSize.getSize(FontSizeOption.regular),
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
                fontSize: FontSize.getSize(FontSizeOption.regular),
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
          textStyle: TextStyle(
            fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
            fontWeight: FontWeight.bold,
          ),
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
            isSaved ? AppAssets.icons.saveActive : AppAssets.icons.saveInactive,
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
      AppSnackbar.error('Tidak dapat menyukai post, silakan coba lagi');
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
            decoration: BoxDecoration(
              color: AppColors.backgroundContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Center(
                    child: Text(
                      'Komentar',
                      style: TextStyle(
                        fontSize: FontSize.getSize(FontSizeOption.medium),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Obx(
                    () => _comments.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak Ada Komentar',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
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
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: FontSize.getSize(
                                                      FontSizeOption.regular),
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
                                                  fontSize: FontSize.getSize(
                                                      FontSizeOption.xxSmall),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            comment.comment ?? '',
                                            style: TextStyle(
                                              fontSize: FontSize.getSize(
                                                  FontSizeOption.regular),
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
                        color: AppColors.backgroundContainer,
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
                                  color: AppColors.textTertiary,
                                  fontSize:
                                      FontSize.getSize(FontSizeOption.regular),
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
      AppSnackbar.success('Status mengikuti diperbarui');
    } catch (e) {
      AppSnackbar.error('Tidak dapat mengikuti: $e');
    }
  }

  void _savePost() {
    final postId = post.id;
    if (postId == null) return;

    try {
      final controller = Get.find<HomeController>();
      controller.toggleSavePost(postId).then((_) {
        AppSnackbar.success(
          controller.isPostSaved(postId)
              ? 'Postingan disimpan'
              : 'Postingan dihapus dari tersimpan',
        );
      }).catchError((e) {
        AppSnackbar.error('Tidak dapat menyimpan: $e');
      });
    } catch (e) {
      AppSnackbar.error('Fitur simpan tidak tersedia');
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
      _commentsCount.value = updatedPost.commentsCount ?? 0;

      // Update comments list so new comment appears instantly in bottom sheet
      if (updatedPost.comments != null) {
        _comments.assignAll(updatedPost.comments!);
      }

      // Also sync with HomeController if available
      try {
        final homeController = Get.find<HomeController>();
        homeController.updatePost(updatedPost);
      } catch (e) {
        Logger.warning('HomeController not found, skipping sync', 'PostCard');
      }

      AppSnackbar.success('Komentar berhasil ditambahkan');
    } catch (e) {
      Logger.error('Failed to add comment', e, null, 'PostCard');
      AppSnackbar.error('Tidak dapat menambahkan komentar, silakan coba lagi');
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

      AppSnackbar.error('Gagal memuat detail tempat');
    }
  }
}
