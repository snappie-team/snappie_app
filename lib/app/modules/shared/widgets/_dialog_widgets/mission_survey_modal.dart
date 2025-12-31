import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';

/// Survey question model
class SurveyQuestion {
  final String question;
  final String positiveAnswer;
  final String negativeAnswer;

  const SurveyQuestion({
    required this.question,
    required this.positiveAnswer,
    required this.negativeAnswer,
  });
}

/// Survey result model
class SurveyResult {
  final bool completed;
  final Map<int, bool> answers; // questionIndex -> isPositive

  const SurveyResult({
    required this.completed,
    required this.answers,
  });
}

/// Modal survey dengan 4 slide pertanyaan
class MissionSurveyModal extends StatefulWidget {
  final String placeName;
  final int coinReward;

  const MissionSurveyModal({
    super.key,
    required this.placeName,
    required this.coinReward,
  });

  /// Show the survey modal
  static Future<SurveyResult?> show({
    required String placeName,
    int coinReward = 25,
  }) async {
    return await Get.dialog<SurveyResult>(
      MissionSurveyModal(
        placeName: placeName,
        coinReward: coinReward,
      ),
      barrierDismissible: false,
    );
  }

  @override
  State<MissionSurveyModal> createState() => _MissionSurveyModalState();
}

class _MissionSurveyModalState extends State<MissionSurveyModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<int, bool> _answers = {};

  // 4 survey questions
  final List<SurveyQuestion> _questions = const [
    SurveyQuestion(
      question: 'Apakah informasi yang disajikan sudah sesuai?',
      positiveAnswer: 'Iya sesuai',
      negativeAnswer: 'Tidak, ada yang berubah',
    ),
    SurveyQuestion(
      question: 'Apakah tempat ini nyaman untuk dikunjungi?',
      positiveAnswer: 'Ya, nyaman',
      negativeAnswer: 'Tidak, kurang nyaman',
    ),
    SurveyQuestion(
      question: 'Apakah pelayanan di tempat ini memuaskan?',
      positiveAnswer: 'Ya, memuaskan',
      negativeAnswer: 'Tidak, kurang memuaskan',
    ),
    SurveyQuestion(
      question: 'Apakah kamu akan merekomendasikan tempat ini?',
      positiveAnswer: 'Ya, saya rekomendasikan',
      negativeAnswer: 'Tidak, saya tidak rekomendasikan',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _answerQuestion(bool isPositive) {
    setState(() {
      _answers[_currentPage] = isPositive;
    });

    if (_currentPage < _questions.length - 1) {
      // Go to next question
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Survey completed
      Get.back(
        result: SurveyResult(
          completed: true,
          answers: Map.from(_answers),
        ),
      );
    }
  }

  void _close() {
    Get.back(
      result: SurveyResult(
        completed: false,
        answers: Map.from(_answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildHeader(),

            // Progress indicator
            _buildProgressIndicator(),

            // Question content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index]);
                },
              ),
            ),

            // Answer buttons
            _buildAnswerButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      child: Row(
        children: [
          // Back button (if not first page)
          if (_currentPage > 0)
            IconButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
            )
          else
            const SizedBox(width: 48),

          // Place name
          Expanded(
            child: Text(
              widget.placeName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Close button
          IconButton(
            onPressed: _close,
            icon: Icon(
              Icons.close,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Progress bar
          Expanded(
            child: Row(
              children: List.generate(_questions.length, (index) {
                final isCompleted = index < _currentPage;
                final isCurrent = index == _currentPage;
                final isLast = index == _questions.length - 1;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isCompleted || isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      if (!isLast) const SizedBox(width: 4),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(width: 12),

          // Coin reward
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '🪙',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.coinReward} Koin',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(SurveyQuestion question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Text(
          question.question,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButtons() {
    final question = _questions[_currentPage];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Positive answer button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _answerQuestion(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                question.positiveAnswer,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Negative answer button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _answerQuestion(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Text(
                question.negativeAnswer,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
