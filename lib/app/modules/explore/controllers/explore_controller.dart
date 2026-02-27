import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/food_type.dart';
import 'package:snappie_app/app/core/constants/place_value.dart';
import '../../../core/services/logger_service.dart';
import '../../../data/models/place_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/checkin_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/gamification_model.dart';
import '../../../data/repositories/place_repository_impl.dart';
import '../../../data/repositories/review_repository_impl.dart';
import '../../../data/repositories/checkin_repository_impl.dart';
import '../../../data/repositories/post_repository_impl.dart';
import '../../../data/repositories/user_repository_impl.dart';
import '../../../data/repositories/gamification_repository_impl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../core/helpers/error_handler.dart';

class ExploreController extends GetxController {
  final PlaceRepository placeRepository;
  final ReviewRepository reviewRepository;
  final CheckinRepository checkinRepository;
  final PostRepository postRepository;
  final UserRepository userRepository;
  final GamificationRepository gamificationRepository;
  final AuthService authService;

  ExploreController({
    required this.placeRepository,
    required this.reviewRepository,
    required this.checkinRepository,
    required this.postRepository,
    required this.userRepository,
    required this.gamificationRepository,
    required this.authService,
  });

  // Place-related reactive variables
  final _isLoading = false.obs;
  final _allPlaces = <PlaceModel>[].obs; // Original list from API
  final _filteredPlaces = <PlaceModel>[].obs; // Filtered list for display
  final _categories = <String>[].obs;
  final _selectedPlace = Rxn<PlaceModel>();
  final _selectedImageUrls = Rxn<List<String>>();
  final _errorMessage = ''.obs;
  final _searchQuery = ''.obs;
  final _isSearching = false.obs; // Local search indicator
  final _selectedCategory = ''.obs;
  final _selectedRating = Rxn<int>();
  final _selectedPriceRange = Rxn<String>();
  final _selectedLocation = Rxn<List<double>>();
  final _selectedFilter = ''.obs; // For 'favorit' or 'terlaris'
  final _hasMoreData = true.obs;
  final _currentPage = 1.obs;
  final _isLoadingCategories = false.obs;

  // Review-related reactive variables
  final _reviews = <ReviewModel>[].obs;
  final _userReviews = <ReviewModel>[].obs;
  final _isCreatingReview = false.obs;
  final _isLoadingReviews = false.obs;
  final _selectedReview = Rxn<ReviewModel>();

  // Check-in related
  final _isCreatingCheckin = false.obs;

  // Gallery-related reactive variables
  final _galleryCheckins = <CheckinModel>[].obs;
  final _galleryPosts = <PostModel>[].obs;
  final _isLoadingGalleryCheckins = false.obs;
  final _isLoadingGalleryPosts = false.obs;

  // Favorite/Saved places related
  final _isTogglingFavorite = false.obs;
  final _savedPlaces = <int>[].obs;
  final _isLoadingSavedPlaces = false.obs;
  final _isLoadingPlaceStatus = false.obs;
  final _placeStatus = Rxn<PlaceGamificationStatus>();

  // Initialization flag
  final _isInitialized = false.obs;

  // Banner visibility state
  final _showBanner = true.obs;
  final _showMissionCta = true.obs;

  Timer? _searchDebounce;

  // Search text controller
  final searchTextController = TextEditingController();

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingCategories => _isLoadingCategories.value;
  bool get isLoadingReviews => _isLoadingReviews.value;
  bool get isCreatingReview => _isCreatingReview.value;
  bool get isCreatingCheckin => _isCreatingCheckin.value;
  bool get isLoadingGalleryCheckins => _isLoadingGalleryCheckins.value;
  bool get isLoadingGalleryPosts => _isLoadingGalleryPosts.value;
  bool get isTogglingFavorite => _isTogglingFavorite.value;
  bool get isLoadingSavedPlaces => _isLoadingSavedPlaces.value;
  bool get isLoadingPlaceStatus => _isLoadingPlaceStatus.value;
  bool get isSearching => _isSearching.value;
  List<int> get savedPlaces => _savedPlaces;

  List<PlaceModel> get places => _filteredPlaces; // Return filtered list
  List<String> get categories => _categories;
  List<ReviewModel> get reviews => _reviews;
  List<ReviewModel> get userReviews => _userReviews;
  List<CheckinModel> get galleryCheckins => _galleryCheckins;
  List<PostModel> get galleryPosts => _galleryPosts;

