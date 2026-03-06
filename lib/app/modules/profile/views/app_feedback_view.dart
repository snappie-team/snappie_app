import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/modules/shared/layout/views/scaffold_frame.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../controllers/profile_controller.dart';
import '../../shared/widgets/index.dart';

/// Halaman feedback / masukan untuk aplikasi Snappie
/// Diakses dari Settings
class AppFeedbackView extends StatefulWidget {
  const AppFeedbackView({super.key});

  @override
  State<AppFeedbackView> createState() => _AppFeedbackViewState();
}

class _AppFeedbackViewState extends State<AppFeedbackView> {
  int _appRating = 0;
  final Set<String> _selectedFeatures = {};
  int _easeOfUseRating = 0;
  final Set<String> _improvements = {};
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  /// Fitur yang paling disukai pengguna
  final List<String> _featureOptions = [
    'Tampilan mudah dipahami',
    'Informasi tempat lengkap',
    'Filter pencarian',
    'Pencarian cepat & responsif',
    'Hasil pencarian akurat',
    'Sistem misi & reward',
    'Galeri foto tempat',
    'Fitur review tempat',
  ];

  /// Area yang bisa ditingkatkan
  final List<String> _improvementOptions = [
    'Kecepatan aplikasi',
    'Desain tampilan',
    'Kelengkapan data tempat',
    'Fitur pencarian',
    'Sistem reward & koin',
    'Notifikasi',
    'Keamanan akun',
    'Tutorial penggunaan',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldFrame.detail(
      title: 'Masukan & Saran',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Header
              _buildSectionCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bantu kami jadi lebih baik!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pendapatmu sangat berarti untuk pengembangan aplikasi Snappie.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Question 1: Rating aplikasi
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionLabel(
                      '1. Seberapa besar kamu merekomendasikan Snappie kepada temanmu?',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _appRating = index + 1);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              index < _appRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: index < _appRating
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                              size: 36,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Question 2: Fitur favorit
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionLabel(
                      '2. Apa yang paling kamu sukai dari aplikasi Snappie?',
                    ),
                    const SizedBox(height: 12),
                    _buildTagWrap(
                      options: _featureOptions,
                      selectedSet: _selectedFeatures,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Question 3: Kemudahan penggunaan
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionLabel(
                      '3. Seberapa mudah penggunaan aplikasi Snappie menurutmu?',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        final isSelected = _easeOfUseRating == index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _easeOfUseRating = index + 1);
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sangat sulit',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Text(
                          'Sangat mudah',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Question 4: Area yang bisa ditingkatkan
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionLabel(
                      '4. Area mana yang menurutmu perlu ditingkatkan?',
                    ),
                    const SizedBox(height: 12),
                    _buildTagWrap(
                      options: _improvementOptions,
                      selectedSet: _improvements,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Question 5: Free text
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestionLabel(
                      '5. Ada masukan atau saran lainnya?',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText:
                            'Ceritakan pengalamanmu menggunakan Snappie...',
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
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withAlpha(100),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
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
                          'Kirim Masukan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildQuestionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildTagWrap({
    required List<String> options,
    required Set<String> selectedSet,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedSet.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedSet.remove(option);
              } else {
                selectedSet.add(option);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitFeedback() async {
    // Validasi minimal rating
    if (_appRating == 0) {
      AppSnackbar.warning(
        'Berikan rating terlebih dahulu',
        title: 'Peringatan',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final feedbackData = {
        'app_rating': _appRating,
        'liked_features': _selectedFeatures.toList(),
        'ease_of_use_rating': _easeOfUseRating,
        'improvement_areas': _improvements.toList(),
        'feedback_text': _feedbackController.text.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      };

      final profileController = Get.find<ProfileController>();

      // Show loading modal with avatar
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarWidget(
                  imageUrl: profileController.userAvatar,
                  size: AvatarSize.extraLarge,
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Mengirim masukan...',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await profileController.userRepository.updateUserProfile(
        userFeedback: feedbackData,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // close loading modal

      // Show thank you modal
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarWidget(
                  imageUrl: profileController.userAvatar,
                  size: AvatarSize.extraLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Terima Kasih! 🎉',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukan dan saranmu sangat berarti untuk pengembangan Snappie.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      Get.back(); // navigate back to settings
    } catch (e) {
      // Dismiss loading modal if still showing
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      AppSnackbar.error(
        'Gagal mengirim masukan. Silakan coba lagi.',
        title: 'Gagal',
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
