import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/modules/shared/widgets/_form_widgets/rectangle_button_widget.dart';
import '../_display_widgets/avatar_widget.dart';
import '../_display_widgets/fullscreen_image_viewer.dart';
import '../_navigation_widgets/button_widget.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/post_model.dart';
import '../../../../modules/home/controllers/home_controller.dart';
import '../../../../routes/app_pages.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

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
          ButtonWidget(
            icon: Icons.more_vert_outlined,
            iconColor: AppColors.textPrimary,
            onPressed: () => _showPostOptions(post),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(PostModel post) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Simpan Post'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Post disimpan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: Text('Sembunyikan dari ${post.user?.name}'),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Post disembunyikan');
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Laporkan Post',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                Get.snackbar('Info', 'Post dilaporkan');
              },
            ),
          ],
        ),
      ),
    );
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
    // Use first image from imageUrls array
    // final imageUrl = (post.imageUrls != null && post.imageUrls!.isNotEmpty) ? post.imageUrls!.first : 'https://statik.tempo.co/data/2023/12/19/id_1264597/1264597_720.jpg';
    //  final imageUrls = post.imageUrls ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GestureDetector(
        //   onTap: () {
        //     FullscreenImageViewer.show(
        //       context: context,
        //       imageUrls: post.imageUrls ?? [imageUrl],
        //       initialIndex: 0,
        //       postOverlay: post,
        //     );
        //   },
        //   child: Container(
        //     width: double.infinity,
        //     constraints: const BoxConstraints(
        //       maxHeight: 400, // Limit maximum height to prevent overflow
        //     ),
        //     decoration: BoxDecoration(
        //       color: Colors.grey[200],
        //     ),
        //     child: Image.network(
        //       imageUrl,
        //       fit: BoxFit.cover, // Changed from fill to cover for better aspect ratio
        //       loadingBuilder: (context, child, loadingProgress) {
        //         if (loadingProgress == null) return child;
        //         return Container(
        //           height: 300,
        //           color: Colors.grey[200],
        //           child: Center(
        //             child: CircularProgressIndicator(
        //               value: loadingProgress.expectedTotalBytes != null
        //                   ? loadingProgress.cumulativeBytesLoaded /
        //                       loadingProgress.expectedTotalBytes!
        //                   : null,
        //               strokeWidth: 2,
        //               color: Colors.grey[400],
        //             ),
        //           ),
        //         );
        //       },
        //       errorBuilder: (context, error, stackTrace) {
        //         return Container(
        //           height: 200,
        //           padding: const EdgeInsets.all(20),
        //           color: Colors.grey[200],
        //           child: const Center(
        //             child: Icon(
        //               Icons.image_not_supported_outlined,
        //               color: Colors.grey,
        //               size: 40,
        //             ),
        //           ),
        //         );
        //       },
        //     ),
        //   ),
        // ),
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
              // const SizedBox(width: 8),
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
      return Container(
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
    final controller = Get.find<HomeController>();
    final postId = post.id;

    if (postId == null) return const SizedBox.shrink();

    return Obx(() {
      final isLiked = controller.isPostLiked(postId);
      final isLoading = controller.isTogglingLikePost(postId);

      if (isLoading) {
        return Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${post.likesCount ?? 0}',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
              ),
            ),
          ],
        );
      }

      return GestureDetector(
        onTap: _handleLike,
        child: Row(
          children: [
            Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              '${post.likesCount ?? 0}',
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
    return GestureDetector(
      onTap: _showComments,
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: AppColors.accent,
            size: 24,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.commentsCount ?? 0}',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: _showShare,
      child: Icon(
        Icons.share_outlined,
        color: AppColors.accent,
        size: 24,
      ),
    );
  }

  Widget _buildFollowButton() {
    final controller = Get.find<HomeController>();
    final authService = Get.find<AuthService>();

    final userId = post.userId;
    final currentUserId = authService.userData?.id;

    if (userId == null || currentUserId == null || userId == currentUserId) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final state = controller.getFollowState(userId);
      final isOutline =
          state == PostFollowState.friend || state == PostFollowState.following;

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
  }

  Widget _buildSaveButton() {
    final controller = Get.find<HomeController>();
    final postId = post.id;

    if (postId == null) return const SizedBox.shrink();

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

      // Inverse of follow button:
      // - saved => full color
      // - not saved => outline
      if (isSaved) {
        return GestureDetector(
          onTap: _savePost,
          child: Icon(
            Icons.bookmark,
            color: AppColors.accent,
            size: 24,
          ),
        );
      }

      return GestureDetector(
        onTap: _savePost,
        child: Icon(
          Icons.bookmark_border,
          color: AppColors.accent,
          size: 24,
        ),
      );
    });
  }

  void _handleLike() async {
    final controller = Get.find<HomeController>();
    final postId = post.id;
    if (postId == null) return;

    try {
      await controller.toggleLikePost(postId);
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menyukai post: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showComments() {
    final TextEditingController commentController = TextEditingController();
    final authService = Get.find<AuthService>();
    final comments = post.comments ?? [];

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
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: Center(
                    child: Text(
                      'Komentar (${comments.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: comments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
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
                                                  ? TimeFormatter.formatTimeAgo(
                                                      comment.createdAt!)
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
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        AvatarWidget(
                          imageUrl: authService.userData?.imageUrl,
                          size: AvatarSize.small,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: 'Tulis komentar...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
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
                        IconButton(
                          onPressed: () {
                            if (commentController.text.trim().isNotEmpty) {
                              _addComment(commentController.text.trim());
                              commentController.clear();
                            }
                          },
                          icon: Icon(Icons.send, color: AppColors.primary),
                        ),
                      ],
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
    final controller = Get.find<HomeController>();

    try {
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
    final controller = Get.find<HomeController>();
    final postId = post.id;
    if (postId == null) return;

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
  }

  void _addComment(String comment) async {
    final postId = post.id;
    if (postId == null || comment.trim().isEmpty) return;

    try {
      final postRepository = Get.find<PostRepository>();
      await postRepository.createComment(postId, comment);

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Komentar berhasil ditambahkan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat menambahkan komentar: $e',
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
