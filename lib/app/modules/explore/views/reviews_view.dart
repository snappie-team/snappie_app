import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return ScaffoldFrame.detail(
      title: 'Ulasan',
      onRefresh: () async {
        await controller.loadPlaceReviews(place.id!);
      },
      slivers: [
        // Content
        SliverToBoxAdapter(
          child: Obx(() => _buildContent(context, place)),
        ),
      ],
    );
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
    if (controller.isLoadingReviews) {
      return const Center(child: LoadingStateWidget());
    }

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          // Filter chips
          _buildFilterChips(place),
      
          // CTA Berikan Ulasan
          _buildGiveReviewCTA(),
                
          // Rating summary
          _buildRatingSummary(place),
      
          // Reviews list
          if (controller.reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: NoDataEmptyState(
                title: 'Belum ada ulasan',
                subtitle: 'Jadilah yang pertama menulis ulasan',
              ),
            )
          else
            _buildReviewsList(),
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
            Expanded(
              child: _buildFilterChip(
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

            // Bintang dropdown
            Expanded(
              child: _buildRatingDropdown(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
          child: Text(
            count != null ? '$label\n($count)' : label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.primary,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color:
            _selectedRating != null ? AppColors.primary : AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary,
        ),
      ),
      child: PopupMenuButton<int?>(
        offset: const Offset(0, 40),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bintang ★\n(${_selectedRating != null ? '$_selectedRating' : 'Semua'})',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _selectedRating != null
                      ? Colors.white
                      : AppColors.primary,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color:
                    _selectedRating != null ? Colors.white : AppColors.primary,
              ),
            ],
          ),
        ),
        itemBuilder: (context) => [
          PopupMenuItem<int?>(
            value: null,
            child: Text('Semua'),
          ),
          ...List.generate(5, (index) {
            final rating = 5 - index;
            return PopupMenuItem<int?>(
              value: rating,
              child: Row(
                children: [
                  ...List.generate(
                      rating,
                      (_) =>
                          AppIcon(AppAssets.icons.rating, color: AppColors.warning, size: 16)),
                  // TODO: Add star_border.svg icon to assets/iconsvg/
                  ...List.generate(
                      5 - rating,
                      (_) => Icon(Icons.star_border,
                          color: AppColors.textTertiary, size: 16)),
                  const SizedBox(width: 8),
                  Text('(${_ratingCounts[rating] ?? 0})'),
                ],
              ),
            );
          }),
        ],
        onSelected: (value) {
          setState(() {
            _selectedRating = value;
            if (value != null) {
              _selectedFilter =
                  'all'; // Reset media filter when selecting rating
            }
          });
        },
      ),
    );
  }

  Widget _buildGiveReviewCTA() {
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
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Berikan ulasan untuk mendapatkan '),
                TextSpan(
                  text: '50 XP',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: '25 Koin',
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
              final PlaceModel? place = Get.arguments as PlaceModel?;
              if (place != null) {
                Get.toNamed(AppPages.MISSION_REVIEW, arguments: place);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Berikan Ulasan',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                // TODO: Add chevron_right.svg icon to assets/iconsvg/
                Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(PlaceModel place) {
    final totalReviews = controller.reviews.length;
    final avgRating = place.avgRating ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Big rating number
          Text(
            avgRating.toStringAsFixed(1).replaceAll('.', ','),
            style: TextStyle(
              fontSize: 56,
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
                return AppIcon(AppAssets.icons.rating, color: AppColors.warning, size: 28);
              } else if (avgRating >= starValue - 0.5) {
                // TODO: Add star_half.svg icon to assets/iconsvg/
                return Icon(Icons.star_half,
                    color: AppColors.warning, size: 28);
              } else {
                // TODO: Add star_border.svg icon to assets/iconsvg/
                return Icon(Icons.star_border,
                    color: AppColors.warning, size: 28);
              }
            }),
          ),
          const SizedBox(height: 4),

          // Total reviews
          Text(
            '($totalReviews Ulasan)',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Rating breakdown bars
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = _ratingCounts[rating] ?? 0;
            final percentage = totalReviews > 0 ? count / totalReviews : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    '$rating',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcon(AppAssets.icons.rating, color: AppColors.warning, size: 16),
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
                      fontSize: 14,
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
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: reviews.length,
        separatorBuilder: (context, index) => Divider(
          height: 24,
          thickness: 1,
          color: AppColors.surfaceContainer,
        ),
        itemBuilder: (context, index) {
          return _buildReviewCard(reviews[index]);
        },
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User info row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AvatarWidget(
              imageUrl: review.user?.imageUrl,
              size: AvatarSize.medium,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.user?.name ?? 'Anonim',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (review.rating ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.warning,
                        size: 16,
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
                fontSize: 12,
              ),
            ),
          ],
        ),
    
        // Review content
        if (review.content != null && review.content!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            review.content!,
            style: TextStyle(
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
    
        // Review images
        if (review.imageUrls != null && review.imageUrls!.isNotEmpty) ...[
          const SizedBox(height: 12),
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
