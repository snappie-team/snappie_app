import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/place_model.dart';
import '../../shared/widgets/index.dart';
import '../controllers/explore_controller.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  final controller = Get.find<ExploreController>();
  PlaceModel? place;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    place = Get.arguments as PlaceModel?;
    
    // Load gallery data when view initializes
    if (place?.id != null) {
      controller.loadGalleryCheckins(place!.id!);
      controller.loadGalleryPosts(place!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (place == null) {
      return Scaffold(
        body: const Center(
          child: Text('Data tidak ditemukan'),
        ),
      );
    }

    return ScaffoldFrame.detail(
      title: 'Galeri Bersama',
      onRefresh: () async {
        if (place?.id != null) {
          await controller.loadGalleryCheckins(place!.id!);
          await controller.loadGalleryPosts(place!.id!);
        }
      },
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildTabBar(),
            ],
          ),
        ),
        SliverFillRemaining(
          child: _buildSelectedTab(),
        ),
      ],
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGaleriKamiTab();
      case 1:
        return _buildGaleriMisiTab();
      case 2:
        return _buildPostinganTerkaitTab();
      default:
        return _buildGaleriKamiTab();
    }
  }

  Widget _buildTabBar() {
    final tabs = ['Galeri Kami', 'Galeri Misi', 'Postingan Terkait'];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundContainer
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: AppColors.background
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Tab 1: Galeri Kami - from place.imageUrls
  Widget _buildGaleriKamiTab() {
    final photos = place?.imageUrls ?? [];
    
    if (photos.isEmpty) {
      return _buildEmptyState('Belum ada foto dari tempat ini');
    }

    return _buildPhotoGrid(
      photos: photos,
      showLabel: true,
    );
  }

  /// Tab 2: Galeri Misi - from checkin.imageUrl
  Widget _buildGaleriMisiTab() {
    return Obx(() {
      if (controller.isLoadingGalleryCheckins) {
        return const Center(child: CircularProgressIndicator());
      }

      final photos = controller.galleryCheckinImages;
      
      if (photos.isEmpty) {
        return _buildEmptyState('Belum ada foto misi dari pengunjung');
      }

      return _buildPhotoGrid(photos: photos);
    });
  }

  /// Tab 3: Postingan Terkait - from posts related to this place
  Widget _buildPostinganTerkaitTab() {
    return Obx(() {
      if (controller.isLoadingGalleryPosts) {
        return const Center(child: CircularProgressIndicator());
      }

      final posts = controller.galleryPosts;
      
      if (posts.isEmpty) {
        return _buildEmptyState('Belum ada postingan terkait');
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostCard(post: posts[index]);
        },
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid({
    required List<String> photos,
    bool showLabel = false,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoTile(
          context: context,
          photos: photos,
          index: index,
          showLabel: showLabel,
        );
      },
    );
  }

  Widget _buildPhotoTile({
    required BuildContext context,
    required List<String> photos,
    required int index,
    bool showLabel = false,
  }) {
    return GestureDetector(
      onTap: () {
        FullscreenImageViewer.show(
          context: context,
          imageUrls: photos,
          initialIndex: index,
          isCarousel: true
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            NetworkImageWidget(
              imageUrl: photos[index],
              fit: BoxFit.cover,
            ),
            if (showLabel)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    _getLabelForIndex(index),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // TODO: Add label for each images in database
  String _getLabelForIndex(int index) {
    // Generate label based on place info if available
    final placeAttributes = place?.placeAttributes;
    if (placeAttributes != null) {
      // Try to get area names from place attributes
      final capacityList = placeAttributes.capacity;
      if (capacityList != null && index < capacityList.length) {
        return capacityList[index].name ?? 'Area ${index + 1}';
      }
    }
    
    // Default labels based on common areas
    final defaultLabels = [
      'Area Indoor',
      'Area Indoor',
      'Area Outdoor 1',
      'Area Outdoor 2',
      'Area Outdoor 3',
      'Mushola',
      'Area Parkir',
      'Toilet',
    ];
    
    if (index < defaultLabels.length) {
      return defaultLabels[index];
    }
    return 'Foto ${index + 1}';
  }
}
