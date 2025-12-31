import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  int _currentStep = 0;
  final int _totalSteps = 4;
  final Map<String, dynamic> _answers = {};

  // For step 2 - photo selection (2 random images from place)
  int _selectedPhotoIndex = -1; // -1 = none selected
  late List<String> _comparisonImages;

  // For step 4
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
    _initComparisonImages();
  }

  void _initComparisonImages() {
    // Only use place images (not checkin image), pick 2 random
    final placeImages = List<String>.from(widget.placeImages);
    placeImages.shuffle();
    _comparisonImages = placeImages.take(2).toList();
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _close() {
    Get.back(
      result: FeedbackResult(
        completed: false,
        answers: Map.from(_answers),
      ),
    );
  }

  Future<void> _submitFeedback() async {
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
        height: screenHeight * 0.8, // Fixed 70% height
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // Header with progress bar
            _buildHeader(),

            // Content based on current step
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(),
              ),
            ),

            _buildSubmitButton()
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      child: Column(
        children: [
          // Place name and close button row
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.placeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: _close,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Progress bar with coin reward
          Row(
            children: [
              // Progress segments
              Expanded(
                child: Row(
                  children: List.generate(_totalSteps, (index) {
                    final isCompleted = index < _currentStep;
                    final isCurrent = index == _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: isCompleted || isCurrent
                              ? AppColors.accent
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 12),
              
              // Coin reward badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on,
                    color: AppColors.warning,
                    size: 18,
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return _buildStep1();
    }
  }

  /// Step 1: Apakah informasi yang disajikan sudah sesuai?
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Apakah informasi yang disajikan sudah sesuai?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Step 2: Foto mana yang paling cocok untuk profil tempat?
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Foto manakah yang paling cocok menjadi gambar profil tempat ini?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Two images side by side for comparison
          if (_comparisonImages.length >= 2)
            Row(
              children: [
                // Image 1
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoIndex = 0;
                      });
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPhotoIndex == 0
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _comparisonImages[0],
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
                            if (_selectedPhotoIndex == 0)
                              Container(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                child: Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.accent,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Image 2
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPhotoIndex = 1;
                      });
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedPhotoIndex == 1
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _comparisonImages[1],
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
                            if (_selectedPhotoIndex == 1)
                              Container(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                child: Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.accent,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Tidak ada foto tersedia',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          
        ],
      ),
    );
  }

  /// Step 3: Apakah tempat ini hidden gems?
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              children: [
                const TextSpan(text: 'Apakah kamu setuju jika tempat ini disebut '),
                TextSpan(
                  text: 'hidden gems',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build submit button(s) based on current step
  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      // decoration: BoxDecoration(
      //   color: AppColors.surface,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withValues(alpha: 0.05),
      //       blurRadius: 10,
      //       offset: const Offset(0, -4),
      //     ),
      //   ],
      // ),
      child: _buildStepButtons(),
    );
  }

  Widget _buildStepButtons() {
    switch (_currentStep) {
      case 0:
        return _buildYesNoButtons(
          yesLabel: 'Iya sesuai',
          noLabel: 'Tidak, ada yang berubah',
          onYes: () {
            _answers['info_accurate'] = true;
            _goToNextStep();
          },
          onNo: () {
            _answers['info_accurate'] = false;
            _goToNextStep();
          },
        );
      case 1:
        return _buildSingleButton(
          label: 'Lanjut',
          onPressed: _selectedPhotoIndex >= 0
              ? () {
                  _answers['best_photo_index'] = _selectedPhotoIndex;
                  _answers['best_photo_url'] = _comparisonImages[_selectedPhotoIndex];
                  _goToNextStep();
                }
              : null,
        );
      case 2:
        return _buildYesNoButtons(
          yesLabel: 'Iya setuju',
          noLabel: 'Tidak setuju',
          onYes: () {
            _answers['is_hidden_gem'] = true;
            _goToNextStep();
          },
          onNo: () {
            _answers['is_hidden_gem'] = false;
            _goToNextStep();
          },
        );
      case 3:
        return _buildSingleButton(
          label: 'Kirim',
          onPressed: _submitFeedback,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildYesNoButtons({
    required String yesLabel,
    required String noLabel,
    required VoidCallback onYes,
    required VoidCallback onNo,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onYes,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              yesLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onNo,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              noLabel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Step 4: Rating, tags, dan masukan
  Widget _buildStep4() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
}
