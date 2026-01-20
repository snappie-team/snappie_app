import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/food_type.dart';
import 'package:snappie_app/app/core/constants/place_value.dart';
import 'package:snappie_app/app/core/services/google_auth_service.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/routes/app_pages.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/constants/remote_assets.dart';
import '../../../core/errors/auth_result.dart';
import '../../../core/services/app_update_service.dart';

enum Gender { male, female, others }

class AuthController extends GetxController {
  final AuthService authService;
  final GoogleAuthService googleAuthService;

  AuthController({required this.authService, required this.googleAuthService});

  // Login form controllers
  final TextEditingController emailController = TextEditingController();

  // Register form controllers
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();

  final _isLoading = false.obs;
  final _selectedPageIndex = 0.obs;
  final _isLoggedIn = false.obs;
  final _googleUserName = ''.obs;
  final _googleUserEmail = ''.obs;
  final _agreedToTerms = false.obs;
  final _selectedGender = ''.obs;
  final _selectedAvatar = ''.obs;
  final _showAvatarPicker = false.obs;
  final _selectedFoodTypes = <String>[].obs;
  final _selectedPlaceValues = <String>[].obs;

  // Form validation observables
  final _isFirstnameValid = false.obs;
  final _isLastnameValid = false.obs;
  final _isUsernameValid = false.obs;

  List<String> get foodTypes => FoodTypeExtension.allLabels;
  List<String> get placeValues => PlaceValueExtension.allLabels;

  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get googleUserName => _googleUserName.value;
  String get googleUserEmail => _googleUserEmail.value;
  RxBool get agreedToTerms => _agreedToTerms;
  RxString get selectedGender => _selectedGender;
  Gender get selectedGenderEnum {
    if (_selectedGender.value.toLowerCase() == 'male') {
      return Gender.male;
    } else if (_selectedGender.value.toLowerCase() == 'female') {
      return Gender.female;
    }
    return Gender.others;
  }

  RxString get selectedAvatar => _selectedAvatar;
  RxBool get showAvatarPicker => _showAvatarPicker;
  int get selectedPageIndex => _selectedPageIndex.value;
  RxList<String> get selectedFoodTypes => _selectedFoodTypes;
  RxList<String> get selectedPlaceValues => _selectedPlaceValues;

  // Form validation getters
  RxBool get isFirstnameValid => _isFirstnameValid;
  RxBool get isLastnameValid => _isLastnameValid;
  RxBool get isUsernameValid => _isUsernameValid;

  // Keep controller alive during auth flow
  @override
  bool get isClosed => false;

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in
    _isLoggedIn.value = authService.isLoggedIn;
    _loadGoogleUserData();

    // Add listeners for form validation
    firstnameController.addListener(() {
      _isFirstnameValid.value = firstnameController.text.trim().isNotEmpty;
    });

    lastnameController.addListener(() {
      _isLastnameValid.value = lastnameController.text.trim().isNotEmpty;
    });

