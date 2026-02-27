import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../data/models/articles_model.dart';
import '../../../data/repositories/articles_repository_impl.dart';

class ArticlesController extends GetxController {
  final ArticlesRepository articlesRepository;
  
  ArticlesController({ArticlesRepository? articlesRepository})
      : articlesRepository =
            articlesRepository ?? Get.find<ArticlesRepository>();

  final _allArticles = <ArticlesModel>[].obs; // Original list
  final _filteredArticles = <ArticlesModel>[].obs; // Filtered list for display
  final _categories = <String>[].obs;
  final _selectedCategory = ''.obs;
  final _searchQuery = ''.obs;
  final _isLoading = false.obs;
  final _isSearching = false.obs;
  final _isInitialized = false.obs;
  
  Timer? _debounceTimer;
  
  // Search text controller
  final searchTextController = TextEditingController();

  List<ArticlesModel> get articles => _filteredArticles;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory.value;
  String get searchQuery => _searchQuery.value;
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;

  @override
  void onInit() {
    super.onInit();
    Logger.debug('ArticlesController created (not initialized yet)', 'ArticlesController');
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
  
  /// Initialize data hanya saat tab pertama kali dibuka
  void initializeIfNeeded() {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
      Logger.debug('ArticlesController initializing...', 'ArticlesController');
      loadArticles();
      loadCategories();
    }
  }

  Future<void> loadArticles() async {
    _setLoading(true);
    
    try {
      final articles = await articlesRepository.getArticles();
      _allArticles.value = articles;
      _applyFilters(); // Apply any existing filters
      Logger.debug('Loaded ${articles.length} articles', 'ArticlesController');
    } catch (e) {
      // Handle error silently
      Logger.error('Error loading articles', e, null, 'ArticlesController');
      _allArticles.clear();
      _filteredArticles.clear();
    }
    
    _setLoading(false);
  }

  Future<void> loadCategories() async {
    try {
      // Always use API now instead of mock data
      // TODO: Load real categories from API when endpoints are ready
      _categories.clear();
      
      // For now, show empty state until API endpoints are implemented
    } catch (e) {
      // Handle error silently
      Logger.error('Error loading categories', e, null, 'ArticlesController');
    }
  }

  void filterByCategory(String category) {
    _selectedCategory.value = category;
    _applyFilters();
  }

  void searchArticles(String query) {
    _searchQuery.value = query;
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Show searching state immediately if query is not empty
    if (query.isNotEmpty) {
      _isSearching.value = true;
    }
    
    // Debounce the actual filter
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
      _isSearching.value = false;
    });
  }

  /// Apply search and category filters to articles
  void _applyFilters() {
    List<ArticlesModel> result = List.from(_allArticles);

    // Apply search filter
    if (_searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      result = result.where((article) {
        final title = article.title?.toLowerCase() ?? '';
        final description = article.description?.toLowerCase() ?? '';
        final author = article.author?.toLowerCase() ?? '';
        final category = article.category?.toLowerCase() ?? '';
        
        return title.contains(query) ||
            description.contains(query) ||
            author.contains(query) ||
            category.contains(query);
      }).toList();
    }

    // Apply category filter
    if (_selectedCategory.value.isNotEmpty) {
      result = result.where((article) {
        return article.category?.toLowerCase() == _selectedCategory.value.toLowerCase();
      }).toList();
    }

    _filteredArticles.value = result;
    Logger.debug('Filtered articles: ${result.length} of ${_allArticles.length}', 'ArticlesController');
  }

  void clearFilters() {
    _debounceTimer?.cancel();
    _selectedCategory.value = '';
    _searchQuery.value = '';
    _isSearching.value = false;
    searchTextController.clear(); // Clear the text field
    _applyFilters();
  }

  Future<void> refreshData() async {
    await loadArticles();
  }

  void bookmarkArticle(int articleId) {
    // TODO: Implement bookmark functionality
    AppSnackbar.info('Article bookmarked successfully!', title: 'Bookmarked');
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }
}
