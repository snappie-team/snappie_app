import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/modules/shared/layout/views/detail_layout.dart';
import '../../../core/services/logger_service.dart';
import '../controllers/explore_controller.dart';
import '../../../data/models/place_model.dart';
import '../../shared/widgets/index.dart';

class PlaceView extends GetView<ExploreController> {
  const PlaceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get place from arguments - can be either PlaceModel or int (ID)
    PlaceModel? place;
    final arguments = Get.arguments;
    
    if (arguments is PlaceModel) {
      // Direct PlaceModel passed
      place = arguments;
    } else if (arguments is int) {
      // Place ID passed - need to load place data
      // For now, we'll handle this in the controller
      place = null;
    }
    
    controller.selectPlace(place);

    // Load place when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (arguments is int) {
        // Load place by ID
        Logger.debug('Loading place with ID: $arguments', 'PlaceView');
        controller.loadPlaceById(arguments);
      } else if (place != null) {
        Logger.debug('Place is ${place.id}', 'PlaceView');
        controller.selectPlace(place);
        controller.loadPlaceReviews(place.id!);
      }
    });

    return Obx(() {
      // Get the current selected place from controller
      final currentPlace = controller.selectedPlace ?? place;
      
      return DetailLayout(
        title: currentPlace?.name ?? '',
        actions: [
          ButtonWidget(
            icon: AppIcon(AppAssets.icons.saveInactive, size: 24),
            backgroundColor: AppColors.background,
            onPressed: () => {},
          ),
          const SizedBox(width: 8),
          ButtonWidget(
            icon: AppIcon(AppAssets.icons.share, size: 24),
            backgroundColor: AppColors.background,
            onPressed: () => {},
          ),
          const SizedBox(width: 8),
        ],
        body: controller.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : controller.errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${controller.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (arguments is int) {
                          controller.loadPlaceById(arguments);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSection(context, currentPlace),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          _buildPlaceInfo(currentPlace),
                          const SizedBox(height: 16),
                          _buildPlaceReviews(currentPlace),
                        ],
                      ),
                    ),
                  ],
                ),
              )
      );
    });
  }

  Widget _buildPlaceInfo(PlaceModel? place) {
    Logger.debug('Place Value: ${place?.placeValue}', 'PlaceView');
    Logger.debug('Food Type: ${place?.foodType}', 'PlaceView');
    return Column(
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place?.name ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  place?.description ?? '',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  '${place?.minPrice} - ${place?.maxPrice}',
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final avgRating = place?.avgRating ?? 0.0;
                    return Icon(
                      index < avgRating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                      size: 20,
                    );
                  }),
                ),
                Text('${place?.avgRating} (${place?.totalReview} Ulasan)', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cocok Untuk',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFixedGrid(place?.placeValue, true),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipe Kuliner',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildFixedGrid(place?.foodType, false),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alamat
                _buildDetailRow(
                  icon: Icons.location_on,
                  title: 'Alamat:',
                  content: place?.placeDetail?.address ?? 'Alamat tidak tersedia',
                  subtitle: 'Lihat di peta',
                  subtitleColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                
                // Jam Buka
                _buildDetailRow(
                  icon: Icons.access_time,
                  title: 'Jam Buka:',
                  content: _getOperatingStatus(place),
                  subtitle: _getOperatingHours(place),
                  subtitleColor: _getOperatingStatus(place) == 'Buka Sekarang' 
                      ? Colors.green 
                      : Colors.red,
                ),
                const SizedBox(height: 16),
                
                // Reservasi
                _buildDetailRow(
                  icon: Icons.phone,
                  title: 'Reservasi:',
                  content: '',
                  customWidget: _buildWhatsAppButton(place?.placeDetail?.contactNumber),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorit Kami!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildMenuList(place),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: RectangleButtonWidget(
                    text: 'Lihat Menu Lengkap',
                    backgroundColor: Colors.cyan,
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to full menu page
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fasilitas',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to full facilities page
                      },
                      child: Text(
                        'Lihat Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFacilitiesGrid(place),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPlaceReviews(PlaceModel? place) {
    return Column(
      children: [
        // Galeri Bersama Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Galeri Bersama',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to full gallery page
                      },
                      child: Text(
                        'Lihat Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGalleryGrid(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Ulasan Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ulasan',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to full reviews page
                      },
                      child: Text(
                        'Lihat Selengkapnya',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildReviewsList(),
              ],
            ),
          ),
        ),
         const SizedBox(height: 16),
         // Tempat Serupa Lainnya Card
         Card(
           elevation: 2,
           child: Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   'Tempat Serupa Lainnya',
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                 ),
                 const SizedBox(height: 16),
                 _buildRecommendationsList(),
               ],
             ),
           ),
         ),
       ],
     );
   }

  Widget _buildImageSection(BuildContext context, PlaceModel? place) {
    double imageHeight = 300;
    // final imageUrls = ['https://static.promediateknologi.id/crop/0x0:0x0/0x0/webp/photo/p2/146/2024/04/30/Sagarmatha-3522761961.jpeg', 'https://sitimustiani.com/wp-content/uploads/2023/10/Kedai-Kopi-Lao-Kopitiam-Pontianak-1170x878.jpg',];
    final imageUrls = place?.imageUrls ?? [];
    Logger.debug('imageUrls: $imageUrls', 'PlaceView');
    
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
    //     ),
    //   ),
    // );
  }

  Widget _buildFixedGrid(List<String>? items, bool isPlaceValue) {
    // Jika tidak ada data, tampilkan pesan
    if (items == null || items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Belum ada informasi',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Siapkan item berdasarkan data yang ada
    List<Widget> gridItems = [];
    
    for (int i = 0; i < items.length; i++) {
      if (isPlaceValue) {
        gridItems.add(_buildPlaceValueChip(items[i], i));
      } else {
        gridItems.add(_buildFoodTypeChip(items[i], i));
      }
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: gridItems,
    );
  }

  Widget _buildRecommendationsList() {
    // Mock data untuk rekomendasi tempat - dalam implementasi nyata akan dari API
    final recommendations = [
      {
        'name': '2818 Coffee Roasters',
        'description': 'Kopi dalam Harmoni',
        'rating': 5.0,
        'image': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=200&h=200&fit=crop',
      },
      {
        'name': 'Ningrat Eatery',
        'description': 'Resep Tradisional Nusantara Sejak Dulu',
        'rating': 4.8,
        'image': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&h=200&fit=crop',
      },
    ];

    return Column(
      children: recommendations.map((place) => _buildRecommendationItem(place)).toList(),
    );
  }

  Widget _buildRecommendationItem(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Place Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 80,
              height: 80,
              child: Image.network(
                place['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[600],
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Place Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.yellow[700],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      place['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryGrid() {
    // Mock data untuk galeri - dalam implementasi nyata akan dari API
    final galleryImages = [
      'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1559329007-40df8a9345d8?w=200&h=200&fit=crop',
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200&h=200&fit=crop',
    ];

    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(right: index < galleryImages.length - 1 ? 8 : 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 100,
                child: Image.network(
                  galleryImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.image,
                        color: Colors.grey[600],
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsList() {
    // Mock data untuk reviews - dalam implementasi nyata akan dari controller.reviews
    final reviews = [
      {
        'name': 'm.tafif',
        'date': '19-07-2025',
        'rating': 4,
        'comment': 'Tempatnya bagus, cocok untuk WFC, cemilan dan minumannya juga enak-enak',
        'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=50&h=50&fit=crop',
      },
      {
        'name': 'Tafif',
        'date': '19-07-2025',
        'rating': 4,
        'comment': 'Kentangnya enak, terutama sausnya dengan campuran mayonaise beuh khas bat rasanya',
        'avatar': 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=50&h=50&fit=crop',
      },
      {
        'name': 'Siapa',
        'date': '19-07-2025',
        'rating': 4,
        'comment': 'okelah untuk nyantai, ada kolam, buku, dan interior unik lainnya. Tempatnya tersembunyi didalam gang',
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=50&h=50&fit=crop',
      },
    ];

    return Column(
      children: reviews.map((review) => _buildReviewItem(review)).toList(),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 50,
              height: 50,
              child: Image.network(
                review['avatar'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: Colors.grey[600],
                      size: 30,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Review Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      review['date'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Rating Stars
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review['rating'] ? Icons.star : Icons.star_border,
                      color: Colors.yellow[700],
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  review['comment'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesGrid(PlaceModel? place) {
    // Mock data untuk fasilitas - dalam implementasi nyata akan dari place.placeAttributes
    final facilities = [
      'Wi-Fi Cepat',
      'Area Parkir',
      'Banyak Colokan',
      'Toilet Bersih',
      'Indoor & Outdoor',
      'Meja & Kursi Ergonomis',
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.8,
      children: facilities.take(6).map((facility) {
        final index = facilities.indexOf(facility);
        return _buildFacilityChip(facility.toString(), index);
      }).toList(),
    );
  }

  Widget _buildFacilityChip(String facility, int index) {
    // Background colors sesuai gambar
    List<Color> backgroundColors = [
      Colors.blue[100]!,      // Wi-Fi Cepat
      Colors.green[100]!,     // Area Parkir
      Colors.red[100]!,       // Banyak Colokan
      Colors.yellow[100]!,    // Toilet Bersih
      Colors.purple[100]!,    // Indoor & Outdoor
      Colors.orange[100]!,    // Meja & Kursi Ergonomis
    ];

    List<Color> textColors = [
      Colors.blue[700]!,      // Wi-Fi Cepat
      Colors.green[700]!,     // Area Parkir
      Colors.red[700]!,       // Banyak Colokan
      Colors.orange[700]!,    // Toilet Bersih (orange text for yellow bg)
      Colors.purple[700]!,    // Indoor & Outdoor
      Colors.orange[700]!,    // Meja & Kursi Ergonomis
    ];

    final backgroundColor = backgroundColors[index % backgroundColors.length];
    final textColor = textColors[index % textColors.length];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          facility,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildMenuList(PlaceModel? place) {
    // Mock data untuk menu favorit - dalam implementasi nyata akan dari place.menu
    final favoriteMenus = [
      {
        'name': 'Mie Rimpang',
        'description': 'Perpaduan mie dengan ekstrak rimpang alami, disajikan hangat.',
        'price': 'Rp25.000,-',
        'image': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=100&h=100&fit=crop',
      },
      {
        'name': 'Mauna Kea',
        'description': 'Dari ekstrak buah bit yang kaya, dipadukan dengan susu segar dan p...',
        'price': 'Rp25.000,-',
        'image': 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=100&h=100&fit=crop',
      },
    ];

    // Jika ada data menu dari place, gunakan itu
    final menuItems = place?.menu ?? favoriteMenus;

    return Column(
      children: menuItems.take(2).map((menu) => _buildMenuItem(menu)).toList(),
    );
  }

  Widget _buildMenuItem(dynamic menu) {
    String name = '';
    String description = '';
    String price = '';
    String imageUrl = '';

    // Handle both Map (mock data) and MenuItem model
    if (menu is Map<String, dynamic>) {
      name = menu['name'] ?? '';
      description = menu['description'] ?? '';
      price = menu['price'] ?? '';
      imageUrl = menu['image'] ?? '';
    } else {
      // Handle MenuItem model if available
      name = menu.name ?? '';
      description = menu.description ?? '';
      price = 'Rp${menu.price ?? 0},-';
      imageUrl = menu.imageUrl ?? '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              color: Colors.grey[300],
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.grey[600],
                            size: 30,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.restaurant,
                      color: Colors.grey[600],
                      size: 30,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Menu Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
    Color? subtitleColor,
    Widget? customWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              if (customWidget != null)
                customWidget
              else ...[
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor ?? Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getOperatingStatus(PlaceModel? place) {
    // Untuk demo, kita return status statis
    // Dalam implementasi nyata, ini akan mengecek jam saat ini vs jam operasional
    return 'Buka Sekarang';
  }

  String _getOperatingHours(PlaceModel? place) {
    final openingHours = place?.placeDetail?.openingHours ?? '09:00';
    final closingHours = place?.placeDetail?.closingHours ?? '18:00';
    return 'Senin - Minggu: $openingHours - $closingHours WIB';
  }

  Widget _buildWhatsAppButton(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return Text(
        'Tidak tersedia',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: Implement WhatsApp launch
            Logger.debug('Opening WhatsApp for: $phoneNumber', 'PlaceView');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                const Text(
                  'WhatsApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceValueChip(String value, int index) {
    IconData icon;
    Color textColor = Colors.white;

    // Background color berdasarkan indeks dengan pola berulang
    List<Color> colorPattern = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.pink,
    ];
    // backgroundColor = colorPattern[index % colorPattern.length];
    textColor = colorPattern[index % colorPattern.length];

    // Mapping berdasarkan value dengan ikon yang sesuai
    switch (value.toLowerCase()) {
      case 'wfc':
      case 'work from cafe':
        icon = Icons.laptop_mac;
        break;
      case 'nongkrong':
      case 'diskusi':
      case 'nongkrong/diskusi':
        icon = Icons.chat_bubble_outline;
        break;
      case 'keluarga':
      case 'pasangan':
      case 'keluarga/pasangan':
        icon = Icons.favorite;
        break;
      case 'me time':
        icon = Icons.sentiment_satisfied;
        break;
      case 'suasana tradisional':
        icon = Icons.temple_buddhist;
        break;
      case 'pelayanan ramah':
        icon = Icons.sentiment_very_satisfied;
        break;
      case 'pet friendly':
        icon = Icons.pets;
        break;
      default:
        icon = Icons.place;
    }

    return Container(
      decoration: BoxDecoration(
        color: textColor.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTypeChip(String type, int index) {
    Color textColor = Colors.white;

    // Background color berdasarkan indeks dengan pola berulang
    List<Color> colorPattern = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.yellow,
      Colors.purple,
      Colors.pink,
    ];
    textColor = colorPattern[index % colorPattern.length];

    return Container(
      decoration: BoxDecoration(
        color: textColor.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          type,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}