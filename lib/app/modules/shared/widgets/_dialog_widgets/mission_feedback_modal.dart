import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';

/// Feedback result model
class FeedbackResult {
  final bool completed;
  final Map<String, dynamic> answers;

  const FeedbackResult({
    required this.completed,
    required this.answers,
  });
}

/// Modal feedback dengan 4 langkah
class MissionFeedbackModal extends StatefulWidget {
  final String placeName;
  final int coinReward;
  final List<String> placeImages;
  final String? checkinImageUrl;

  const MissionFeedbackModal({
    super.key,
    required this.placeName,
    required this.coinReward,
    required this.placeImages,
    this.checkinImageUrl,
  });

  /// Show the feedback modal
  static Future<FeedbackResult?> show({
    required String placeName,
    int coinReward = 25,
    List<String> placeImages = const [],
    String? checkinImageUrl,
  }) async {
    return await Get.dialog<FeedbackResult>(
      MissionFeedbackModal(
        placeName: placeName,
        coinReward: coinReward,
        placeImages: placeImages,
        checkinImageUrl: checkinImageUrl,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<MissionFeedbackModal> createState() => _MissionFeedbackModalState();
}

class _MissionFeedbackModalState extends State<MissionFeedbackModal> {
  final Map<String, dynamic> _answers = {};

  // Feedback form data
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Validate at least one tag is selected
    if (_recommendRating == 0 || _selectedTags.isEmpty) {
      // You can show a snackbar or validation message
      return;
    }

    // Gather all answers
    _answers['recommend_rating'] = _recommendRating;
    _answers['liked_features'] = _selectedTags.toList();
    _answers['feedback_text'] = _feedbackController.text.trim();

    // Close modal with result
    Get.back(
      result: FeedbackResult(
        completed: true,
        answers: Map.from(_answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: screenHeight * 0.8, // 80% of screen height
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Content - All questions in one page
            Expanded(
              child: SingleChildScrollView(
                child: _buildFeedbackContent(),
              ),
            ),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      child: Stack(
        children: [
          // Centered title
          Align(
            alignment: Alignment.center,
            child: Text(
              'Umpan Balik Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Close button on the right
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Get.back(
                result: FeedbackResult(
                  completed: false,
                  answers: Map.from(_answers),
                ),
              ),
              child: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Coin reward badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppAssets.images.coin,
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.coinReward} Koin',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Question 1: Rating
          Text(
            'Seberapa besar kamu merekomendasikan aplikasi Snappie kepada temanmu?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _recommendRating
                        ? Icons.star
                        : Icons.star_border,
                    color: index < _recommendRating
                        ? AppColors.warning
                        : AppColors.textTertiary,
                    size: 32,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Question 2: Tags
          Text(
            'Apa yang paling kamu sukai dari proses pencarian tempat di aplikasi Snappie?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Question 3: Free text feedback
          Text(
            'Masukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _feedbackController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Berikan pendapat atau masukan jika ada',
              hintStyle: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              contentPadding: const EdgeInsets.all(12),
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
                borderSide: BorderSide(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: (_recommendRating > 0 && _selectedTags.isNotEmpty)
              ? _submitFeedback
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textTertiary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Kirim',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
