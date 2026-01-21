import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/widgets/_display_widgets/avatar_widget.dart';
import 'package:snappie_app/app/data/models/post_model.dart';

class FullscreenImageViewer {
  /// Show fullscreen image viewer with a list of image URLs.
  /// 
  /// [imageUrls] - List of image URLs to display
  /// [initialIndex] - Starting index in the image list (default: 0)
  /// [postOverlay] - Optional PostModel to show user info overlay (for social posts)
  static void show({
    required BuildContext context,
    required List<String> imageUrls,
    int initialIndex = 0,
    bool isCarousel = false,
    PostModel? postOverlay,
    WidgetBuilder? postActionsBuilder,
  }) {
    if (imageUrls.isEmpty) return;
    
    final safeIndex = initialIndex.clamp(0, imageUrls.length - 1);
    final showCarousel = isCarousel && imageUrls.length > 1;
    int currentIndex = safeIndex;
    // Hide system UI for true fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Get.dialog(
      WillPopScope(
         onWillPop: () async {
           return true; // Allow the pop, system UI will be restored in .then()
         },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: StatefulBuilder(
            builder: (context, setState) {
              final mediaQuery = MediaQuery.of(context);
              const carouselHeight = 90.0;
              final postOverlayBottom = mediaQuery.padding.bottom +
                  (showCarousel ? carouselHeight + 28 : 20);

              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20),
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          imageUrls[currentIndex],
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 64,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: mediaQuery.padding.top,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  if (showCarousel)
                    Positioned(
                      bottom: mediaQuery.padding.bottom + 12,
                      left: 12,
                      right: 12,
                      child: SizedBox(
                        height: carouselHeight,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            final isActive = index == currentIndex;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                              child: Container(
                                width: carouselHeight,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ColorFiltered(
                                    colorFilter: isActive
                                        ? const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.multiply,
                                          )
                                        : const ColorFilter.matrix(<double>[
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0, 0, 0, 1, 0,
                                          ]),
                                    child: Image.network(
                                      imageUrls[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (postOverlay != null)
                    Positioned(
                      bottom: postOverlayBottom,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                AvatarWidget(
                                  imageUrl: postOverlay.user?.imageUrl ?? '',
                                  size: AvatarSize.small,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        postOverlay.user?.name ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        postOverlay.place?.name ?? '',
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (postActionsBuilder != null)
                              postActionsBuilder(context)
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.favorite,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${postOverlay.likesCount ?? 0}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${postOverlay.commentsCount ?? 0}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.share_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: const Icon(
                                          Icons.bookmark_border,
                                          color: Colors.white,
                                          size: 20,
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
                ],
              );
            },
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.transparent,
    ).then((_) {
      // Ensure system UI is restored when dialog is dismissed by any means
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }
}
