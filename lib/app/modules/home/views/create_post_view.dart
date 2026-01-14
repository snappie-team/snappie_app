import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/constants/font_size.dart';
import 'package:snappie_app/app/core/services/cloudinary_service.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/core/helpers/error_handler.dart';
import 'package:snappie_app/app/data/models/place_model.dart';
import 'package:snappie_app/app/data/models/user_model.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/post_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';
import 'package:snappie_app/app/modules/home/controllers/home_controller.dart';
import 'package:snappie_app/app/modules/shared/layout/controllers/main_controller.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import 'package:snappie_app/app/modules/shared/widgets/index.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

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
  bool _hasForcedPlaceSelection = false;

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
      Logger.debug('CloudinaryService found and initialized', 'CreatePostView');
    } catch (e) {
      Logger.error('CloudinaryService not found', e, null, 'CreatePostView');
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

    // Add listener to text controller to update button state
    _contentController.addListener(() {
      setState(() {});
    });

    _loadData();
    // _loadPlaces();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _contentController.text.trim().isNotEmpty &&
        _imageFiles.isNotEmpty &&
        _selectedPlace != null;
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
      if (!_hasForcedPlaceSelection && mounted) {
        _hasForcedPlaceSelection = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _selectedPlace != null) return;
          if (_places.isEmpty) {
            Get.snackbar(
              'Error',
              'Tidak ada tempat tersedia',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.error,
              colorText: AppColors.textOnPrimary,
            );
            return;
          }
          _showPlaceSelection(force: true);
        });
      }
    } catch (e) {
      Logger.error('Error loading user data', e, null, 'CreatePostView');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayWidget(
      isLoading: _isLoading,
      child: ScaffoldFrame.detail(
        title: 'Buat Postingan',
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
                                      hintStyle: TextStyle(
                                          color: AppColors.textSecondary),
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
                                        _imageFiles
                                            .removeAt(_currentImageIndex);
                                        if (_currentImageIndex >=
                                                _imageFiles.length &&
                                            _currentImageIndex > 0) {
                                          _currentImageIndex--;
                                          _pageController
                                              .jumpToPage(_currentImageIndex);
                                        }
                                      });
                                    },
                                    icon: AppIcon(
                                      AppAssets.icons.close,
                                      color: AppColors.textOnPrimary,
                                    ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                              ),
                              label: Text(
                                _selectedPlace!.name ?? 'Unknown',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              deleteIcon: AppIcon(
                                AppAssets.icons.close,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundContainer,
                    // border: Border(
                    //   top: BorderSide(color: AppColors.borderLight, width: 1),
                    // ),
                  ),
                  child: Column(
                    children: [
                      // Foto/Video option
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundContainer,
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: AppIcon(
                            AppAssets.icons.video,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            'Foto/Video',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          trailing: AppIcon(
                            AppAssets.icons.moreOption3,
                            color: AppColors.textSecondary,
                          ),
                          onTap: _pickImage,
                        ),
                      ),
                      // Lokasi option
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundContainer,
                          border: Border.all(color: AppColors.borderLight),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowDark,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: AppIcon(
                            AppAssets.icons.location,
                            color: AppColors.error,
                          ),
                          title: Text(
                            'Lokasi',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          trailing: AppIcon(
                            AppAssets.icons.moreOption3,
                            color: AppColors.textSecondary,
                          ),
                          onTap: _showPlaceSelection,
                        ),
                      ),
                      // Tombol Unggah
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_isFormValid)
                                ? null
                                : _submitPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                              ),
                              disabledBackgroundColor:
                                  AppColors.textSecondary.withOpacity(0.3),
                              disabledForegroundColor: AppColors.textSecondary,
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
                                    'Unggah',
                                    style: TextStyle(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showPlaceSelection({bool force = false}) {
    final searchController = TextEditingController();
    String query = '';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          final normalizedQuery = query.trim().toLowerCase();
          final filteredPlaces = normalizedQuery.isEmpty
              ? _places
              : _places.where((place) {
                  final name = (place.name ?? '').toLowerCase();
                  final address = (place.placeDetail?.address ?? '').toLowerCase();
                  return name.contains(normalizedQuery) ||
                      address.contains(normalizedQuery);
                }).toList();

          return PopScope(
            canPop: true,
            child: Container(
              height: Get.height * 0.9,
              decoration: BoxDecoration(
                color: AppColors.backgroundContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // decoration: BoxDecoration(
                    //   border: Border(
                    //     bottom: BorderSide(color: AppColors.borderLight),
                    //   ),
                    // ),
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
                          onPressed: () {
                            if (force) {
                              _exitCreatePostToHome();
                              return;
                            }
                            Get.back();
                          },
                          icon: AppIcon(
                            AppAssets.icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setModalState(() => query = value),
                      decoration: InputDecoration(
                        hintText: 'Cari tempat...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(99),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isLoadingPlaces
                        ? const Center(child: CircularProgressIndicator())
                        : filteredPlaces.isEmpty
                            ? Center(
                                child: Text(
                                  normalizedQuery.isEmpty
                                      ? 'Tidak ada tempat tersedia'
                                      : 'Tempat tidak ditemukan',
                                  style: TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredPlaces.length,
                                itemBuilder: (context, index) {
                                  final place = filteredPlaces[index];
                                  return ListTile(
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
          );
        },
      ),
      isScrollControlled: true,
      isDismissible: !force,
      enableDrag: !force,
    ).whenComplete(searchController.dispose);
  }

  void _exitCreatePostToHome() {
    if (Get.isBottomSheetOpen == true) {
      Get.back();
    }

    Get.offAllNamed(AppPages.MAIN);

    Future.delayed(Duration.zero, () {
      try {
        Get.find<MainController>().changeTab(0);
      } catch (_) {}
    });
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
        'Gagal',
        ErrorHandler.getReadableMessage(e, tag: 'CreatePostView'),
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
        Logger.debug('Starting upload of ${_imageFiles.length} images...',
            'CreatePostView');

        for (int i = 0; i < _imageFiles.length; i++) {
          final file = _imageFiles[i];
          Logger.debug('Uploading image ${i + 1}/${_imageFiles.length}...',
              'CreatePostView');
          Logger.debug('File path: ${file.path}', 'CreatePostView');
          Logger.debug('File exists: ${await file.exists()}', 'CreatePostView');
          Logger.debug(
              'File size: ${await file.length()} bytes', 'CreatePostView');

          try {
            final result = await _cloudinaryService.uploadPostImage(file);

            if (result.success && result.secureUrl != null) {
              imageUrls.add(result.secureUrl!);
              Logger.debug(
                  'Image ${i + 1} uploaded successfully: ${result.secureUrl}',
                  'CreatePostView');
            } else {
              Logger.warning(
                  'Upload failed for image ${i + 1}: ${result.error}',
                  'CreatePostView');
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
            Logger.error('Exception uploading image ${i + 1}', uploadError,
                null, 'CreatePostView');
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

        Logger.debug(
            'Upload complete. Successfully uploaded ${imageUrls.length}/${_imageFiles.length} images',
            'CreatePostView');

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

      Logger.debug('Creating post with ${imageUrls.length} image URLs...',
          'CreatePostView');
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
      Logger.error('Failed to create post', e, null, 'CreatePostView');
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuat postingan, silakan coba lagi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
