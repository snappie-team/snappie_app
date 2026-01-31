import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/mission/controllers/mission_controller.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../data/models/place_model.dart';
import '../../../data/models/review_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/explore_controller.dart';
import '../../shared/widgets/index.dart';

class ReviewsView extends StatefulWidget {
  const ReviewsView({super.key});

  @override
  State<ReviewsView> createState() => _ReviewsViewState();
}

class _ReviewsViewState extends State<ReviewsView> {
  final ExploreController controller = Get.find<ExploreController>();

  // Filter state
  String _selectedFilter = 'all'; // 'all', 'with_media'
  int? _selectedRating; // null = semua, 1-5 = rating tertentu

  @override
  void initState() {
    super.initState();
    final PlaceModel? place = Get.arguments as PlaceModel?;
    if (place != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.loadPlaceReviews(place.id!);
        controller.loadPlaceGamificationStatus(place.id!);
      });
    }
  }

  List<ReviewModel> get _filteredReviews {
    List<ReviewModel> reviews = controller.reviews.toList();

    // Filter by media
    if (_selectedFilter == 'with_media') {
      reviews = reviews
          .where((r) => r.imageUrls != null && r.imageUrls!.isNotEmpty)
          .toList();
    }

    // Filter by rating
    if (_selectedRating != null) {
      reviews = reviews.where((r) => r.rating == _selectedRating).toList();
    }

    return reviews;
  }

  int get _reviewsWithMediaCount {
    return controller.reviews
        .where((r) => r.imageUrls != null && r.imageUrls!.isNotEmpty)
        .length;
  }

  Map<int, int> get _ratingCounts {
    final counts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in controller.reviews) {
      final rating = review.rating ?? 0;
      if (rating >= 1 && rating <= 5) {
        counts[rating] = counts[rating]! + 1;
      }
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final PlaceModel? place = Get.arguments as PlaceModel?;

    if (place == null) {
      return Scaffold(
        body: Center(
          child: _buildEmptyState('Data tidak ditemukan'),
        ),
      );
    }

    return Obx(() {
      return LoadingOverlayWidget(
        isLoading: controller.isLoadingReviews,
        message: 'Memuat ulasan...',
        child: ScaffoldFrame.detail(
          title: 'Ulasan',
          onRefresh: () async {
            await controller.loadPlaceReviews(place.id!);
          },
          slivers: [
            SliverToBoxAdapter(
              child: _buildContent(context, place),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlaceModel place) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildFilterChips(place),
          _buildGiveReviewCTA(place),
          if (_selectedFilter == 'all') _buildRatingSummary(place),
          if (controller.reviews.isEmpty)
            controller.isLoadingReviews
                ? const SizedBox(height: 240)
                : const Padding(
                    padding: EdgeInsets.all(32),
                    child: NoDataEmptyState(
                      title: 'Belum ada ulasan',
                      subtitle: 'Jadilah yang pertama menulis ulasan',
                    ),
                  )
          else _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildFilterChips(PlaceModel place) {
    return Container(
      decoration: BoxDecoration(color: AppColors.backgroundContainer),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Semua chip
            _buildFilterChip(
              label: 'Semua',
              count: controller.reviews.length,
              isSelected: _selectedFilter == 'all' && _selectedRating == null,
              onTap: () {
                setState(() {
                  _selectedFilter = 'all';
                  _selectedRating = null;
                });
              },
            ),
            const SizedBox(width: 8),

            // Dengan Foto/Video chip
            Expanded(
              child: _buildFilterChip(
                label: 'Dengan Foto/Video',
                count: _reviewsWithMediaCount,
                isSelected: _selectedFilter == 'with_media',
                onTap: () {
                  setState(() {
                    _selectedFilter = 'with_media';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),

            // Bintang filter
            _buildFilterChip(
              label: 'Bintang ★',
              subtitle: _selectedRating != null ? '$_selectedRating' : 'Semua',
              showDropdownIcon: true,
              isSelected: _selectedRating != null,
              onTap: () {
                _showRatingBottomSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? subtitle,
    int? count,
    bool showDropdownIcon = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final effectiveSubtitle = subtitle ?? (count != null ? '$count' : null);
    final text = effectiveSubtitle != null ? '$label\n($effectiveSubtitle)' : label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary,
          ),
        ),
        child: Center(
          child: showDropdownIcon
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: FontSize.getSize(FontSizeOption.regular),
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.primary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AppIcon(
                      AppAssets.icons.more,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ],
                )
              : Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: FontSize.getSize(FontSizeOption.regular),
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.primary,
                    height: 1.2,
                  ),
                ),
        ),
      ),
    );
  }

  void _showRatingBottomSheet() {
    final maxCount = _ratingCounts.values.fold<int>(0, (prev, el) => el > prev ? el : prev);
    int? tempSelected = _selectedRating;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          Widget buildRatingRow(int rating) {
            final count = _ratingCounts[rating] ?? 0;
            final value = maxCount == 0 ? 0.0 : (count / maxCount);
            final isSelected = tempSelected == rating;

            return InkWell(
              onTap: () => setModalState(() => tempSelected = rating),
              child: SizedBox(
                height: 44,
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: Center(
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AppIcon(
                            AppAssets.icons.rating,
                            color: AppColors.warning,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceContainer,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '(${controller.reviews.length} Ulasan)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: AppIcon(AppAssets.icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  buildRatingRow(5),
                  buildRatingRow(4),
                  buildRatingRow(3),
                  buildRatingRow(2),
                  buildRatingRow(1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedRating = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Hapus'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedRating = tempSelected;
                              if (tempSelected != null) {
                                _selectedFilter = 'all';
                              }
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                          child: const Text('Ok'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGiveReviewCTA(PlaceModel place) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.regular),
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Berikan ulasan untuk mendapatkan '),
                TextSpan(
                  text: '${place.expReward} XP',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: '${place.coinReward} Koin',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '!'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (!controller.canReview) {
                Get.snackbar(
                  'Ulasan sudah selesai',
                  'Kamu sudah mengulas tempat ini bulan ini.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.warning,
                  colorText: AppColors.textOnPrimary,
                );
                return;
              }
              if (controller.hasCheckinThisMonth && !controller.hasReviewThisMonth) {
                Get.toNamed(AppPages.MISSION_REVIEW, arguments: place);
                return;
              }
              _showMissionRequiredModal(place);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Berikan Ulasan',
                  style: TextStyle(
                    fontSize: FontSize.getSize(FontSizeOption.regular),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(width: 4),

                AppIcon(AppAssets.icons.moreOption3, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(PlaceModel place) {
    final selectedRating = _selectedRating;
    final totalReviews = selectedRating != null
        ? (_ratingCounts[selectedRating] ?? 0)
        : controller.reviews.length;
    final avgRating = selectedRating?.toDouble() ?? (place.avgRating ?? 0.0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (selectedRating == null) ...[
            // Big rating number
            Text(
              avgRating.toStringAsFixed(1).replaceAll('.', ','),
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.xl8),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                if (avgRating >= starValue) {
                  return AppIcon(
                    AppAssets.icons.rating,
                    color: AppColors.warning,
                    size: FontSize.getSize(FontSizeOption.xl2),
                  );
                } else if (avgRating >= starValue - 0.5) {
                  // TODO: Add star_half.svg icon to assets/icons/
                  return AppIcon(
                    AppAssets.icons.ratingAlt,
                    color: AppColors.warning,
                    size: FontSize.getSize(FontSizeOption.xl2),
                  );
                } else {
                  // TODO: Add star_border.svg icon to assets/icons/
                  return AppIcon(
                    AppAssets.icons.ratingEmpty,
                    color: AppColors.warning,
                    size: FontSize.getSize(FontSizeOption.xl2),
                  );
                }
              }),
            ),

            const SizedBox(height: 8),

            // Total reviews
            Text(
              '($totalReviews Ulasan)',
              style: TextStyle(
                fontSize: FontSize.getSize(FontSizeOption.regular),
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Rating breakdown bars
          ...List.generate(selectedRating != null ? 1 : 5, (index) {
            final rating = selectedRating ?? (5 - index);
            final count = _ratingCounts[rating] ?? 0;
            final percentage = selectedRating != null
                ? (count > 0 ? 1.0 : 0.0)
                : (totalReviews > 0 ? count / totalReviews : 0.0);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: FontSize.getSize(FontSizeOption.regular),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcon(
                    AppAssets.icons.rating,
                    color: AppColors.warning,
                    size: FontSize.getSize(FontSizeOption.regular),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceContainer,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($count)',
                    style: TextStyle(
                      fontSize: FontSize.getSize(FontSizeOption.regular),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviews = _filteredReviews;

    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Tidak ada ulasan dengan filter ini',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: reviews.length,
        separatorBuilder: (context, index) => SizedBox(height: 24),
        itemBuilder: (context, index) {
          return _buildReviewCard(reviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final hideUsername =
        review.additionalInfo?['hide_username'] == true;
    final displayName =
        hideUsername ? 'Anonim' : (review.user?.name ?? 'Anonim');
    final displayImageUrl = hideUsername ? null : review.user?.imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(
              imageUrl: displayImageUrl,
              size: AvatarSize.medium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: FontSize.getSize(FontSizeOption.regular),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return AppIcon(
                        index < (review.rating ?? 0)
                            ? AppAssets.icons.rating
                            : AppAssets.icons.ratingEmpty,
                        color: AppColors.warning,
                        size: FontSize.getSize(FontSizeOption.medium),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Text(
              _formatDate(review.createdAt ?? DateTime.now()),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
              ),
            ),
          ],
        ),
    
        // Review content
        if (review.content != null && review.content!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            review.content!,
            style: TextStyle(
              fontSize: FontSize.getSize(FontSizeOption.regular),
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
    
        // Review images
        if (review.imageUrls != null && review.imageUrls!.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: review.imageUrls!.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    FullscreenImageViewer.show(
                      context: context,
                      imageUrls: review.imageUrls!,
                      initialIndex: index,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageWidget(
                      imageUrl: review.imageUrls![index],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showMissionRequiredModal(PlaceModel place) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.images.mission,
                height: 100,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.flag_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Selesaikan Misi Dulu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Untuk memberikan ulasan dan mendapatkan reward, kamu harus menyelesaikan misi foto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: Text(
                            'Mengerti',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            _startMission(place);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.textOnPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          child: const Text(
                            'Misi Foto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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

  void _startMission(PlaceModel place) async {
    await controller.loadPlaceGamificationStatus(place.id!);
    if (!controller.canCheckin || !controller.canReview) {
      Get.snackbar(
        'Misi sudah selesai',
        'Kamu sudah menyelesaikan misi atau ulasan untuk tempat ini bulan ini.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    final result = await MissionConfirmModal.show(place: place);

    if (result != null && result.confirmed) {
      // Initialize mission controller and navigate
      final missionController = Get.put(MissionController());
      missionController.initMission(place, hideUsername: result.hideUsername);

      Get.toNamed(AppPages.MISSION_PHOTO);
    }
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
