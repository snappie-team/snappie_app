import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../routes/app_pages.dart';
import '../controllers/mission_controller.dart';
import '../../shared/widgets/_dialog_widgets/mission_loading_modal.dart';
import '../../shared/widgets/_dialog_widgets/mission_success_modal.dart';
import '../../shared/widgets/_dialog_widgets/mission_failed_modal.dart';

/// Halaman untuk mengisi feedback misi (4 langkah)
class MissionFeedbackView extends GetView<MissionController> {
  const MissionFeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() => _buildFeedbackStep(controller.feedbackStep.value)),
      ),
    );
  }

  Widget _buildFeedbackStep(int step) {
    switch (step) {
      case 0:
        return _FeedbackStep1(controller: controller);
      case 1:
        return _FeedbackStep2(controller: controller);
      case 2:
        return _FeedbackStep3(controller: controller);
      case 3:
        return _FeedbackStep4(controller: controller);
      default:
        return _FeedbackStep1(controller: controller);
    }
  }
}

/// Base feedback layout
class _FeedbackBaseLayout extends StatelessWidget {
  final String placeName;
  final int coinReward;
  final Widget child;

  const _FeedbackBaseLayout({
    required this.placeName,
    required this.coinReward,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with close button and place info
        _buildHeader(),

        // Content
        Expanded(child: child),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Place info
          Expanded(
            child: Row(
              children: [
                // Orange dot indicator
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    placeName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Coin reward badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TODO: Add coin.svg icon to assets/icons/
                Icon(Icons.monetization_on, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$coinReward Koin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Close button
          GestureDetector(
            onTap: () => _showExitConfirmation(),
            child: Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    final controller = Get.find<MissionController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Batalkan Feedback?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Progress feedback akan hilang jika kamu keluar sekarang.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Lanjutkan'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetMission();
              Get.until(
                  (route) => route.settings.name == AppPages.PLACE_DETAIL);
            },
            child: Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feedback Step 1: Apakah informasi yang disajikan sudah sesuai?
class _FeedbackStep1 extends StatelessWidget {
  final MissionController controller;

  const _FeedbackStep1({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _FeedbackBaseLayout(
      placeName: controller.currentPlace?.name ?? 'Nama Tempat',
      coinReward: controller.coinReward,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Question
            Text(
              'Apakah informasi yang disajikan sudah sesuai?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.feedbackAnswers['info_accurate'] = true;
                  controller.feedbackStep.value = 1;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Iya sesuai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.feedbackAnswers['info_accurate'] = false;
                  controller.feedbackStep.value = 1;
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Tidak, ada yang berubah',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Feedback Step 2: Foto mana yang paling cocok untuk profil tempat?
class _FeedbackStep2 extends StatefulWidget {
  final MissionController controller;

  const _FeedbackStep2({required this.controller});

  @override
  State<_FeedbackStep2> createState() => _FeedbackStep2State();
}

class _FeedbackStep2State extends State<_FeedbackStep2> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentIndex = 0;

  List<String> get _images {
    final place = widget.controller.currentPlace;
    final images = <String>[];

    // Add place images
    if (place?.imageUrls != null && place!.imageUrls!.isNotEmpty) {
      images.addAll(place.imageUrls!
          .where((img) => img.url != null)
          .map((img) => img.url!));
    }

    // Add uploaded checkin image if available
    if (widget.controller.uploadedImageUrl.value != null) {
      images.add(widget.controller.uploadedImageUrl.value!);
    }

    return images;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;

    return _FeedbackBaseLayout(
      placeName: widget.controller.currentPlace?.name ?? 'Nama Tempat',
      coinReward: widget.controller.coinReward,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Question
            Text(
              'Foto manakah yang paling cocok menjadi gambar profil tempat ini?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Image carousel
            Expanded(
              child: images.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada foto tersedia',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.surfaceContainer,
                                child: Icon(
                                  Icons.image,
                                  color: AppColors.textTertiary,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Page indicator dots
            if (images.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (images.isNotEmpty) {
                    widget.controller.feedbackAnswers['best_photo_index'] =
                        _currentIndex;
                    widget.controller.feedbackAnswers['best_photo_url'] =
                        images[_currentIndex];
                  }
                  widget.controller.feedbackStep.value = 2;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Lanjut',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Feedback Step 3: Apakah tempat ini hidden gems?
class _FeedbackStep3 extends StatelessWidget {
  final MissionController controller;

  const _FeedbackStep3({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _FeedbackBaseLayout(
      placeName: controller.currentPlace?.name ?? 'Nama Tempat',
      coinReward: controller.coinReward,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Question
            Text(
              'Apakah kamu setuju jika tempat ini disebut ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'hidden gems',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              '?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.feedbackAnswers['is_hidden_gem'] = true;
                  controller.feedbackStep.value = 3;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Iya setuju',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.feedbackAnswers['is_hidden_gem'] = false;
                  controller.feedbackStep.value = 3;
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Tidak setuju',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Feedback Step 4: Rating, tags, dan masukan
class _FeedbackStep4 extends StatefulWidget {
  final MissionController controller;

  const _FeedbackStep4({required this.controller});

  @override
  State<_FeedbackStep4> createState() => _FeedbackStep4State();
}

class _FeedbackStep4State extends State<_FeedbackStep4> {
  int _recommendRating = 0;
  final Set<String> _selectedTags = {};
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _availableTags = [
    'Tampilan mudah dipahami',
    'Informasi tempat',
    'Filter pencarian',
    'Pencarian cepat responsif',
    'Hasil pencarian akurat',
    'Pencarian penuh hadiah',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FeedbackBaseLayout(
      placeName: widget.controller.currentPlace?.name ?? 'Nama Tempat',
      coinReward: widget.controller.coinReward,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question 1: Rating
            Text(
              'Seberapa besar kamu merekomendasikan aplikasi Snappie kepada temanmu?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _recommendRating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _recommendRating ? Icons.star : Icons.star_border,
                      color: index < _recommendRating
                          ? AppColors.warning
                          : AppColors.textTertiary,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Question 2: Tags
            Text(
              'Apa yang paling kamu sukai dari proses pencarian tempat di aplikasi Snappie?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Tags wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTags.remove(tag);
                      } else {
                        _selectedTags.add(tag);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Question 3: Free text feedback
            Text(
              'Masukan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Berikan pendapat atau masukan jika ada',
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

            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Kirim',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback() async {
    // Save answers
    widget.controller.feedbackAnswers['recommend_rating'] = _recommendRating;
    widget.controller.feedbackAnswers['liked_features'] =
        _selectedTags.toList();
    widget.controller.feedbackAnswers['feedback_text'] =
        _feedbackController.text.trim();

    // Show loading modal
    MissionLoadingModal.show(message: 'Mengirim feedback...');

    final success = await widget.controller.submitFeedback();

    // Hide loading modal
    MissionLoadingModal.hide();

    if (success) {
      // Show final success modal
      final claimResult = await MissionSuccessModal.show(
        title: 'Misi Berhasil!',
        description:
            'Selamat, Anda telah menyelesaikan semua misi.\nKlaim ${widget.controller.expReward} XP dan ${widget.controller.coinReward} Koin Kamu!',
      );

      if (claimResult == true) {
        // Reset mission and return to place detail
        widget.controller.resetMission();
        Get.until((route) => route.settings.name == AppPages.PLACE_DETAIL);

        AppSnackbar.success(
          'Kamu mendapatkan total ${widget.controller.expReward} XP',
          title: 'Selamat!',
        );
      }
    } else {
      // Show failed modal
      final retry = await MissionFailedModal.show(
        failureType: MissionFailureType.failed,
      );

      if (retry == true) {
        _submitFeedback();
      }
    }
  }
}