  PlaceModel? get selectedPlace => _selectedPlace.value;
  List<String>? get selectedImageUrls => _selectedImageUrls.value;
  ReviewModel? get selectedReview => _selectedReview.value;
  PlaceGamificationStatus? get placeStatus => _placeStatus.value;

  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  int? get selectedRating => _selectedRating.value;
  String? get selectedPriceRange => _selectedPriceRange.value;
  String get selectedFilter => _selectedFilter.value;

  List<String> get foodTypes => FoodTypeExtension.allLabels;
  List<String> get placeValues => PlaceValueExtension.allLabels;

  final _selectedFoodTypes = <String>[].obs;
  final _selectedPlaceValues = <String>[].obs;
  RxList<String> get selectedFoodTypes => _selectedFoodTypes;
  RxList<String> get selectedPlaceValues => _selectedPlaceValues;

  // Check if any filter is active
  bool get isFiltered =>
      _searchQuery.value.isNotEmpty ||
      _selectedCategory.value.isNotEmpty ||
      _selectedRating.value != null ||
      _selectedPriceRange.value != null ||
      _selectedFilter.value.isNotEmpty;

  // Setters untuk widget access
  set searchQuery(String value) => _searchQuery.value = value;
  set selectedCategory(String value) => _selectedCategory.value = value;

  bool get hasMoreData => _hasMoreData.value;
  int get currentPage => _currentPage.value;
  bool get showBanner => _showBanner.value;
  bool get showMissionCta => _showMissionCta.value;
  bool get hasCheckinThisMonth =>
      _placeStatus.value?.hasCheckinThisMonth ?? false;
  bool get hasReviewThisMonth =>
      _placeStatus.value?.hasReviewThisMonth ?? false;
  bool get appReviewSubmittedThisMonth =>
      _placeStatus.value?.appReviewSubmittedThisMonth ?? false;
  bool get canCheckin => _placeStatus.value?.canCheckin ?? true;
  bool get canReview => _placeStatus.value?.canReview ?? true;
  bool get canSubmitAppReview => _placeStatus.value?.canSubmitAppReview ?? true;

  void hideBanner() => _showBanner.value = false;
  void hideMissionCta() => _showMissionCta.value = false;
  void showMissionCtaPrompt() => _showMissionCta.value = true;

