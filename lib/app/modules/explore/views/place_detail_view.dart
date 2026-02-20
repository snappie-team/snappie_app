import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snappie_app/app/core/constants/place_value.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/error_handler.dart';
import '../controllers/explore_controller.dart';
import '../../shared/widgets/index.dart';
import '../../../data/models/place_model.dart';
import '../../../data/models/review_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../mission/controllers/mission_controller.dart';

class PlaceDetailView extends GetView<ExploreController> {
  const PlaceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get place from arguments if passed
    final PlaceModel? place = Get.arguments as PlaceModel?;

    // Load place reviews and saved places when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (place != null) {
        controller.showMissionCtaPrompt();
        controller.selectPlace(place);
        controller.loadPlaceReviews(place.id!);
        controller.loadSavedPlaces();
        controller.loadPlaceGamificationStatus(place.id!);
      }
    });

    if (place == null) {
      return Scaffold(
        body: const Center(
          child: Text('Place not found'),
        ),
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ScaffoldFrame.detail(
          title: place.name ?? 'Place Name not available',
          actions: [
            Obx(() {
              final isSaved =
                  place.id != null && controller.isPlaceSaved(place.id!);
              final isLoading = controller.isTogglingFavorite;
              return IconButton(
                icon: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : AppIcon(
                        isSaved
                            ? AppAssets.icons.saveActive
                            : AppAssets.icons.saveInactive,
                        color: AppColors.primary,
                        size: 24,
                      ),
                onPressed: isLoading ? null : () => _toggleFavorite(place),
              );
            }),
            IconButton(
              icon: AppIcon(AppAssets.icons.share,
                  color: AppColors.primary, size: 24),
              onPressed: () => _showShareDialog(place),
            ),
          ],
          onRefresh: () async {
            if (place.id != null) {
              await controller.loadPlaceReviews(place.id!);
              await controller.loadSavedPlaces();
              await controller.loadPlaceGamificationStatus(place.id!);
            }
          },
          slivers: [
            // Content
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    _buildImageSection(context, place),
                    _buildPlaceHeaderCard(place),
                    if ((place.placeValue?.isNotEmpty ?? false))
                      _buildChipSection(
                        title: 'Cocok Untuk',
                        chips: place.placeValue!,
                      ),
                    if ((place.foodType?.isNotEmpty ?? false))
                      _buildChipSection(
                        title: 'Katalog Makanan',
                        chips: place.foodType!,
                      ),
                    _buildInfoCard(place),
                    if ((place.menu?.isNotEmpty ?? false))
                      _buildMenuSection(context, place),
                    if (_getFacilityChips(place).isNotEmpty)
                      _buildFacilitySection(place, _getFacilityChips(place)),
                    _buildGallerySection(context, place),
                    _buildReviewPreviewSection(place),
                    _buildSimilarPlacesSection(place),
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
          ],
        ),
        Obx(() {
          if (!controller.showMissionCta) {
            return const SizedBox.shrink();
          }
          return Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildMissionCtaCard(place),
          );
        }),
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, PlaceModel? place) {
    double imageHeight = 300;
    final placeImages = place?.imageUrls ?? [];
    final imageUrls = placeImages
        .where((img) => img.url != null)
        .map((img) => img.url!)
        .toList();
    Logger.debug('imageUrls: $imageUrls', 'PlaceDetailView');

    // If no images, show placeholder
    if (imageUrls.isEmpty) {
      return Container(
        height: imageHeight,
        width: double.infinity,
        color: AppColors.background,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
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
                    Icons.image_not_supported,
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
                              Icons.image_not_supported,
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

  Widget _buildPlaceHeaderCard(PlaceModel place) {
    final shortDescription =
        place.placeDetail?.shortDescription ?? place.description ?? '';
    final priceRange = _formatPriceRange(place);

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place.name ?? '-',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          if (shortDescription.isNotEmpty)
            Text(
              shortDescription,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 12),
          if (priceRange != null) ...[
            Text(
              priceRange,
              style: TextStyle(color: AppColors.success),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                return AppIcon(
                  index < (place.avgRating ?? 0).round()
                      ? AppAssets.icons.rating
                      : AppAssets.icons.ratingEmpty,
                  color: AppColors.warning,
                  size: 20,
                );
              }),
              const SizedBox(width: 8),
              Text(
                '${(place.avgRating ?? 0).toStringAsFixed(1)} (${(place.totalReview ?? 0)} ulasan)',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> chips,
  }) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildChipGrid(chips),
        ],
      ),
    );
  }

  Widget _buildChipGrid(List<String> chips) {
    if (chips.isEmpty) return const SizedBox.shrink();
    final rows = _chunkList(chips, 2);

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          Row(
            children: List.generate(2, (colIndex) {
              final currentRow = rows[rowIndex];
              final chipIndex = rowIndex * 2 + colIndex;
              if (colIndex >= currentRow.length) {
                return const Expanded(child: SizedBox.shrink());
              }

              final chip = currentRow[colIndex];
              final style = _chipStyleFor(chip, chipIndex);
              final textColor = style.textColor ?? AppColors.textPrimary;

              return Expanded(
                child: Container(
                  height: 64,
                  margin: EdgeInsets.only(right: colIndex == 0 ? 8 : 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: style.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (style.icon != null) ...[
                        Icon(style.icon, size: 16, color: textColor),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          chip,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize:
                                FontSize.getSize(FontSizeOption.mediumSmall),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          if (rowIndex != rows.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  List<List<String>> _chunkList(List<String> items, int chunkSize) {
    final chunks = <List<String>>[];
    for (var i = 0; i < items.length; i += chunkSize) {
      chunks.add(items.sublist(
          i, i + chunkSize > items.length ? items.length : i + chunkSize));
    }
    return chunks;
  }

  _ChipStyle _chipStyleFor(String label, int index) {
    final colors = _randomChipColors(label, index);
    final backgroundColor = colors.background;
    final textColor = colors.text;
    final icon = _getChipIcon(label);
    return _ChipStyle(
      backgroundColor: backgroundColor,
      icon: icon,
      textColor: textColor,
    );
  }

  static const List<_ChipColorPair> _chipColorPairs = [
    _ChipColorPair(background: Color(0xFFFFF3E0), text: Color(0xFFD84315)),
    _ChipColorPair(background: Color(0xFFE3F2FD), text: Color(0xFF0D47A1)),
    _ChipColorPair(background: Color(0xFFF3E5F5), text: Color(0xFF6A1B9A)),
    _ChipColorPair(background: Color(0xFFE8F5E9), text: Color(0xFF1B5E20)),
    _ChipColorPair(background: Color(0xFFFFEBEE), text: Color(0xFFB71C1C)),
    _ChipColorPair(background: Color(0xFFFFF8E1), text: Color(0xFFF57F17)),
  ];

  _ChipColorPair _randomChipColors(String label, int seed) {
    final palette = _chipColorPairs;
    final safeSeed = (label.hashCode + seed * 17).abs();
    return palette[safeSeed % palette.length];
  }

  IconData? _getChipIcon(String label) {
    // Coba cari di PlaceValue dulu
    final placeIcon = PlaceValueExtension.getIconByLabel(label);
    if (placeIcon != null) return placeIcon;

    return null;
  }

  Widget _buildInfoCard(PlaceModel place) {
    final detail = place.placeDetail;
    final openingDaysText = _formatOpeningDays(detail);
    final openingHoursText = _formatOperatingHours(detail);
    final isOpen = _checkIsOpenNow(detail);

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            title: 'Alamat',
            content: Text(detail?.address ?? 'Alamat belum tersedia'),
            icon: AppIcon(AppAssets.icons.location,
                color: AppColors.textSecondary, size: 20),
            trailing: TextButton(
              onPressed: () => _openMap(place),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: Text('Lihat di peta'),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            title: 'Jam Buka',
            trailing: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  openingDaysText ?? 'Jam operasional belum tersedia',
                ),
                Text(': '),
                Text(
                  openingHoursText ?? 'Jam operasional belum tersedia',
                ),
              ],
            ),
            content: Text(
              isOpen == null
                  ? 'Tidak ada data'
                  : isOpen
                      ? 'Buka Sekarang'
                      : 'Tutup',
              style: TextStyle(
                color: isOpen == null
                    ? AppColors.textSecondary
                    : isOpen
                        ? AppColors.success
                        : AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: AppIcon(AppAssets.icons.clock,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            title: 'Reservasi',
            icon: AppIcon(AppAssets.icons.contact,
                color: AppColors.textSecondary, size: 20),
            trailing: ElevatedButton(
              onPressed: () => _openReservation(detail?.contactNumber),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(99)),
              ),
              child: const Text('WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, PlaceModel place) {
    List<MenuItem> menu = place.menu ?? [];
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Favorit Kami!'),
          const SizedBox(height: 12),
          ...menu.take(3).map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null
                        ? NetworkImageWidget(
                            imageUrl: item.imageUrl!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surfaceContainer,
                            child: AppIcon(
                              AppAssets.icons.camera,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.description != null)
                          Text(
                            item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          item.price != null
                              ? 'Rp ${item.price!.toStringAsFixed(0)}'
                              : '-',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          ElevatedButton(
            onPressed: () => _showMenuDialog(place.menuImageUrl ?? ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99)),
            ),
            child: const Text('Lihat Menu Lengkap'),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySection(PlaceModel place, List<String> facilities) {
    if (facilities.isEmpty) return const SizedBox.shrink();
    final visibleFacilities = facilities.take(6).toList();

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Fasilitas',
              onSeeAll: () => _showFacilitiesDialog(place, facilities)),
          const SizedBox(height: 12),
          _buildChipGrid(visibleFacilities),
        ],
      ),
    );
  }

  List<String> _getFacilityChips(PlaceModel place) {
    final attributes = place.placeAttributes;
    final facilities = <String>[];
    void addAll(List<dynamic>? list) {
      if (list == null) return;
      for (final item in list) {
        final name = (item as dynamic).name as String?;
        if (name != null) facilities.add(name);
      }
    }

    addAll(attributes?.facility);
    addAll(attributes?.service);
    addAll(attributes?.parking);
    addAll(attributes?.capacity);
    addAll(attributes?.accessibility);
    addAll(attributes?.payment);

    return facilities;
  }

  Widget _buildGallerySection(BuildContext context, PlaceModel place) {
    return Obx(() {
      final photos = <String>[];
      if (place.imageUrls != null)
        photos.addAll(place.imageUrls!
            .where((img) => img.url != null)
            .map((img) => img.url!));
      for (final review in controller.reviews) {
        if (review.imageUrls != null) {
          photos.addAll(review.imageUrls!);
        }
      }

      const double imageSize = 120;

      if (photos.isEmpty) {
        return _buildSectionCard(
          child: _buildSectionHeader('Galeri Bersama',
              child: const Text('Belum ada foto')),
        );
      }

      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Galeri Bersama',
                onSeeAll: () => _showGalleryPage(place)),
            const SizedBox(height: 12),
            SizedBox(
              height: imageSize,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: NetworkImageWidget(
                        imageUrl: photos[index],
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      FullscreenImageViewer.show(
                        context: context,
                        imageUrls: photos,
                        initialIndex: index,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildReviewPreviewSection(PlaceModel place) {
    return Obx(() {
      final reviews = controller.reviews;
      final isLoading = controller.isLoadingReviews;

      return _buildSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Ulasan',
                onSeeAll: () => _showReviewsPage(place)),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: LoadingStateWidget())
            else if (reviews.isEmpty)
              const NoDataEmptyState(
                title: 'Belum ada ulasan',
                subtitle: 'Jadilah yang pertama menulis ulasan',
              )
            else
              ...reviews.take(3).map(_buildReviewTile),
          ],
        ),
      );
    });
  }

  Widget _buildReviewTile(ReviewModel review) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Row(
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
                    spacing: 4,
                    children: [
                      Text(
                        review.user?.name ?? 'Anonim',
                        style: TextStyle(
                            fontSize:
                                FontSize.getSize(FontSizeOption.mediumSmall),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return AppIcon(
                            index < (review.rating ?? 0)
                                ? AppAssets.icons.rating
                                : AppAssets.icons.ratingEmpty,
                            color: AppColors.warning,
                            size: 20,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt ?? DateTime.now()),
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          if (review.content != null) ...[
            Text(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              review.content!,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: FontSize.getSize(FontSizeOption.mediumSmall),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _formatPriceRange(PlaceModel place) {
    final min = place.minPrice;
    final max = place.maxPrice;
    if (min == null && max == null) return null;
    if (min != null && max != null) {
      return 'Rp ${min.toStringAsFixed(0)} - Rp ${max.toStringAsFixed(0)}/orang';
    }
    final value = min ?? max;
    return value != null ? 'Mulai Rp ${value.toStringAsFixed(0)}' : null;
  }

  bool? _checkIsOpenNow(PlaceDetail? detail) {
    if (detail == null) return null;
    if (detail.openingHours == null || detail.closingHours == null) return null;

    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

      // Parse opening hours (format: "HH:MM" or "HH.MM")
      final openingParts = detail.openingHours!.split(RegExp(r'[:.]'));
      final openingTime = TimeOfDay(
        hour: int.parse(openingParts[0]),
        minute: openingParts.length > 1 ? int.parse(openingParts[1]) : 0,
      );

      // Parse closing hours
      final closingParts = detail.closingHours!.split(RegExp(r'[:.]'));
      final closingTime = TimeOfDay(
        hour: int.parse(closingParts[0]),
        minute: closingParts.length > 1 ? int.parse(closingParts[1]) : 0,
      );

      // Convert to minutes for comparison
      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final openingMinutes = openingTime.hour * 60 + openingTime.minute;
      final closingMinutes = closingTime.hour * 60 + closingTime.minute;

      // Handle overnight hours (e.g., 22:00 - 02:00)
      if (closingMinutes < openingMinutes) {
        return currentMinutes >= openingMinutes ||
            currentMinutes < closingMinutes;
      }

      return currentMinutes >= openingMinutes &&
          currentMinutes < closingMinutes;
    } catch (e) {
      Logger.error('Error parsing opening hours: $e', 'PlaceDetailView');
      return null;
    }
  }

  String? _formatOpeningDays(PlaceDetail? detail) {
    if (detail == null ||
        detail.openingDays == null ||
        detail.openingDays!.isEmpty) {
      return null;
    }

    final days = detail.openingDays!;
    if (days.length == 1) {
      return days.first;
    }

    // Create range from first to last day
    return '${days.first} - ${days.last}';
  }

  String? _formatOperatingHours(PlaceDetail? detail) {
    if (detail == null) return null;
    if (detail.openingHours == null || detail.closingHours == null) return null;
    return '${detail.openingHours} - ${detail.closingHours} WIB';
  }

  void _openMap(PlaceModel place) async {
    final lat = place.latitude;
    final lng = place.longitude;

    if (lat == null || lng == null) {
      Get.snackbar(
        'Petunjuk Arah',
        'Koordinat lokasi tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    // Try Google Maps app first, fallback to browser
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      final launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka aplikasi peta',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'PlaceDetailView'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    }
  }

  void _openReservation(String? contactNumber) async {
    if (contactNumber == null || contactNumber.isEmpty) {
      Get.snackbar(
        'Reservasi',
        'Kontak reservasi belum tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    // Format phone number: remove non-digit characters
    String formattedNumber = contactNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // Handle various formats
    if (formattedNumber.startsWith('+62')) {
      formattedNumber = formattedNumber.substring(1); // Remove + for wa.me
    } else if (formattedNumber.startsWith('62')) {
      // Already in correct format
    } else if (formattedNumber.startsWith('0')) {
      formattedNumber = '62${formattedNumber.substring(1)}';
    } else {
      formattedNumber = '62$formattedNumber';
    }

    final whatsappUrl = Uri.parse('https://wa.me/$formattedNumber');

    try {
      final launched = await launchUrl(
        whatsappUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'PlaceDetailView'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    }
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
      // Initialize mission controller (check if already registered)
      if (!Get.isRegistered<MissionController>()) {
        Get.put(MissionController());
      }
      final missionController = Get.find<MissionController>();
      missionController.initMission(place, hideUsername: result.hideUsername);

      Get.toNamed(AppPages.MISSION_PHOTO);
    }
  }

  void _showMenuDialog(String menuImageUrl) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowDark,
                blurRadius: 8,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Daftar Menu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (menuImageUrl.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Center(
                      child: NetworkImageWidget(
                        imageUrl: menuImageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      'Menu belum tersedia',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFacilitiesDialog(PlaceModel place, List<String> facilities) {
    Get.toNamed(
      AppPages.FACILITIES,
      arguments: {
        'placeAttributes': place.placeAttributes,
        'placeName': place.name ?? 'Tempat',
      },
    );
  }

  void _showReviewsPage(PlaceModel place) {
    Get.toNamed(
      AppPages.REVIEWS,
      arguments: place,
    );
  }

  Widget _buildSimilarPlacesSection(PlaceModel currentPlace) {
    final similarPlaces = controller.places
        .where((item) => item.id != currentPlace.id)
        .take(3)
        .toList();

    if (similarPlaces.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Tempat Serupa Lainnya'),
          const SizedBox(height: 12),
          ...similarPlaces.map((place) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: place.imageUrls?.isNotEmpty == true
                        ? NetworkImageWidget(
                            imageUrl: place.imageUrls!.first.url ?? '',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 70,
                            height: 70,
                            color: AppColors.surfaceContainer,
                            child: AppIcon(
                              AppAssets.icons.camera,
                              color: AppColors.textSecondary,
                              size: 36,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          place.name ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          place.description ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                        Row(
                          children: [
                            AppIcon(AppAssets.icons.rating,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 4),
                            Text((place.avgRating ?? 0).toStringAsFixed(1)),
                          ],
                        ),
                      ],
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

  Widget _buildSectionCard({required Widget child, EdgeInsets? margin}) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMissionCtaCard(PlaceModel place) {
    return Material(
      color: Colors.transparent,
      elevation: 12,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 16,
              offset: const Offset(-4, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selesaikan Misi!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dapatkan hadiah dengan menyelesaikan misi!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.hideMissionCta,
                  icon: AppIcon(AppAssets.icons.close,
                      color: AppColors.textSecondary, size: 20),
                  splashRadius: 18,
                  tooltip: 'Tutup',
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startMission(place),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Mulai Misi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    // String? value,
    required Widget icon,
    Widget? content,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (content != null) ...[const SizedBox(height: 4), content],
              if (trailing != null) ...[const SizedBox(height: 4), trailing],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title,
      {VoidCallback? onSeeAll, Widget? child}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (child != null) child,
        if (child == null && onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'Lihat Selengkapnya',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
      ],
    );
  }

  void _showShareDialog(PlaceModel place) async {
    final placeName = place.name ?? 'Tempat Menarik';
    final description = place.description ?? '';
    final lat = place.latitude;
    final lng = place.longitude;

    String shareText = '🍽️ $placeName\n';
    if (description.isNotEmpty) {
      shareText += '\n$description\n';
    }
    if (lat != null && lng != null) {
      shareText +=
          '\n📍 Lihat di Google Maps:\nhttps://www.google.com/maps/search/?api=1&query=$lat,$lng';
    }
    shareText += '\n\nTemukan di Snappie App! 📱';

    await SharePlus.instance.share(
      ShareParams(
        text: shareText,
        subject: 'Cek tempat ini: $placeName',
      ),
    );
  }

  void _toggleFavorite(PlaceModel place) async {
    if (place.id == null) {
      Get.snackbar(
        'Error',
        'Tidak dapat menyimpan tempat ini',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    try {
      final isNowSaved = await controller.toggleSavedPlace(place.id!);

      Get.snackbar(
        isNowSaved ? 'Disimpan' : 'Dihapus',
        isNowSaved
            ? '${place.name} ditambahkan ke favorit'
            : '${place.name} dihapus dari favorit',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isNowSaved ? AppColors.success : AppColors.primary,
        colorText: AppColors.textOnPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'PlaceDetailView'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    }
  }

  // ignore: unused_element
  void _showCheckinDialog(PlaceModel place) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Check In',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Check in at ${place.name}?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            if (place.partnershipStatus == true) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rewards Available:',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (place.expReward! > 0)
                      Text(
                        '• ${place.expReward} XP',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    if (place.coinReward! > 0)
                      Text(
                        '• ${place.coinReward} Coins',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Obx(() => ElevatedButton(
                onPressed: controller.isCreatingCheckin
                    ? null
                    : () => _performCheckin(place),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                ),
                child: controller.isCreatingCheckin
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Check In'),
              )),
        ],
      ),
    );
  }

  void _performCheckin(PlaceModel place) async {
    // Get current location (mock coordinates for now)
    const latitude = -6.2088;
    const longitude = 106.8456;

    await controller.createCheckin(
      placeId: place.id!,
      latitude: latitude,
      longitude: longitude,
    );

    Get.back();
  }

  void _showGalleryPage(PlaceModel place) {
    Get.toNamed(
      AppPages.GALLERY,
      arguments: place,
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _ChipStyle {
  final Color backgroundColor;
  final IconData? icon;
  final Color? textColor;
  const _ChipStyle({
    required this.backgroundColor,
    this.icon,
    this.textColor,
  });
}

class _ChipColorPair {
  final Color background;
  final Color text;
  const _ChipColorPair({
    required this.background,
    required this.text,
  });
}
