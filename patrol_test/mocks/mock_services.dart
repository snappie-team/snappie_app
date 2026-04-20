import 'dart:io';

import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/errors/auth_result.dart';
import 'package:snappie_app/app/core/network/network_info.dart';
import 'package:snappie_app/app/core/services/auth_service.dart';
import 'package:snappie_app/app/core/services/cloudinary_service.dart';
import 'package:snappie_app/app/core/services/google_auth_service.dart';
import 'package:snappie_app/app/core/services/location_service.dart';
import 'package:snappie_app/app/core/services/onboarding_service.dart';
import 'package:snappie_app/app/data/models/user_model.dart';

import 'mock_data.dart';

class TestNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => Stream<bool>.value(true);
}

class TestAuthService extends AuthService {
  final bool _isLoggedIn;
  final RxBool _isLoggedInObs;
  final AuthResult _loginResult;
  final String? _registerError;

  TestAuthService({
    required bool isLoggedIn,
    required AuthResult loginResult,
    String? registerError,
  })  : _isLoggedIn = isLoggedIn,
        _isLoggedInObs = RxBool(isLoggedIn),
        _loginResult = loginResult,
        _registerError = registerError;

  @override
  Future<void> onInit() async {}

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  RxBool get isLoggedInObs => _isLoggedInObs;

  @override
  UserModel? get userData => MockData.testUser;

  @override
  String? get token => 'patrol-test-token';

  @override
  String? get userEmail => 'test@snappie.com';

  @override
  Future<AuthResult> login() async => _loginResult;

  @override
  Future<String?> registerUser({
    required String name,
    required String username,
    required String email,
    required String gender,
    required String imageUrl,
    required List<String> foodTypes,
    required List<String> placeValues,
  }) async =>
      _registerError;

  @override
  Future<bool> checkUsernameAvailability(String username) async => true;
}

class TestGoogleAuthService extends GoogleAuthService {
  @override
  Future<void> onInit() async {}

  @override
  bool get isLoggedIn => false;

  @override
  Future<UserCredential?> signInWithGoogle() async => null;

  @override
  Future<void> signOut() async {}
}

class TestLocationService extends LocationService {
  @override
  Future<void> onInit() async {}

  @override
  Future<Position?> getCurrentPosition({
    bool showSnackbars = true,
    LocationAccuracy accuracy = LocationAccuracy.medium,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    return Position(
      longitude: 106.84513,
      latitude: -6.21462,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 10,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 1,
      headingAccuracy: 1,
    );
  }
}

class TestCloudinaryService implements CloudinaryService {
  @override
  Cloudinary get cloudinary => Cloudinary.fromStringUrl(
        'cloudinary://test_key:test_secret@test_cloud',
      );

  Future<CloudinaryUploadResult> _successResult(File file) async {
    return CloudinaryUploadResult(
      publicId: 'patrol_test_image',
      url: 'http://example.com/patrol_test_image.jpg',
      secureUrl: 'https://example.com/patrol_test_image.jpg',
      width: 100,
      height: 100,
      format: 'jpg',
      bytes: await file.length(),
      success: true,
    );
  }

  @override
  Future<CloudinaryUploadResult> uploadImage(
    File file, {
    String folder = CloudinaryFolder.checkins,
    UploadProgressCallback? progressCallback,
    int quality = 85,
  }) async {
    if (!await file.exists()) {
      return CloudinaryUploadResult.error('File tidak ditemukan');
    }
    return _successResult(file);
  }

  @override
  Future<CloudinaryUploadResult> uploadCheckinImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) async =>
      uploadImage(file,
          folder: CloudinaryFolder.checkins,
          progressCallback: progressCallback,
          quality: 85);

  @override
  Future<CloudinaryUploadResult> uploadReviewImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) async =>
      uploadImage(file,
          folder: CloudinaryFolder.reviews,
          progressCallback: progressCallback,
          quality: 85);

  @override
  Future<CloudinaryUploadResult> uploadProfileImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) async =>
      uploadImage(file,
          folder: CloudinaryFolder.profiles,
          progressCallback: progressCallback,
          quality: 90);

  @override
  Future<CloudinaryUploadResult> uploadPostImage(
    File file, {
    UploadProgressCallback? progressCallback,
  }) async =>
      uploadImage(file,
          folder: CloudinaryFolder.posts,
          progressCallback: progressCallback,
          quality: 85);
}

class TestOnboardingService extends OnboardingService {
  @override
  bool get isNewRegistration => false;

  @override
  Future<bool> hasSeenTabTour() async => true;

  @override
  Future<void> markTabTourSeen() async {}

  @override
  void clearNewRegistration() {}
}

late NetworkInfo mockNetworkInfo;
late AuthService mockAuthService;
late GoogleAuthService mockGoogleAuthService;
late LocationService mockLocationService;
late CloudinaryService mockCloudinaryService;
late OnboardingService mockOnboardingService;

void registerMockCoreServices({
  bool isLoggedIn = true,
  AuthResult? loginResult,
  String? registerError,
}) {
  mockNetworkInfo = TestNetworkInfo();

  mockAuthService = TestAuthService(
    isLoggedIn: isLoggedIn,
    loginResult: loginResult ?? AuthResult.ok(),
    registerError: registerError,
  );

  mockGoogleAuthService = TestGoogleAuthService();

  mockLocationService = TestLocationService();

      mockCloudinaryService = TestCloudinaryService();

  mockOnboardingService = TestOnboardingService();

  Get.put<NetworkInfo>(mockNetworkInfo, permanent: true);
  Get.put<AuthService>(mockAuthService, permanent: true);
  Get.put<GoogleAuthService>(mockGoogleAuthService, permanent: true);
  Get.put<LocationService>(mockLocationService, permanent: true);
  Get.put<CloudinaryService>(mockCloudinaryService, permanent: true);
  Get.put<OnboardingService>(mockOnboardingService, permanent: true);
}