    usernameController.addListener(() {
      final username = usernameController.text.trim();
      _isUsernameValid.value = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*._-])[A-Za-z\d!@#$%^&*._-]{8,}$',
      ).hasMatch(username);
    });
  }

  @override
  void onReady() {
    super.onReady();
    try {
      final updater = Get.find<AppUpdateService>();
      updater.checkAndPrompt();
    } catch (_) {}
  }

  @override
  void onClose() {
    // Clear content but don't dispose - controller is reused in auth flow
    emailController.clear();
    firstnameController.clear();
    lastnameController.clear();
    usernameController.clear();
    registerEmailController.clear();
    super.onClose();
  }

  void _showSnackbar(String title, String message, Color backgroundColor) {
    // Check if overlay is available before showing snackbar
    try {
      if (Get.overlayContext != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: backgroundColor,
          colorText: Colors.white,
        );
      } else {
        // If no overlay available, schedule it for next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.overlayContext != null) {
            Get.snackbar(
              title,
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: backgroundColor,
              colorText: Colors.white,
            );
          } else {
            Logger.warning(
                'Cannot show snackbar: $title - $message', 'AuthController');
          }
        });
      }
    } catch (e) {
      Logger.error('Error showing snackbar', e, null, 'AuthController');
    }
  }

  void _loadGoogleUserData() {
    try {
      // Get user data from Google Auth Service
      final user = googleAuthService.currentUser;
      if (user != null) {
        _googleUserEmail.value = user.email ?? '';

        if (user.email != null && user.email!.isNotEmpty) {
          registerEmailController.text = user.email!;
        }
      }
    } catch (e) {
      Logger.error('Error loading Google user data', e, null, 'AuthController');
      _showSnackbar(
        'Error',
        'Google Sign In failed. Please try again.',
        Colors.red,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    _setLoading(true);

    try {
      final result = await authService.login();

      if (result.success) {
        _isLoggedIn.value = true;

        _showSnackbar(
          'Success',
          'Google Sign In successful. wait a minute sir',
          Colors.green,
        );

        // Navigate to main app
        Get.offAllNamed(AppPages.MAIN);

        _setLoading(false);
        return;
      }

      switch (result.errorType ?? AuthErrorType.unknown) {
        case AuthErrorType.userNotFound:
          Logger.debug(
              'User not found, navigating to registration', 'AuthController');
          _loadGoogleUserData();
          Get.toNamed(AppPages.REGISTER);
          break;
        case AuthErrorType.hasActiveSession:
          _showSnackbar(
            'Session Active',
            result.message ?? 'Masih ada sesi aktif. Silakan coba lagi.',
            Colors.orange,
          );
          break;
        case AuthErrorType.network:
          _showSnackbar(
            'Network Error',
            'Please check your connection and try again.',
            Colors.red,
          );
          break;
        case AuthErrorType.unknown:
          _showSnackbar(
            'Error',
            result.message ?? 'Google Sign In failed. Please try again.',
            Colors.red,
          );
          break;
      }
    } catch (e) {
      _showSnackbar(
        'Error',
        'Network error: Please check your connection and try again.',
        Colors.red,
      );
    }

    _setLoading(false);
  }

  Future<void> signUpWithGoogle() async {
    _setLoading(true);

    try {
      final result = await authService.login();

      if (result.success) {
        _isLoggedIn.value = true;

        _showSnackbar(
          'Success',
          'User already created.',
          Colors.green,
        );

        // Navigate to main app
        Get.offAllNamed(AppPages.MAIN);

        _setLoading(false);
        return;
      }

      if (result.errorType == AuthErrorType.userNotFound) {
        _loadGoogleUserData();
        Get.toNamed(AppPages.REGISTER);
      } else if (result.errorType == AuthErrorType.hasActiveSession) {
        _showSnackbar(
          'Session Active',
          result.message ?? 'Masih ada sesi aktif. Silakan coba lagi.',
          Colors.orange,
        );
      } else if (result.errorType == AuthErrorType.network) {
        _showSnackbar(
          'Network Error',
          'Please check your connection and try again.',
          Colors.red,
        );
      } else {
        _showSnackbar(
          'Error',
          result.message ?? 'Google Sign In failed. Please try again.',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackbar(
        'Error',
        'Network error: Please check your connection and try again.',
        Colors.red,
      );
    }

    _setLoading(false);
  }

  // ========== REGISTRATION METHODS ==========

  Future<void> register() async {
    if (!_validateForm()) {
      return;
    }

    _setLoading(true);

    // Show info snackbar
    _showSnackbar(
      'Processing',
      'Mendaftarkan akun Anda, mohon tunggu...',
      Colors.blue,
    );

    try {
      final success = await authService.registerUser(
        name:
            '${firstnameController.text.trim()} ${lastnameController.text.trim()}',
        username: usernameController.text.trim(),
        email: registerEmailController.text.trim(),
        gender: _selectedGender.value,
        imageUrl: _selectedAvatar.value,
        foodTypes: _selectedFoodTypes.toList(),
        placeValues: _selectedPlaceValues.toList(),
      );

      if (success) {
        // Set loading false before navigation
        _setLoading(false);

        _showSnackbar(
          'Berhasil',
          'Registrasi berhasil! Selamat datang di Snappie',
          Colors.green,
        );

        // Small delay before navigation to ensure everything is ready
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to home (main app layout)
        Get.offAllNamed(AppPages.MAIN);

        return; // Exit early to avoid setting loading again
      } else {
        _showSnackbar(
          'Gagal',
          'Registrasi gagal. Silakan coba lagi.',
          Colors.red,
        );
      }
    } catch (e, stackTrace) {
      Logger.error('Registration error', e, stackTrace, 'AuthController');
      _showSnackbar(
        'Error',
        'Server membutuhkan waktu lama atau koneksi bermasalah. Silakan coba lagi.',
        Colors.red,
      );
    }

    _setLoading(false);
  }

  bool _validateForm() {
    if (firstnameController.text.trim().isEmpty ||
        lastnameController.text.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Please enter your full name',
        Colors.red,
      );
      return false;
    }

    if (usernameController.text.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Please enter a username',
        Colors.red,
      );
      return false;
    }

    if (registerEmailController.text.trim().isEmpty) {
      _showSnackbar(
        'Error',
        'Email is required',
        Colors.red,
      );
      return false;
    }

    // Basic username validation
    final username = usernameController.text.trim();
    if (username.length < 8) {
      _showSnackbar(
        'Error',
        'Username must be at least 8 characters long',
        Colors.red,
      );
      return false;
    }

    final usernamePattern = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*._-])[A-Za-z\d!@#$%^&*._-]{8,}$',
    );
    if (!usernamePattern.hasMatch(username)) {
      _showSnackbar(
        'Error',
        'Username must contain letters, numbers, and special characters',
        Colors.red,
      );
      return false;
    }

    // Validate gender
    if (_selectedGender.value.isEmpty) {
      _showSnackbar(
        'Error',
        'Please select your gender',
        Colors.red,
      );
      return false;
    }

    // Validate avatar
    if (_selectedAvatar.value.isEmpty) {
      _showSnackbar(
        'Error',
        'Please select an avatar',
        Colors.red,
      );
      return false;
    }

    // Validate food types (minimum 3)
    if (_selectedFoodTypes.length < 3) {
      _showSnackbar(
        'Error',
        'Please select at least 3 food types',
        Colors.red,
      );
      return false;
    }

    // Validate place values (minimum 3)
    if (_selectedPlaceValues.length < 3) {
      _showSnackbar(
        'Error',
        'Please select at least 3 place values',
        Colors.red,
      );
      return false;
    }

    return true;
  }

  void cancelRegistration() {
    // Sign out from Google and return to login
    googleAuthService.signOut();
    Get.toNamed(AppPages.LOGIN);

    _showSnackbar(
      'Cancelled',
      'Registration cancelled',
      Colors.orange,
    );
  }

  // ========== SHARED METHODS ==========

  void skipLogin() {
    // For development - skip authentication
    _isLoggedIn.value = true;
    _showSnackbar(
      'Development Mode',
      'Login skipped for development',
      Colors.orange,
    );

    // Navigate to main app
    Get.offAllNamed(AppPages.MAIN);
  }

  void logout() {
    authService.logout();
    _isLoggedIn.value = false;
    emailController.clear();

    _showSnackbar(
      'Logged Out',
      'You have been logged out',
      Colors.blue,
    );

    // Navigate back to login
    Get.toNamed(AppPages.LOGIN);
  }

  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setGender(Gender gender) {
    _selectedGender.value = gender.toString().split('.').last;
    Logger.debug('Gender selected: $gender', 'AuthController');
  }

  void setAvatar(String avatar) {
    _selectedAvatar.value = avatar;
    Logger.debug('Avatar selected: $avatar', 'AuthController');
  }

  void toggleAvatarPicker() {
    _showAvatarPicker.value = !_showAvatarPicker.value;
    Logger.debug(
        'Avatar picker toggled: ${_showAvatarPicker.value}', 'AuthController');
  }

  void nextPage() {
    if (_selectedPageIndex.value < 2) {
      _selectedPageIndex.value++;
      Logger.debug(
          'Moving to page: ${_selectedPageIndex.value}', 'AuthController');
    }
  }

  void previousPage() {
    if (_selectedPageIndex.value > 0) {
      _selectedPageIndex.value--;
      Logger.debug(
          'Moving to page: ${_selectedPageIndex.value}', 'AuthController');
    }
  }

  void goToPage(int index) {
    if (index >= 0 && index <= 2) {
      _selectedPageIndex.value = index;
      Logger.debug(
          'Going to page: ${_selectedPageIndex.value}', 'AuthController');
    }
  }

  void toggleFoodTypeSelection(String foodType) {
    if (_selectedFoodTypes.contains(foodType)) {
      _selectedFoodTypes.remove(foodType);
      Logger.debug('Food type removed: $foodType', 'AuthController');
    } else {
      _selectedFoodTypes.add(foodType);
      Logger.debug('Food type selected: $foodType', 'AuthController');
    }
    Logger.debug(
        'Total selected: ${_selectedFoodTypes.length} - ${_selectedFoodTypes.join(", ")}',
        'AuthController');
  }

  void togglePlaceValueSelection(String placeValue) {
    if (_selectedPlaceValues.contains(placeValue)) {
      _selectedPlaceValues.remove(placeValue);
      Logger.debug('Place value removed: $placeValue', 'AuthController');
    } else {
      _selectedPlaceValues.add(placeValue);
      Logger.debug('Place value selected: $placeValue', 'AuthController');
    }
    Logger.debug(
        'Total selected: ${_selectedPlaceValues.length} - ${_selectedPlaceValues.join(", ")}',
        'AuthController');
  }

  List<Map<String, dynamic>> getAvatarOptions(String gender) {
    if (gender.toLowerCase() == 'male') {
      return [
        {
          'path': RemoteAssets.avatar('avatar_m1_hdpi.png'),
          'localPath': RemoteAssets.localAvatar('avatar_m1_hdpi.png'),
          'color': Colors.blue
        },
        {
          'path': RemoteAssets.avatar('avatar_m2_hdpi.png'),
          'localPath': RemoteAssets.localAvatar('avatar_m2_hdpi.png'),
          'color': Colors.green
        },
        {
          'path': RemoteAssets.avatar('avatar_m3_hdpi.png'),
          'localPath': RemoteAssets.localAvatar('avatar_m3_hdpi.png'),
          'color': Colors.orange
        },
        {
          'path': RemoteAssets.avatar('avatar_m4_hdpi.png'),
          'localPath': RemoteAssets.localAvatar('avatar_m4_hdpi.png'),
          'color': Colors.grey
        },
      ];
    }
    return [
      {
        'path': RemoteAssets.avatar('avatar_f1_hdpi.png'),
        'localPath': RemoteAssets.localAvatar('avatar_f1_hdpi.png'),
        'color': Colors.orange
      },
      {
        'path': RemoteAssets.avatar('avatar_f2_hdpi.png'),
        'localPath': RemoteAssets.localAvatar('avatar_f2_hdpi.png'),
        'color': Colors.yellow
      },
      {
        'path': RemoteAssets.avatar('avatar_f3_hdpi.png'),
        'localPath': RemoteAssets.localAvatar('avatar_f3_hdpi.png'),
        'color': Colors.green
      },
      {
        'path': RemoteAssets.avatar('avatar_f4_hdpi.png'),
        'localPath': RemoteAssets.localAvatar('avatar_f4_hdpi.png'),
        'color': Colors.pink
      },
    ];
  }
}