  @override
  void onInit() {
    super.onInit();
    // Set default filter - use valid category from backend
    _selectedCategory.value = '';
    Logger.debug(
        'ExploreController created (not initialized yet)', 'ExploreController');
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  /// Initialize data hanya saat tab pertama kali dibuka
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      Logger.debug('ExploreController initializing...', 'ExploreController');
      initializeExploreData();
    }
  }

  // Call this method when user is authenticated and navigates to explore
  Future<void> initializeExploreData() async {
    Logger.debug('INITIALIZING EXPLORE DATA:', 'ExploreController');
    Logger.debug('Auth Status: ${authService.isLoggedIn}', 'ExploreController');
    Logger.debug('Token: ${authService.token}', 'ExploreController');
    Logger.debug('User Email: ${authService.userEmail}', 'ExploreController');

    if (authService.isLoggedIn) {
      Logger.debug(
          'User authenticated, loading explore data...', 'ExploreController');
      await loadExploreData();
    } else {
      Logger.debug(
          'User not authenticated, skipping data load', 'ExploreController');
    }
  }

  Future<void> loadExploreData() async {
    // Check if user is authenticated
    if (!authService.isLoggedIn) {
      Logger.debug('User not authenticated, cannot load explore data',
          'ExploreController');
      _setError('Please login to view places and categories');
      return;
    }

    await Future.wait([
      loadPlaces(),
      loadCategories(),
    ]);
  }

  // ===== PLACE METHODS =====

  Future<void> loadPlaces({bool refresh = false, bool fromApi = true}) async {
    // Check authentication before loading
    if (!authService.isLoggedIn) {
      _setError('Please login to view places');
      return;
    }

    if (refresh) {
      _currentPage.value = 1;
      _hasMoreData.value = true;
      _allPlaces.clear();
      _filteredPlaces.clear();
    }

    if (!_hasMoreData.value && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      Logger.debug(
          "Load Places with filters: "
              "selectedCategory='${_selectedCategory.value}', "
              "selectedRating=${_selectedRating.value}, "
              "selectedPriceRange='${_selectedPriceRange.value}', "
              "selectedFilter='${_selectedFilter.value}', "
              "selectedLocation=${_selectedLocation.value}",
          'ExploreController');

      // Load places from repository - don't include search query (local search)
      final placesList = await placeRepository.getPlaces(
        perPage: 50, // Load more for local search
        minRating: _selectedRating.value?.toDouble(),
        partner: _selectedFilter.value == 'partner' ? true : null,
        popular: _selectedFilter.value == 'popular' ? true : null,
        longitude: _selectedFilter.value == 'nearby'
            ? _selectedLocation.value![1]
            : null,
        latitude: _selectedFilter.value == 'nearby'
            ? _selectedLocation.value![0]
            : null,
        placeValues: _selectedFilter.value == 'placeValues'
            ? _selectedPlaceValues.toList()
            : null,
        foodTypes: _selectedFilter.value == 'foodTypes'
            ? _selectedFoodTypes.toList()
            : null,
      );

      Logger.debug('PLACES LOADED SUCCESSFULLY:', 'ExploreController');
      Logger.debug('Places Count: ${placesList.length}', 'ExploreController');
      Logger.debug(
          'First Place: ${placesList.isNotEmpty ? placesList.first.name : "None"}',
          'ExploreController');
      Logger.debug(
          'First Place Additional Info: ${placesList.isNotEmpty ? placesList.first.placeAttributes : "None"}',
          'ExploreController');

      if (refresh || _currentPage.value == 1) {
        Logger.debug('Assigning all places to _allPlaces', 'ExploreController');
        _allPlaces.assignAll(placesList);
      } else {
        Logger.debug(
            'Adding places to existing _allPlaces', 'ExploreController');
        _allPlaces.addAll(placesList);
      }

      Logger.debug('_allPlaces length after update: ${_allPlaces.length}',
          'ExploreController');

      if (placesList.isEmpty) {
        _hasMoreData.value = false;
      } else {
        _currentPage.value++;
      }

      // Apply local search filter
      _applyLocalSearch();
    } catch (e) {
      _setError(ErrorHandler.getReadableMessage(e, tag: 'ExploreController'));
    }

    _setLoading(false);
  }

  Future<void> loadCategories() async {
    // Check authentication before loading
    if (!authService.isLoggedIn) {
      Logger.debug('User not authenticated, cannot load categories',
          'ExploreController');
      return;
    }

    _isLoadingCategories.value = true;

    try {
      // TODO: Implement categories API endpoint
      // For now, use hardcoded categories
      _categories
          .assignAll(['Semua', 'Restoran', 'Kafe', 'Street Food', 'Fast Food']);
      Logger.debug('Categories loaded', 'ExploreController');
    } catch (e) {
      // Handle error silently for categories
      Logger.error('Error loading categories', e, null, 'ExploreController');
    }

    _isLoadingCategories.value = false;
  }

  /// Apply local search filter to places
  void _applyLocalSearch() {
    List<PlaceModel> result = List.from(_allPlaces);

    // Apply search filter locally
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      result = result.where((place) {
        final name = place.name?.toLowerCase() ?? '';
        // final address = place.address?.toLowerCase() ?? '';
        // final description = place.description?.toLowerCase() ?? '';
        // final category = place.category?.toLowerCase() ?? '';

        return name.contains(query);
        // address.contains(query) ||
        // description.contains(query) ||
        // category.contains(query);
      }).toList();
    }

    _filteredPlaces.value = result;
    Logger.debug('Filtered places: ${result.length} of ${_allPlaces.length}',
        'ExploreController');
  }

  /// Handle search input with debounce (local search)
  void handleSearchInput(String query,
      {Duration delay = const Duration(milliseconds: 300)}) {
    _searchQuery.value = query;
    _searchDebounce?.cancel();

    // Show searching state immediately if query is not empty
    if (query.isNotEmpty) {
      _isSearching.value = true;
    }

    // Debounce the actual filter
    _searchDebounce = Timer(delay, () {
      _applyLocalSearch();
      _isSearching.value = false;
    });
  }

  /// Legacy method - now uses local search
  void searchPlaces(String query) {
    _searchQuery.value = query;
    _applyLocalSearch();
  }

  void applyFilter(String filter) {
    _selectedFilter.value = filter;
    loadPlaces(refresh: true);
  }

  void togglePlaceValueSelection(String placeValue) {
    if (_selectedPlaceValues.contains(placeValue)) {
      _selectedPlaceValues.remove(placeValue);
      Logger.debug('Place value removed: $placeValue', 'ExploreController');
    } else {
      _selectedPlaceValues.add(placeValue);
      Logger.debug('Place value selected: $placeValue', 'ExploreController');
    }
    Logger.debug(
        'Total selected: ${_selectedPlaceValues.length} - ${_selectedPlaceValues.join(", ")}',
        'ExploreController');
  }

  void toggleFoodTypeSelection(String foodType) {
    if (_selectedFoodTypes.contains(foodType)) {
      _selectedFoodTypes.remove(foodType);
      Logger.debug('Food type removed: $foodType', 'ExploreController');
    } else {
      _selectedFoodTypes.add(foodType);
      Logger.debug('Food type selected: $foodType', 'ExploreController');
    }
    Logger.debug(
        'Total selected: ${_selectedFoodTypes.length} - ${_selectedFoodTypes.join(", ")}',
        'ExploreController');
  }

  void filterByCategory(String category) {
    _selectedCategory.value = category;
    loadPlaces(refresh: true);
  }

  void setSelectedRating(int rating) {
    _selectedRating.value = rating;
    // Don't load places immediately, wait for user to press OK
  }

  void applyRatingFilter() {
    loadPlaces(refresh: true);
  }

  void clearRatingFilter() {
    _selectedRating.value = null;
    loadPlaces(refresh: true);
  }

  void setSelectedPriceRange(String priceRange) {
    _selectedPriceRange.value = priceRange;
    // Don't load places immediately, wait for user to press OK
  }

  void applyPriceFilter() {
    loadPlaces(refresh: true);
  }

  void clearPriceFilter() {
    _selectedPriceRange.value = null;
    loadPlaces(refresh: true);
  }

  Future<void> filterByNearby() async {
    // Toggle off jika sudah aktif
    if (_selectedFilter.value == 'nearby') {
      _selectedFilter.value = '';
      _selectedLocation.value = null;
      await loadPlaces(refresh: true);
      return;
    }

    final locationService = Get.find<LocationService>();
    final position = await locationService.getCurrentPosition();
    if (position == null) return;

    Logger.debug(
        'Current Position: Lat ${position.latitude}, Lon ${position.longitude}',
        'ExploreController');
    _selectedFilter.value = 'nearby';
    _selectedLocation.value = [position.latitude, position.longitude];
    await loadPlaces(refresh: true);
  }

  void clearFilters() {
    _searchDebounce?.cancel();
    _selectedCategory.value = '';
    _searchQuery.value = '';
    _isSearching.value = false;
    _selectedRating.value = null;
    _selectedPriceRange.value = null;
    _selectedFilter.value = '';
    _selectedLocation.value = null;
    _selectedPlaceValues.clear();
    _selectedFoodTypes.clear();
    searchTextController.clear(); // Clear the search text field
    loadPlaces(refresh: true);
  }

  /// Clear only search query (for search bar X button)
  void clearSearch() {
    _searchDebounce?.cancel();
    _searchQuery.value = '';
    _isSearching.value = false;
    searchTextController.clear();
    _applyLocalSearch();
  }

  void loadMorePlaces() {
    if (!_isLoading.value && _hasMoreData.value) {
      loadPlaces();
    }
  }

  void selectPlace(PlaceModel? place) {
    _selectedPlace.value = place;
    _selectedImageUrls.value = place?.imageUrls
        ?.where((img) => img.url != null)
        .map((img) => img.url!)
        .toList();
  }

  Future<void> loadPlaceGamificationStatus(int placeId) async {
    _isLoadingPlaceStatus.value = true;
    try {
      final status =
          await gamificationRepository.getPlaceStatus(placeId: placeId);
      _placeStatus.value = status;
    } catch (e) {
      Logger.error('Error loading place status', e, null, 'ExploreController');
    } finally {
      _isLoadingPlaceStatus.value = false;
    }
  }

  Future<void> loadPlaceById(int placeId) async {
    _setLoading(true);
    _clearError();

    try {
      // Load place by ID from repository
      final place = await placeRepository.getPlaceById(placeId);
      selectPlace(place);

      // Also load reviews for this place
      await loadPlaceReviews(placeId);

      Logger.debug('Place loaded by ID: ${place.name}', 'ExploreController');
    } catch (e) {
      _setError(ErrorHandler.getReadableMessage(e, tag: 'ExploreController'));
    }

    _setLoading(false);
  }

  Future<void> refreshData() async {
    await Future.wait([
      loadPlaces(refresh: true),
      loadCategories(),
    ]);
  }

  // ===== REVIEW METHODS =====

  Future<void> loadPlaceReviews(int placeId) async {
    _isLoadingReviews.value = true;
    _clearError();

    try {
      // Load reviews from repository
      final reviewsList = await reviewRepository.getPlaceReviews(placeId);
      _reviews.assignAll(reviewsList);
      Logger.debug(
          'Reviews loaded: ${reviewsList.length}', 'ExploreController');
    } catch (e) {
      _setError(ErrorHandler.getReadableMessage(e, tag: 'ExploreController'));
    }

    _isLoadingReviews.value = false;
  }

  // Filter reviews by status
  void filterByStatus(String status) {
    // Mock implementation - in real app would filter reviews
    loadPlaceReviews(1); // Mock place ID
  }

  // Load more reviews data
  void loadMoreData() {
    if (!_isLoadingReviews.value && _hasMoreData.value) {
      // Mock load more implementation
    }
  }

  // Get review statistics
  Map<String, int> getReviewStats() {
    final total = _reviews.length;
    return {
      'total': total,
      'approved': (total * 0.8).round(),
      'pending': (total * 0.15).round(),
      'rejected': (total * 0.05).round(),
    };
  }

  // Get user review statistics
  Map<String, int> getUserReviewStats() {
    final userReviews = _userReviews.length;
    return {
      'total': userReviews,
      'approved': (userReviews * 0.9).round(),
    };
  }

  Future<void> createReview({
    required PlaceModel? place,
    required int vote,
    required String content,
    List<String>? imageUrls,
    Map<String, dynamic> additionalInfo = const {},
  }) async {
    _isCreatingReview.value = true;
    _clearError();

    try {
      // Create review via repository
      await reviewRepository.createReview(
        placeId: place!.id!,
        content: content,
        rating: vote,
        imageUrls: imageUrls,
        additionalInfo: additionalInfo,
      );

      // Show success and go back to place reviews list
      AppSnackbar.success(
        'Ulasan berhasil dikirim! Kamu mendapatkan ${place.expReward ?? 50} XP dan ${place.coinReward ?? 25} Koin',
        duration: const Duration(seconds: 3),
      );

      await loadPlaceReviews(place.id!);

      await Future.delayed(Duration(milliseconds: 100));
      Get.back(closeOverlays: true);
    } catch (e) {
      final msg = ErrorHandler.getReadableMessage(e, tag: 'ExploreController');
      _setError(msg);
      AppSnackbar.error(msg);
    }

    _isCreatingReview.value = false;
  }

  // ===== CHECKIN METHODS =====

  Future<void> createCheckin({
    required int placeId,
    required double latitude,
    required double longitude,
    Map<String, dynamic> additionalInfo = const {},
  }) async {
    _isCreatingCheckin.value = true;
    _clearError();

    try {
      // Create checkin via repository
      await checkinRepository.createCheckin(
        placeId: placeId,
        latitude: latitude,
        longitude: longitude,
        additionalInfo: additionalInfo,
      );

      AppSnackbar.success('Check-in created successfully! (API Mode)');
    } catch (e) {
      final msg = ErrorHandler.getReadableMessage(e, tag: 'ExploreController');
      _setError(msg);
      AppSnackbar.error(msg);
    }

    _isCreatingCheckin.value = false;
  }

  // ===== GALLERY METHODS =====

  /// Load checkins for gallery (Galeri Misi tab)
  Future<void> loadGalleryCheckins(int placeId) async {
    _isLoadingGalleryCheckins.value = true;
    _galleryCheckins.clear();

    try {
      final checkins = await checkinRepository.getCheckinsByPlaceId(placeId);
      _galleryCheckins.assignAll(checkins);
      Logger.debug(
          'Gallery checkins loaded: ${checkins.length}', 'ExploreController');
    } catch (e) {
      Logger.error(
          'Error loading gallery checkins', e, null, 'ExploreController');
      // Silent fail - gallery will show empty state
    }

    _isLoadingGalleryCheckins.value = false;
  }

  /// Load posts for gallery (Postingan Terkait tab)
  Future<void> loadGalleryPosts(int placeId) async {
    _isLoadingGalleryPosts.value = true;
    _galleryPosts.clear();

    try {
      final posts = await postRepository.getPostsByPlaceId(placeId);
      _galleryPosts.assignAll(posts);
      Logger.debug(
          'Gallery posts loaded: ${posts.length}', 'ExploreController');
    } catch (e) {
      Logger.error('Error loading gallery posts', e, null, 'ExploreController');
      // Silent fail - gallery will show empty state
    }

    _isLoadingGalleryPosts.value = false;
  }

  /// Get all image URLs from checkins (for Galeri Misi)
  List<String> get galleryCheckinImages {
    return _galleryCheckins
        .where((c) => c.imageUrl != null && c.imageUrl!.isNotEmpty)
        .map((c) => c.imageUrl!)
        .toList();
  }

  /// Get all image URLs from posts (for Postingan Terkait)
  List<String> get galleryPostImages {
    final images = <String>[];
    for (final post in _galleryPosts) {
      if (post.imageUrls != null && post.imageUrls!.isNotEmpty) {
        images.addAll(post.imageUrls!);
      }
    }
    return images;
  }

  // ===== FAVORITE/SAVED PLACES METHODS =====

  /// Load user's saved places from API
  Future<void> loadSavedPlaces() async {
    if (_isLoadingSavedPlaces.value) return;

    _isLoadingSavedPlaces.value = true;
    try {
      final userSaved = await userRepository.getUserSaved();
      // Extract IDs from SavedPlacePreview objects
      final placeIds = userSaved.savedPlaces
              ?.where((p) => p.id != null)
              .map((p) => p.id!)
              .toList() ??
          [];
      _savedPlaces.assignAll(placeIds);
      Logger.debug(
          'Loaded saved places: ${_savedPlaces.length}', 'ExploreController');
      Logger.debug(
          'Saved place IDs: ${_savedPlaces.join(", ")}', 'ExploreController');
    } catch (e) {
      Logger.error('Error loading saved places', e, null, 'ExploreController');
      // Silent fail - will show as not saved
    } finally {
      _isLoadingSavedPlaces.value = false;
    }
  }

  /// Check if a place is saved in user's favorites
  bool isPlaceSaved(int placeId) {
    return _savedPlaces.contains(placeId);
  }

  /// Toggle save/unsave a place from favorites
  Future<bool> toggleSavedPlace(int placeId) async {
    if (_isTogglingFavorite.value) return false;

    _isTogglingFavorite.value = true;

    try {
      // Check if already saved locally
      final isCurrentlySaved = _savedPlaces.contains(placeId);
      Logger.debug(
          'Toggling saved place: $placeId (currently saved: $isCurrentlySaved)',
          'ExploreController');

      if (isCurrentlySaved) {
        // Remove from local state first (optimistic)
        _savedPlaces.remove(placeId);
      } else {
        // Add to local state first (optimistic)
        _savedPlaces.add(placeId);
      }

      // Call toggle API - returns list of IDs directly
      final updatedPlaceIds =
          await userRepository.toggleSavedPlace(_savedPlaces);
      Logger.debug('Toggled saved place on server $updatedPlaceIds',
          'ExploreController');

      // Sync with server response
      _savedPlaces.assignAll(updatedPlaceIds);

      final isNowSaved = _savedPlaces.contains(placeId);
      Logger.debug('Place ${isNowSaved ? "saved" : "unsaved"}: $placeId',
          'ExploreController');
      return isNowSaved;
    } catch (e) {
      // Revert optimistic update on error - reload from server
      await loadSavedPlaces();
      Logger.error('Error toggling saved place', e, null, 'ExploreController');
      rethrow;
    } finally {
      _isTogglingFavorite.value = false;
    }
  }

  // ===== PRIVATE METHODS =====

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void _setError(String error) {
    _errorMessage.value = error;
  }

  void _clearError() {
    _errorMessage.value = '';
  }
}
