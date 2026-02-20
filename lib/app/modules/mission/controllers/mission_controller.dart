import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snappie_app/app/core/constants/app_colors.dart';
import 'package:snappie_app/app/core/services/cloudinary_service.dart';
import 'package:snappie_app/app/core/services/gamification_handler_service.dart';
import 'package:snappie_app/app/core/services/location_service.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../data/models/place_model.dart';
import '../../../data/models/checkin_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/checkin_repository_impl.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/constants/food_type.dart';
import '../../../core/constants/place_value.dart';
import '../../profile/controllers/profile_controller.dart';

/// Mission Step Enum
enum MissionStep {
  photo, // Step 1: Ambil foto (Check-in)
  review, // Step 2: Tulis ulasan
  feedback, // Step 3: Isi feedback (renamed from survey)
}

/// Mission Controller
class MissionController extends GetxController {
  // Repositories
  late final CheckinRepository _checkinRepository;
  late final ReviewRepository _reviewRepository;

  // Current place for mission
  PlaceModel? currentPlace;

  // Current mission step
  final Rx<MissionStep> currentStep = MissionStep.photo.obs;

  // Photo capture state
  final Rx<String?> capturedImagePath = Rx<String?>(null);
  final Rx<String?> uploadedImageUrl = Rx<String?>(null); // URL after upload

  // Review state
  final reviewController = TextEditingController();
  final Rx<int> rating = 0.obs; // Start with 0 (no rating selected)
  final RxList<String> reviewMediaPaths =
      <String>[].obs; // Photos/videos for review
  final RxList<FoodType> selectedFoodTypes =
      <FoodType>[].obs; // Selected food types
  final RxList<PlaceValue> selectedPlaceValues =
      <PlaceValue>[].obs; // Selected place values

  // Survey state
  final RxMap<String, dynamic> surveyAnswers = <String, dynamic>{}.obs;

  // Feedback state (new multi-step feedback)
  final RxInt feedbackStep = 0.obs; // 0-3 for 4 feedback steps
  final RxMap<String, dynamic> feedbackAnswers = <String, dynamic>{}.obs;

  // Settings from confirm modal
  final RxBool hideUsername = false.obs;

  // Loading state
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  // Error state
  final Rx<String?> errorMessage = Rx<String?>(null);
  final RxBool isConflictError =
      false.obs; // 409 Conflict - already reviewed/checked-in

  // Results
  final Rx<CheckinModel?> checkinResult = Rx<CheckinModel?>(null);
  final Rx<ReviewModel?> reviewResult = Rx<ReviewModel?>(null);

  // Points from place
  int get expReward => currentPlace?.expReward ?? 50;
  int get coinReward => currentPlace?.coinReward ?? 25;

  @override
  void onInit() {
    super.onInit();
    _checkinRepository = Get.find<CheckinRepository>();
    _reviewRepository = Get.find<ReviewRepository>();
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }

  /// Initialize mission with place
  void initMission(PlaceModel place, {bool hideUsername = false}) {
    currentPlace = place;
    currentStep.value = MissionStep.photo;
    capturedImagePath.value = null;
    uploadedImageUrl.value = null;
    reviewController.clear();
    rating.value = 0; // No rating selected initially
    reviewMediaPaths.clear();
    selectedFoodTypes.clear();
    selectedPlaceValues.clear();
    surveyAnswers.clear();
    feedbackStep.value = 0;
    feedbackAnswers.clear();
    this.hideUsername.value = hideUsername;
    errorMessage.value = null;
    isConflictError.value = false;
    checkinResult.value = null;
    reviewResult.value = null;
  }

  /// Set captured image path
  void setCapturedImage(String path) {
    capturedImagePath.value = path;
  }

  /// Clear captured image
  void clearCapturedImage() {
    capturedImagePath.value = null;
  }

  /// Set hide username preference
  void setHideUsername(bool value) {
    hideUsername.value = value;
  }

  /// Add media to review
  void addReviewMedia(String path) {
    if (!reviewMediaPaths.contains(path)) {
      reviewMediaPaths.add(path);
    }
  }

  /// Remove media from review
  void removeReviewMedia(String path) {
    reviewMediaPaths.remove(path);
  }

  /// Toggle food type selection
  void toggleFoodType(FoodType foodType) {
    if (selectedFoodTypes.contains(foodType)) {
      selectedFoodTypes.remove(foodType);
    } else {
      selectedFoodTypes.add(foodType);
    }
  }

  /// Toggle place value selection
  void togglePlaceValue(PlaceValue placeValue) {
    if (selectedPlaceValues.contains(placeValue)) {
      selectedPlaceValues.remove(placeValue);
    } else {
      selectedPlaceValues.add(placeValue);
    }
  }

  /// Get current location using LocationService
  Future<Position?> _getCurrentLocation() async {
    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition(
      showSnackbars: false,
      accuracy: LocationAccuracy.high,
    );

    if (position == null) {
      errorMessage.value = 'Failed to get location';
    }

    return position;
  }

