import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/food_type.dart';
import '../../../core/constants/place_value.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/place_model.dart';
import '../controllers/explore_controller.dart';

/// Halaman untuk menulis ulasan dari reviews_view
class GiveReviewView extends StatefulWidget {
  const GiveReviewView({super.key});

  @override
  State<GiveReviewView> createState() => _GiveReviewViewState();
}

class _GiveReviewViewState extends State<GiveReviewView> {
  final ExploreController controller = Get.find<ExploreController>();
  final TextEditingController _reviewController = TextEditingController();
  
  // Local state
  int _rating = 0;
  final List<FoodType> _selectedFoodTypes = [];
  final List<PlaceValue> _selectedPlaceValues = [];
  bool _hideUsername = false;
  bool _isSubmitting = false;
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxImages = 5;
  
  PlaceModel? place;

  @override
  void initState() {
    super.initState();
    place = Get.arguments as PlaceModel?;
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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
      title: 'Tulis Ulasan',
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Green banner with reward info
                      _buildRewardBanner(),
              
                      // Place info card
                      Container(
                        margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowDark.withAlpha(20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPlaceInfoCard(),
                                  
                        // Rating section
                        _buildRatingSection(),
                                  
                        // Photo/Video section
                        _buildPhotoVideoSection(),
                                  
                        // Food catalog section
                        _buildFoodCatalogSection(),
                                  
                        // Place value section
                        _buildPlaceValueSection(),
                                  
                        // Review text section
                        _buildReviewTextSection(),
                                  
                        // Hide username checkbox
                        _buildHideUsernameSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Submit button
          _buildSubmitButton(),
        ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.accent.withAlpha(30),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
          children: [
            const TextSpan(text: 'Tuliskan ulasanmu untuk mendapatkan '),
            TextSpan(
              text: '${place?.expReward ?? 50} XP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const TextSpan(text: ' dan '),
            TextSpan(
              text: '${place?.coinReward ?? 25} Koin',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const TextSpan(text: '! Dapatkan hadiah lebih banyak dengan menambahkan foto dan video'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Place image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: place?.imageUrls != null && place!.imageUrls!.isNotEmpty
                ? Image.network(
                    place!.imageUrls!.first,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 12),
          // Place details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place?.name ?? 'Nama Tempat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place?.placeDetail?.address ?? 'Alamat tempat',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: AppColors.surfaceContainer,
      child: Icon(
        Icons.image,
        color: AppColors.textTertiary,
        size: 32,
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penilaian',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating
                          ? AppColors.warning
                          : AppColors.textTertiary,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoVideoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tambahkan foto dan video (maks $_maxImages)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '+10 Koin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Selected images preview
          if (_selectedImages.isNotEmpty) ...[
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + (_selectedImages.length < _maxImages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    // Add more button
                    return _buildAddMoreButton();
                  }
                  return _buildImagePreview(index);
                },
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Row(
              children: [
                // Foto button
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Foto',
                    onTap: () => _pickPhoto(),
                  ),
                ),
                const SizedBox(width: 12),
                // Video button
                Expanded(
                  child: _buildMediaButton(
                    icon: Icons.videocam_outlined,
                    label: 'Video',
                    onTap: () => _pickVideo(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImages[index],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return GestureDetector(
      onTap: () => _showImagePickerOptions(),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              'Tambah',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCatalogSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Katalog Makanan di Tempat Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: FoodType.values.length,
            itemBuilder: (context, index) {
              final foodType = FoodType.values[index];
              final isSelected = _selectedFoodTypes.contains(foodType);
              return _buildSelectableChip(
                label: foodType.label,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedFoodTypes.remove(foodType);
                    } else {
                      _selectedFoodTypes.add(foodType);
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceValueSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kesesuaian Tempat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.0,
            ),
            itemCount: PlaceValue.values.length,
            itemBuilder: (context, index) {
              final placeValue = PlaceValue.values[index];
              final isSelected = _selectedPlaceValues.contains(placeValue);
              return _buildSelectableChip(
                label: placeValue.label,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPlaceValues.remove(placeValue);
                    } else {
                      _selectedPlaceValues.add(placeValue);
                    }
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: isSelected ? Border.all(
            color: AppColors.primary,
          ) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewTextSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tuliskan ulasan minimal 25 karakter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Bagikan pengalamanmu untuk membantu pengguna lain membuat pilihan sesuai preferensi mereka',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHideUsernameSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          setState(() {
            _hideUsername = !_hideUsername;
          });
        },
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _hideUsername ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: _hideUsername ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: _hideUsername
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              'Sembunyikan username',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitReview(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Kirim Ulasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void _pickPhoto() {
    _showImagePickerOptions();
  }

  void _pickVideo() {
    // Video uses same picker as photo for now
    _showImagePickerOptions();
  }

  void _showImagePickerOptions() {
    if (_selectedImages.length >= _maxImages) {
      Get.snackbar(
        'Info',
        'Maksimal $_maxImages foto',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Kamera',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Ambil foto baru',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImageFromCamera();
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: AppColors.accent,
                  ),
                ),
                title: Text(
                  'Galeri',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Pilih dari galeri',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final int remaining = _maxImages - _selectedImages.length;
      
      if (remaining <= 0) {
        Get.snackbar(
          'Info',
          'Maksimal $_maxImages foto',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        setState(() {
          // Only add up to remaining slots
          final imagesToAdd = images.take(remaining).map((x) => File(x.path)).toList();
          _selectedImages.addAll(imagesToAdd);
          
          if (images.length > remaining) {
            Get.snackbar(
              'Info',
              'Hanya ${imagesToAdd.length} foto yang ditambahkan (maksimal $_maxImages)',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      Get.snackbar(
        'Error',
        'Silakan berikan penilaian terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan tulis ulasan terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: AppColors.textOnPrimary,
      );
      return;
    }

    // if (_reviewController.text.trim().length < 25) {
    //   Get.snackbar(
    //     'Error',
    //     'Ulasan minimal 25 karakter',
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: AppColors.warning,
    //     colorText: AppColors.textOnPrimary,
    //   );
    //   return;
    // }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload images to Cloudinary if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final cloudinaryService = Get.find<CloudinaryService>();
        
        for (int i = 0; i < _selectedImages.length; i++) {
          final file = _selectedImages[i];
          Logger.debug('Uploading image ${i + 1}/${_selectedImages.length}...', 'GiveReviewView');
          
          final result = await cloudinaryService.uploadReviewImage(file);
          
          if (result.success && result.secureUrl != null) {
            imageUrls.add(result.secureUrl!);
            Logger.debug('Image ${i + 1} uploaded: ${result.secureUrl}', 'GiveReviewView');
          } else {
            Logger.warning('Failed to upload image ${i + 1}: ${result.error}', 'GiveReviewView');
            // Continue with other images even if one fails
          }
        }
        
        Logger.debug('Successfully uploaded ${imageUrls.length}/${_selectedImages.length} images', 'GiveReviewView');
      }

      // Prepare additional info
      final additionalInfo = <String, dynamic>{
        'hide_username': _hideUsername,
      };

      // Add selected food types
      if (_selectedFoodTypes.isNotEmpty) {
        additionalInfo['food_types'] = 
            _selectedFoodTypes.map((e) => e.label).toList();
      }

      // Add selected place values
      if (_selectedPlaceValues.isNotEmpty) {
        additionalInfo['place_values'] = 
            _selectedPlaceValues.map((e) => e.label).toList();
      }

      // Create review with uploaded image URLs
      await controller.createReview(
        place: place!,
        vote: _rating,
        content: _reviewController.text.trim(),
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        additionalInfo: additionalInfo,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal mengirim ulasan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
