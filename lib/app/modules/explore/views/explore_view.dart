import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../controllers/explore_controller.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/logger_service.dart';
import '../../shared/widgets/index.dart';

class ExploreView extends GetView<ExploreController> {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger lazy initialization saat view pertama kali di-build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeIfNeeded();
    });

    return ScaffoldFrame(
      controller: controller,
      headerHeight: 75,
      headerContent: SearchBarWidget(
        hintText: 'Mau makan di mana hari ini?',
        enableGlassmorphism: true,
        margin: const EdgeInsets.only(top: 16),
        controller: controller.searchTextController,
        onChanged: controller.handleSearchInput,
      ),
      slivers: [
        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Filter Chips
              Obx(() => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        _buildFilterChip('Terdekat', controller.selectedFilter == 'nearby'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tipe Tempat', controller.selectedFilter == 'placeValues'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Tipe Kuliner', controller.selectedFilter == 'foodTypes'),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'Penilaian', controller.selectedRating != null),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                            'Harga', controller.selectedPriceRange != null),
                        const SizedBox(width: 16),
                      ],
                    ),
                  )),

              // const SizedBox(height: 16),

              Obx(() => (!controller.isFiltered && controller.showBanner)
                  ?
                  // Promotional Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PromotionalBanner(
                        title: 'Dapatkan lebih banyak!',
                        subtitle: 'Dapatkan hadiah dengan menyelesaikan misi!',
                        imageAsset: Image.asset(AppAssets.images.gift),
                        size: BannerSize.standard,
                        onTap: () => Get.toNamed(AppPages.CHALLENGES),
                        showCloseButton: false,
                        onClose: () => controller.hideBanner(),
                      ),
                  )
                  : const SizedBox.shrink()),

              // Conditional Content based on filter state
              Obx(() {
                return controller.isFiltered
                    ? _buildFilteredContent()
                    : _buildDefaultContent();
              }),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _onFilterChipTapped(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.backgroundContainer,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
              ),
            ),
            if (label == 'Penilaian' || label == 'Harga') ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: isSelected ? AppColors.textOnPrimary : AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onFilterChipTapped(String filter) {
    switch (filter) {
      case 'Terdekat':
        controller.filterByNearby();
        break;
      case 'Penilaian':
        _showRatingDropdown();
        break;
      case 'Harga':
        _showPriceDropdown();
        break;
      case 'Tipe Tempat':
        _showPlaceValueDropdown();
        break;
      case 'Tipe Kuliner':
        _showFoodTypeDropdown();
        break;
    }
  }

  void _showPlaceValueDropdown() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipe Tempat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Place value selection grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: controller.placeValues.length,
              itemBuilder: (context, index) {
                final placeValue = controller.placeValues[index];
                
                return Obx(
                  () {
                    final isSelected =
                        controller.selectedPlaceValues.contains(placeValue);
                    
                    return GestureDetector(
                      onTap: () {
                        controller.togglePlaceValueSelection(placeValue);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(100)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          placeValue,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilter('placeValues');
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
  }

  void _showFoodTypeDropdown() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tipe Kuliner',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Place value selection grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: controller.foodTypes.length,
              itemBuilder: (context, index) {
                final foodType = controller.foodTypes[index];
                
                return Obx(
                  () {
                    final isSelected =
                        controller.selectedFoodTypes.contains(foodType);
                    
                    return GestureDetector(
                      onTap: () {
                        controller.toggleFoodTypeSelection(foodType);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withAlpha(100)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Text(
                          foodType,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppColors.primary : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilter('foodTypes');
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
  }


  void _showRatingDropdown() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Penilaian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final rating = 5 - index;
              return Obx(() => ListTile(
                    leading: Radio<int>(
                      value: rating,
                      groupValue: controller.selectedRating,
                      onChanged: (value) {
                        controller.setSelectedRating(value!);
                      },
                    ),
                    title: Row(
                      children: [
                        Text('$rating'),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 16,
                        ),
                      ],
                    ),
                    onTap: () {
                      controller.setSelectedRating(rating);
                    },
                  ));
            }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.clearRatingFilter();
                      Navigator.pop(context);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyRatingFilter();
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
  }

  void _showPriceDropdown() {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Harga (mulai dari)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => ListTile(
                  leading: Radio<String>(
                    value: 'low',
                    groupValue: controller.selectedPriceRange,
                    onChanged: (value) {
                      controller.setSelectedPriceRange(value!);
                    },
                  ),
                  title: const Text('Rp0 - Rp25.000'),
                  onTap: () {
                    controller.setSelectedPriceRange('low');
                  },
                )),
            Obx(() => ListTile(
                  leading: Radio<String>(
                    value: 'medium',
                    groupValue: controller.selectedPriceRange,
                    onChanged: (value) {
                      controller.setSelectedPriceRange(value!);
                    },
                  ),
                  title: const Text('Rp25.000 - Rp50.000'),
                  onTap: () {
                    controller.setSelectedPriceRange('medium');
                  },
                )),
            Obx(() => ListTile(
                  leading: Radio<String>(
                    value: 'high',
                    groupValue: controller.selectedPriceRange,
                    onChanged: (value) {
                      controller.setSelectedPriceRange(value!);
                    },
                  ),
                  title: const Text('> Rp50.000'),
                  onTap: () {
                    controller.setSelectedPriceRange('high');
                  },
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      controller.clearPriceFilter();
                      Navigator.pop(context);
                    },
                    child: const Text('Hapus'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyPriceFilter();
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
  }

  Widget _buildDefaultContent() {
    return Obx(() {
      Logger.debug('BUILDING PLACES GRID:', 'ExploreView');
      Logger.debug('Controller places length: ${controller.places.length}', 'ExploreView');
      Logger.debug('Controller isLoading: ${controller.isLoading}', 'ExploreView');
      Logger.debug('Controller places isEmpty: ${controller.places.isEmpty}', 'ExploreView');

      if (controller.isLoading && controller.places.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading places...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.places.isEmpty) {
        return Center(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada tempat makan',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba refresh atau cek koneksi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Favorit Kami Section
          Container(
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: AppColors.border,
            //   ),
            // ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Favorit kami!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => controller.applyFilter('partner'),
                        child: Text(
                          'Lihat Selengkapnya',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
                // Places Grid
                _buildPlacesGrid(true),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Terlaris Section
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Teratas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => controller.applyFilter('popular'),
                      child: Text(
                        'Lihat Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              // Places Grid
              _buildPlacesGrid(false),
            ],
          ),
        ],
      );
    });
  }

  String _getFilteredContentTitle() {
    // Show search query if searching
    if (controller.searchQuery.isNotEmpty) {
      return '"${controller.searchQuery}"';
    } else if (controller.selectedFilter == 'favorit') {
      return 'Favorit Kami';
    } else if (controller.selectedFilter == 'terlaris') {
      return 'Terlaris';
    } else if (controller.selectedFilter == 'nearby') {
      return 'Terdekat';
    } else if (controller.selectedFilter == 'placeValues') {
      return 'Tipe Tempat';
    } else if (controller.selectedFilter == 'foodTypes') {
      return 'Tipe Kuliner';
    } else if (controller.selectedRating != null) {
      return 'Rating ${controller.selectedRating}+';
    } else if (controller.selectedPriceRange != null) {
      return 'Harga ${controller.selectedPriceRange}';
    } else {
      return 'Hasil Pencarian';
    }
  }

  Widget _buildFilteredContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Container(
          // decoration: BoxDecoration(
          //     border: Border.all(
          //       color: AppColors.success,
          //       width: 1,
          //     ),
          //   ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Obx(() => Text(
                    _getFilteredContentTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  )),
              const Spacer(),
              Obx(() => Text(
                    '${controller.places.length} tempat',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  )),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.clearFilters(),
                icon: Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
            ],
          ),
        ),

        // Loading indicator while fetching filtered results
        if (controller.isLoading && controller.places.isEmpty)
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Mencari tempat...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        // Searching indicator for local search
        else if (controller.isSearching)
          SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Mencari...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          )
        // Empty state when no results match filters
        else if (controller.places.isEmpty)
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada hasil',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba ubah filter atau kata kunci pencarian',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        // Vertical scrollable list - only show when there are places
        else
          _buildFilteredPlacesList(),
      ],
    );
  }

  Widget _buildFilteredPlacesList() {
    // Show all places in vertical scrollable list
    final displayPlaces = controller.places;

    Logger.debug('_buildFilteredPlacesList called', 'ExploreView');
    Logger.debug('displayPlaces.length: ${displayPlaces.length}', 'ExploreView');
    Logger.debug('controller.isLoading: ${controller.isLoading}', 'ExploreView');
    Logger.debug('controller.places.isEmpty: ${controller.places.isEmpty}', 'ExploreView');

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: AppColors.accent,
      //     width: 1,
      //   ),
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: displayPlaces.length,
        itemBuilder: (context, index) {
          Logger.debug('Building place card for index: $index', 'ExploreView');
          return PlaceCardWidget(
            place: displayPlaces[index],
            cardSize: CardSize.fullWidth,
          );
        },
      ),
    );
  }

  Widget _buildPlacesGrid(bool isPartnership) {
    // Show maximum 4 places in horizontal scrollable list
    final displayPlaces = controller.places
        .where((p) => (p.partnershipStatus ?? false) == isPartnership)
        .take(4)
        .toList();

    Logger.debug('displayPlaces for isPartnership=$isPartnership: $displayPlaces', 'ExploreView');

    return Container(
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: AppColors.accent,
      //     width: 1,
      //   ),
      // ),
      height: 240, // Set height constraint for horizontal ListView
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayPlaces.length,
        itemBuilder: (context, index) {
          return PlaceCardWidget(
            place: displayPlaces[index],
            cardSize: CardSize.large,
          );
        },
      ),
    );
  }
}