  /// Submit photo mission (Check-in)
  Future<bool> submitPhoto() async {
    if (capturedImagePath.value == null || currentPlace == null) {
      errorMessage.value = 'No photo captured or place not set';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        isSubmitting.value = false;
        return false;
      }

      // Upload image to Cloudinary
      final cloudinaryService = Get.find<CloudinaryService>();
      final file = File(capturedImagePath.value!);

      Logger.debug('Uploading to Cloudinary...', 'MissionController');
      final uploadResult = await cloudinaryService.uploadCheckinImage(file);

      if (!uploadResult.success || uploadResult.secureUrl == null) {
        errorMessage.value = uploadResult.error ?? 'Failed to upload image';
        isSubmitting.value = false;
        return false;
      }

      final imageUrl = uploadResult.secureUrl!;
      uploadedImageUrl.value = imageUrl;

      Logger.debug(
          'Position: ${position.latitude}, ${position.longitude}', 'MissionController');
      Logger.debug('Uploaded image URL: $imageUrl', 'MissionController');

      // Create checkin
      final response = await _checkinRepository.createCheckin(
        placeId: currentPlace!.id!,
        latitude: position.latitude,
        longitude: position.longitude,
        imageUrl: imageUrl,
        additionalInfo: {
          'device': GetPlatform.isAndroid ? 'android' : 'ios',
        },
      );

      checkinResult.value = response.actionData;

      // Handle gamification if present
      if (response.hasGamification) {
        Logger.debug('Gamification data received, processing...', 'MissionController');
        await GamificationHandlerService.handleGamificationResult(
          response.gamification!,
        );
      }

      isConflictError.value = false;
      return true;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      isConflictError.value = false;
      return false;
    } on ServerException catch (e) {
      errorMessage.value = e.message;
      // Check for 409 Conflict - already checked-in
      isConflictError.value = e.statusCode == 409;
      return false;
    } on ValidationException catch (e) {
      errorMessage.value = e.message;
      isConflictError.value = false;
      return false;
    } catch (e) {
      errorMessage.value = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      isConflictError.value = false;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Create review for a place (standalone, used by MissionReviewView)
  Future<void> createReview({
    required PlaceModel place,
    required int vote,
    required String content,
    List<String>? imageUrls,
    Map<String, dynamic> additionalInfo = const {},
  }) async {
    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      // Create review via repository
      final response = await _reviewRepository.createReview(
        placeId: place.id!,
        content: content,
        rating: vote,
        imageUrls: imageUrls,
        additionalInfo: additionalInfo,
      );

      // Handle gamification if present
      if (response.hasGamification) {
        Logger.debug('Review gamification data received, processing...', 'MissionController');
        await GamificationHandlerService.handleGamificationResult(
          response.gamification!,
        );
      }

      // Show success and go back
      Get.snackbar(
        'Berhasil',
        'Ulasan berhasil dikirim! Kamu mendapatkan ${place.expReward ?? 50} XP dan ${place.coinReward ?? 25} Koin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success,
        colorText: AppColors.textOnPrimary,
        duration: const Duration(seconds: 3),
      );

      await Future.delayed(const Duration(milliseconds: 100));
      Get.back(closeOverlays: true);
    } on ServerException catch (e) {
      final msg = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      errorMessage.value = msg;
      Get.snackbar(
        'Gagal',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    } catch (e) {
      final msg = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      errorMessage.value = msg;
      Get.snackbar(
        'Gagal',
        msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.textOnPrimary,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit review mission (includes survey in additional_info)
  Future<bool> submitReview() async {
    if (currentPlace == null) {
      errorMessage.value = 'Place not set';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      // Prepare image URLs (from checkin photo + review media)
      final imageUrls = <String>[];
      if (uploadedImageUrl.value != null) {
        imageUrls.add(uploadedImageUrl.value!);
      }
      // Add review media URLs
      imageUrls.addAll(reviewMediaPaths);

      // Prepare additional info
      final additionalInfo = <String, dynamic>{
        'hide_username': hideUsername.value,
      };

      // Add selected food types
      if (selectedFoodTypes.isNotEmpty) {
        additionalInfo['food_types'] =
            selectedFoodTypes.map((e) => e.label).toList();
      }

      // Add selected place values
      if (selectedPlaceValues.isNotEmpty) {
        additionalInfo['place_values'] =
            selectedPlaceValues.map((e) => e.label).toList();
      }

      // Add survey answers if available
      if (surveyAnswers.isNotEmpty) {
        additionalInfo['survey'] = Map<String, dynamic>.from(surveyAnswers);
      }

      Logger.debug(
        'Submitting review: placeId=${currentPlace!.id}, rating=${rating.value}, images=${imageUrls.length}, foodTypes=${selectedFoodTypes.length}, placeValues=${selectedPlaceValues.length}',
        'MissionController',
      );

      // Create review
      final trimmedContent = reviewController.text.trim();
      final response = await _reviewRepository.createReview(
        placeId: currentPlace!.id!,
        content: trimmedContent.isEmpty ? 'oi' : trimmedContent,
        rating: rating.value,
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        additionalInfo: additionalInfo,
      );

      reviewResult.value = response.actionData;

      // Handle gamification if present
      if (response.hasGamification) {
        Logger.debug('Review gamification data received, processing...', 'MissionController');
        await GamificationHandlerService.handleGamificationResult(
          response.gamification!,
        );
      }

      isConflictError.value = false;
      return true;
    } on NetworkException catch (e) {
      Logger.error('Submit review network error', e, null, 'MissionController');
      errorMessage.value = e.message;
      isConflictError.value = false;
      return false;
    } on ServerException catch (e) {
      Logger.error(
        'Submit review server error (status=${e.statusCode})',
        e,
        null,
        'MissionController',
      );
      errorMessage.value = e.message;
      // Check for 409 Conflict - already reviewed
      isConflictError.value = e.statusCode == 409;
      return false;
    } on ValidationException catch (e) {
      Logger.error('Submit review validation error', e, null, 'MissionController');
      errorMessage.value = e.message;
      isConflictError.value = false;
      return false;
    } catch (e) {
      Logger.error('Submit review unexpected error', e, null, 'MissionController');
      errorMessage.value = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      isConflictError.value = false;
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit survey mission (data goes to review's additional_info)
  /// This just marks survey as complete, actual data is sent with review
  Future<bool> submitSurvey() async {
    if (surveyAnswers.length < 3) {
      errorMessage.value = 'Please answer all survey questions';
      return false;
    }

    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      // Survey data is already in surveyAnswers
      // It will be included in the review's additional_info
      // If review was already submitted, we need to update it
      // For now, we assume survey is submitted together with review

      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      errorMessage.value = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Submit feedback mission (update review with feedback data)
  Future<bool> submitFeedback() async {
    isSubmitting.value = true;
    errorMessage.value = null;

    try {
      // Check if we have a review result to update
      if (reviewResult.value == null || reviewResult.value!.id == null) {
        errorMessage.value = 'No review to update';
        return false;
      }

      // Prepare feedback data for additional_info
      final feedbackData = <String, dynamic>{
        'info_accurate': feedbackAnswers['info_accurate'],
        'best_photo_index': feedbackAnswers['best_photo_index'],
        'best_photo_url': feedbackAnswers['best_photo_url'],
        'is_hidden_gem': feedbackAnswers['is_hidden_gem'],
        'recommend_rating': feedbackAnswers['recommend_rating'],
        'liked_features': feedbackAnswers['liked_features'],
        'feedback_text': feedbackAnswers['feedback_text'],
      };

      // Merge with existing additional_info
      final existingInfo = reviewResult.value!.additionalInfo ?? {};
      if (existingInfo['is_submitted_app_review'] == true) {
        errorMessage.value = 'Feedback sudah dikirim';
        return false;
      }
      final updatedInfo = <String, dynamic>{
        ...existingInfo,
        'feedback': feedbackData,
        'is_submitted_app_review': true,
      };

      // Update review with feedback data
      final updatedReview = await _reviewRepository.updateReview(
        reviewId: reviewResult.value!.id!,
        additionalInfo: updatedInfo,
      );

      reviewResult.value = updatedReview;
      try {
        final profileController = Get.find<ProfileController>();
        if (coinReward > 0) {
          await profileController.addCoins(coinReward);
        }
        if (expReward > 0) {
          await profileController.addExp(expReward);
        }
      } catch (e) {
        Logger.error('Error updating profile rewards', e, null, 'MissionController');
      }
      return true;
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
      return false;
    } on ServerException catch (e) {
      errorMessage.value = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      return false;
    } catch (e) {
      errorMessage.value = ErrorHandler.getReadableMessage(e, tag: 'MissionController');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Move to next step
  void nextStep() {
    switch (currentStep.value) {
      case MissionStep.photo:
        currentStep.value = MissionStep.review;
        break;
      case MissionStep.review:
        currentStep.value = MissionStep.feedback;
        break;
      case MissionStep.feedback:
        // Mission complete
        break;
    }
  }

  /// Reset mission
  void resetMission() {
    currentPlace = null;
    currentStep.value = MissionStep.photo;
    capturedImagePath.value = null;
    uploadedImageUrl.value = null;
    reviewController.clear();
    rating.value = 0;
    reviewMediaPaths.clear();
    selectedFoodTypes.clear();
    selectedPlaceValues.clear();
    surveyAnswers.clear();
    feedbackStep.value = 0;
    feedbackAnswers.clear();
    hideUsername.value = false;
    errorMessage.value = null;
    isConflictError.value = false;
    checkinResult.value = null;
    reviewResult.value = null;
  }

  /// Save survey answers from modal
  void saveSurveyAnswers(Map<int, bool> answers) {
    surveyAnswers.clear();
    answers.forEach((questionIndex, isPositive) {
      surveyAnswers['q${questionIndex + 1}'] = isPositive;
    });
  }
}
