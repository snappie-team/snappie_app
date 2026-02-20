import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../controllers/profile_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/place_repository_impl.dart';
import '../../../routes/app_pages.dart';
import '../../shared/widgets/index.dart';

/// Full page view for all saved places
class SavedPlacesView extends GetView<ProfileController> {
  const SavedPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Tempat Tersimpan',
      onRefresh: () => controller.loadSavedItems(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: Obx(() {
            if (controller.isLoadingSaved) {
              return const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.savedPlaces.isEmpty) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada tempat tersimpan', // TODO: use local keys
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }

            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = controller.savedPlaces[index];
                  return _buildPlaceCard(place);
                },
                childCount: controller.savedPlaces.length,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlaceCard(SavedPlacePreview place) {
    return GestureDetector(
      onTap: () => _navigateToPlaceDetail(place.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              NetworkImageWidget(
                imageUrl: place.imageUrl ?? '',
                fit: BoxFit.cover,
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),

              // Content at bottom
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Place name with rating
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            place.name ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          (place.rating ?? 0).toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Short description
                    if (place.shortDescription != null &&
                        place.shortDescription!.isNotEmpty)
                      Text(
                        place.shortDescription!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToPlaceDetail(int? placeId) async {
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
