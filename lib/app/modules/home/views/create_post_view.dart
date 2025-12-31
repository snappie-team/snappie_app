import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/services/cloudinary_service.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/data/models/user_model.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';
import 'package:snappie_app/app/modules/home/controllers/home_controller.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _contentController = TextEditingController();
  PlaceModel? _selectedPlace;
  final List<File> _imageFiles = [];
  final List<String> _hashtags = [];
  String _locationDetails = '';
  bool _isLoading = false;
  final _picker = ImagePicker();
  final _pageController = PageController();
  int _currentImageIndex = 0;
  static const int _maxImages = 5;
  bool _showDetailedActions = false;

  UserModel? _userData;
  List<PlaceModel> _places = [];
  bool _isLoadingPlaces = false;

  late final PostRepository _postRepository;
  late final PlaceRepository _placeRepository;
  late final UserRepository _userRepository;
  late final CloudinaryService _cloudinaryService;

  @override
  void initState() {
    super.initState();
    _postRepository = Get.find<PostRepository>();
    _placeRepository = Get.find<PlaceRepository>();
    _userRepository = Get.find<UserRepository>();
    try {
      _cloudinaryService = Get.find<CloudinaryService>();
      print('[CreatePostView] CloudinaryService found and initialized');
    } catch (e) {
      print('[CreatePostView] ERROR: CloudinaryService not found: $e');
      // Show error to user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          'CloudinaryService tidak tersedia. Restart aplikasi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.textOnPrimary,
        );
      });
    }

    _loadData();
    // _loadPlaces();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _userRepository.getUserProfile();
      final placeData = await _placeRepository.getPlaces();
      setState(() {
        _userData = userData;
        _places = placeData;
      });
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Buat Postingan',
      actions: [
        ElevatedButton(
          onPressed: _isLoading ? null : _submitPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Posting',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
        const SizedBox(width: 16),
      ],
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundContainer,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info and content
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar
                          AvatarWidget(
                            imageUrl: _userData?.imageUrl ?? '',
                            size: AvatarSize.medium,
                          ),
                          const SizedBox(width: 12),
                          // Content input
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: 'Apa yang kamu ingin bagikan?',
                                hintStyle:
                                    TextStyle(color: AppColors.textSecondary),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image carousel
                    if (_imageFiles.isNotEmpty)
                      Container(
                        width: double.infinity,
                        height: 400,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.background,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemCount: _imageFiles.length,
                              itemBuilder: (context, index) {
                                return Image.file(
                                  _imageFiles[index],
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                            // Image counter
                            if (_imageFiles.length > 1)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_currentImageIndex + 1}/${_imageFiles.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            // Delete button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _imageFiles.removeAt(_currentImageIndex);
                                    if (_currentImageIndex >=
                                            _imageFiles.length &&
                                        _currentImageIndex > 0) {
                                      _currentImageIndex--;
                                      _pageController
                                          .jumpToPage(_currentImageIndex);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.close),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Selected place chip
                    if (_selectedPlace != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Chip(
                          avatar: Icon(
                            Icons.place,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          label: Text(
                            _selectedPlace!.name ?? 'Unknown',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          onDeleted: () =>
                              setState(() => _selectedPlace = null),
                          backgroundColor: AppColors.backgroundContainer,
                          side: BorderSide(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                      ),

                    const SizedBox(height: 80), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ),

          // Bottom action bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                if (!_showDetailedActions) ...[
                  IconButton(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image, color: AppColors.primary),
                    tooltip: 'Tambah Foto',
                  ),
                  IconButton(
                    onPressed: _showPlaceSelection,
                    icon: Icon(Icons.place, color: AppColors.error),
                    tooltip: 'Pilih Tempat',
                  ),
                ] else ...[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Column(
                          children: [
                            Icon(Icons.image, color: AppColors.primary),
                            const SizedBox(height: 4),
                            Text(
                              'Foto/Video',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.error),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: _showPlaceSelection,
                        child: Column(
                          children: [
                            Icon(Icons.place, color: AppColors.error),
                            const SizedBox(height: 4),
                            Text(
                              'Lokasi',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showDetailedActions = !_showDetailedActions;
                    });
                  },
                    icon: Icon(
                    _showDetailedActions
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                    color: AppColors.textSecondary,
                    ),
                ),
              ],
            ),
          ),
        ],
      ),)
      ],
    );
  }

  void _showPlaceSelection() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih Tempat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingPlaces
                  ? const Center(child: CircularProgressIndicator())
                  : _places.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada tempat tersedia',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _places.length,
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return ListTile(
                              leading: place.imageUrls?.isNotEmpty == true
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        place.imageUrls!.first,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color:
                                                AppColors.backgroundContainer,
                                            child: Icon(
                                              Icons.restaurant,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.restaurant,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                              title: Text(
                                place.name ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                place.placeDetail?.address ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                setState(() => _selectedPlace = place);
                                Get.back();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickImage() async {
    try {
      // Check if already at max limit
      if (_imageFiles.length >= _maxImages) {
        Get.snackbar(
          'Batas Maksimal',
          'Maksimal $_maxImages gambar',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning,
          colorText: AppColors.textOnPrimary,
        );
        return;
      }

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Add files up to the max limit
          final remainingSlots = _maxImages - _imageFiles.length;
          final filesToAdd = pickedFiles.take(remainingSlots);

          for (var file in filesToAdd) {
            _imageFiles.add(File(file.path));
          }

          // Show warning if some images were not added
          if (pickedFiles.length > remainingSlots) {
            Get.snackbar(
              'Info',
              'Hanya $remainingSlots gambar yang ditambahkan (maksimal $_maxImages)',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primary,
              colorText: AppColors.textOnPrimary,
            );
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    }
  }

  Future<void> _submitPost() async {
    // Validation
    if (_selectedPlace == null) {
      Get.snackbar(
        'Error',
        'Pilih tempat terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Konten tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Upload images to Cloudinary if any
      List<String> imageUrls = [];
      if (_imageFiles.isNotEmpty) {
        print(
            '[CreatePostView] Starting upload of ${_imageFiles.length} images...');

        for (int i = 0; i < _imageFiles.length; i++) {
          final file = _imageFiles[i];
          print(
              '[CreatePostView] Uploading image ${i + 1}/${_imageFiles.length}...');
          print('[CreatePostView] File path: ${file.path}');
          print('[CreatePostView] File exists: ${await file.exists()}');
          print('[CreatePostView] File size: ${await file.length()} bytes');

          try {
            final result = await _cloudinaryService.uploadPostImage(file);

            if (result.success && result.secureUrl != null) {
              imageUrls.add(result.secureUrl!);
              print(
                  '[CreatePostView] Image ${i + 1} uploaded successfully: ${result.secureUrl}');
            } else {
              print(
                  '[CreatePostView] Upload failed for image ${i + 1}: ${result.error}');
              // Show error to user
              Get.snackbar(
                'Warning',
                'Gagal upload gambar ${i + 1}: ${result.error}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.warning,
                colorText: AppColors.textOnPrimary,
                duration: const Duration(seconds: 2),
              );
            }
          } catch (uploadError) {
            print(
                '[CreatePostView] Exception uploading image ${i + 1}: $uploadError');
            Get.snackbar(
              'Warning',
              'Error upload gambar ${i + 1}: $uploadError',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.warning,
              colorText: AppColors.textOnPrimary,
              duration: const Duration(seconds: 2),
            );
          }
        }

        print(
            '[CreatePostView] Upload complete. Successfully uploaded ${imageUrls.length}/${_imageFiles.length} images');

        if (imageUrls.isEmpty && _imageFiles.isNotEmpty) {
          Get.snackbar(
            'Error',
            'Semua gambar gagal diupload. Coba lagi.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: AppColors.textOnPrimary,
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      print(
          '[CreatePostView] Creating post with ${imageUrls.length} image URLs...');
      await _postRepository.createPost(
        placeId: _selectedPlace!.id!,
        content: _contentController.text.trim(),
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        hashtags: _hashtags.isNotEmpty ? _hashtags : null,
        locationDetails: _locationDetails.isNotEmpty ? _locationDetails : null,
      );

      // Refresh home feed
      final homeController = Get.find<HomeController>();
      await homeController.refreshData();

      Get.back(); // Close create post view

      Get.snackbar(
        'Berhasil',
        'Postingan berhasil dibuat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textOnPrimary,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuat postingan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
