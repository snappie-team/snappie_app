import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/errors/auth_result.dart';
import 'package:snappie_app/app/core/services/auth_service.dart';
import 'package:snappie_app/app/core/services/google_auth_service.dart';
import 'package:snappie_app/app/data/models/user_model.dart';

// ============================================================================
// Mock Classes for Integration Testing - Use Case 1: Authentication
// ============================================================================

/// Mock implementation of AuthService for testing.
/// Allows configuration of different response scenarios.
class MockAuthService extends GetxService implements AuthService {
  // Configurable responses
  AuthResult? loginResult;
  bool registerResult = true;
  bool shouldThrowOnLogin = false;
  bool shouldThrowOnRegister = false;
  Exception? loginException;
  Exception? registerException;

  // Track method calls for verification
  int loginCallCount = 0;
  int registerCallCount = 0;
  Map<String, dynamic>? lastRegisterData;

  // Internal state
  final _isLoggedIn = false.obs;
  String? _token;
  String? _userEmail;
  UserModel? _userData;

  @override
  RxBool get isLoggedInObs => _isLoggedIn;

  @override
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  String? get token => _token;

  @override
  String? get userEmail => _userEmail;

  @override
  UserModel? get userData => _userData;

  @override
  bool get hasValidAccessToken => _token != null && _token!.isNotEmpty;

  @override
  bool get hasValidRefreshToken => true;

  // === Configurable Methods ===

  void configureLoginSuccess() {
    loginResult = AuthResult.ok(message: 'Login successful');
  }

  void configureLoginUserNotFound() {
    loginResult = AuthResult.fail(
      AuthErrorType.userNotFound,
      message: 'User not found',
      statusCode: 404,
    );
  }

  void configureLoginNetworkError() {
    loginResult = AuthResult.fail(
      AuthErrorType.network,
      message: 'Network error',
    );
  }

  void configureLoginActiveSession() {
    loginResult = AuthResult.fail(
      AuthErrorType.hasActiveSession,
      message: 'Has active session',
      statusCode: 409,
    );
  }

  void configureRegisterSuccess() {
    registerResult = true;
  }

  void configureRegisterFailure() {
    registerResult = false;
  }

  void configureLoginThrows(Exception exception) {
    shouldThrowOnLogin = true;
    loginException = exception;
  }

  void configureRegisterThrows(Exception exception) {
    shouldThrowOnRegister = true;
    registerException = exception;
  }

  void reset() {
    loginResult = null;
    registerResult = true;
    shouldThrowOnLogin = false;
    shouldThrowOnRegister = false;
    loginException = null;
    registerException = null;
    loginCallCount = 0;
    registerCallCount = 0;
    lastRegisterData = null;
    _isLoggedIn.value = false;
    _token = null;
    _userEmail = null;
    _userData = null;
  }

  // === AuthService Interface Implementation ===

  @override
  Future<AuthResult> login() async {
    loginCallCount++;

    if (shouldThrowOnLogin && loginException != null) {
      throw loginException!;
    }

    final result = loginResult ?? AuthResult.ok();

    if (result.success) {
      _isLoggedIn.value = true;
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = 'test@example.com';
    }

    return result;
  }

  @override
  Future<AuthResult> loginWithEmail(String email) async {
    loginCallCount++;
    _userEmail = email;
    return login();
  }

  @override
  Future<bool> registerUser({
    required String name,
    required String username,
    required String email,
    required String gender,
    required String imageUrl,
    required List<String> foodTypes,
    required List<String> placeValues,
  }) async {
    registerCallCount++;

    lastRegisterData = {
      'name': name,
      'username': username,
      'email': email,
      'gender': gender,
      'imageUrl': imageUrl,
      'foodTypes': foodTypes,
      'placeValues': placeValues,
    };

    if (shouldThrowOnRegister && registerException != null) {
      throw registerException!;
    }

    if (registerResult) {
      _isLoggedIn.value = true;
      _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      _userEmail = email;
      _userData = UserModel()
        ..name = name
        ..username = username
        ..email = email
        ..imageUrl = imageUrl;
    }

    return registerResult;
  }

  @override
  Future<void> logout() async {
    _isLoggedIn.value = false;
    _token = null;
    _userEmail = null;
    _userData = null;
  }

  @override
  Future<bool> refreshToken() async {
    return true;
  }

  @override
  Map<String, String> getAuthHeaders({bool useRegistrationKey = false}) {
    return {
      'Authorization': 'Bearer ${_token ?? 'mock_registration_key'}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<void> onInit() async {
    super.onInit();
  }
}

/// Mock implementation of GoogleAuthService for testing.
class MockGoogleAuthService extends GetxService implements GoogleAuthService {
  // Configurable responses
  bool shouldReturnUser = true;
  bool shouldThrowOnSignIn = false;
  Exception? signInException;
  String mockEmail = 'test@example.com';
  String mockDisplayName = 'Test User';

  // Track method calls
  int signInCallCount = 0;
  int signOutCallCount = 0;

  // Internal state
  final _isSigningIn = false.obs;
  MockUser? _mockUser;

  @override
  bool get isSigningIn => _isSigningIn.value;

  @override
  User? get currentUser => _mockUser;

  @override
  bool get isLoggedIn => _mockUser != null;

  // === Configurable Methods ===

  void configureSignInSuccess({String? email, String? displayName}) {
    shouldReturnUser = true;
    shouldThrowOnSignIn = false;
    mockEmail = email ?? 'test@example.com';
    mockDisplayName = displayName ?? 'Test User';
  }

  void configureSignInCancelled() {
    shouldReturnUser = false;
    shouldThrowOnSignIn = false;
  }

  void configureSignInThrows(Exception exception) {
    shouldThrowOnSignIn = true;
    signInException = exception;
  }

  void reset() {
    shouldReturnUser = true;
    shouldThrowOnSignIn = false;
    signInException = null;
    mockEmail = 'test@example.com';
    mockDisplayName = 'Test User';
    signInCallCount = 0;
    signOutCallCount = 0;
    _isSigningIn.value = false;
    _mockUser = null;
  }

  // === GoogleAuthService Interface Implementation ===

  @override
  Future<UserCredential?> signInWithGoogle() async {
    signInCallCount++;
    _isSigningIn.value = true;

    try {
      if (shouldThrowOnSignIn && signInException != null) {
        throw signInException!;
      }

      if (!shouldReturnUser) {
        return null;
      }

      _mockUser = MockUser(email: mockEmail, displayName: mockDisplayName);

      // Return a mock UserCredential
      return MockUserCredential(_mockUser!);
    } finally {
      _isSigningIn.value = false;
    }
  }

  @override
  Future<void> signOut() async {
    signOutCallCount++;
    _mockUser = null;
  }

  @override
  Future<void> disconnect() async {
    _mockUser = null;
  }

  @override
  User? getCurrentUser() {
    return _mockUser;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return 'mock_id_token';
  }

  @override
  bool isSignedInWithGoogle() {
    return _mockUser != null;
  }

  @override
  Map<String, dynamic>? getUserProfile() {
    if (_mockUser == null) return null;
    return {
      'uid': _mockUser!.uid,
      'email': _mockUser!.email,
      'displayName': _mockUser!.displayName,
      'photoURL': _mockUser!.photoURL,
    };
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(_mockUser);

  @override
  Stream<User?> get userChanges => Stream.value(_mockUser);
}

// ============================================================================
// Mock Firebase User Classes
// ============================================================================

/// Simplified mock User for testing purposes.
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;

  MockUser({
    String? uid,
    this.email,
    this.displayName,
    this.photoURL,
  }) : uid = uid ?? 'mock_uid_${DateTime.now().millisecondsSinceEpoch}';

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  UserMetadata get metadata => MockUserMetadata();

  @override
  String? get phoneNumber => null;

  @override
  List<UserInfo> get providerData => [
        MockUserInfo(providerId: 'google.com', email: email),
      ];

  @override
  String? get refreshToken => 'mock_refresh_token';

  @override
  String? get tenantId => null;

  @override
  Future<void> delete() async {}

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async =>
      'mock_id_token';

  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> linkWithProvider(AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithCredential(
          AuthCredential credential) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithProvider(
          AuthProvider provider) async =>
      throw UnimplementedError();

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification(
      [ActionCodeSettings? actionCodeSettings]) async {}

  @override
  Future<User> unlink(String providerId) async => this;

  @override
  Future<void> updateDisplayName(String? displayName) async {}

  Future<void> updateEmail(String newEmail) async {}

  @override
  Future<void> updatePassword(String newPassword) async {}

  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential phoneCredential) async {}

  @override
  Future<void> updatePhotoURL(String? photoURL) async {}

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {}

  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail,
      [ActionCodeSettings? actionCodeSettings]) async {}

  @override
  MultiFactor get multiFactor => throw UnimplementedError();

  @override
  Future<ConfirmationResult> linkWithPhoneNumber(String phoneNumber,
          [RecaptchaVerifier? verifier]) async =>
      throw UnimplementedError();

  @override
  Future<UserCredential> linkWithPopup(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<void> linkWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) =>
      throw UnimplementedError();

  @override
  Future<void> reauthenticateWithRedirect(AuthProvider provider) =>
      throw UnimplementedError();
}

class MockUserMetadata implements UserMetadata {
  @override
  DateTime? get creationTime => DateTime.now();

  @override
  DateTime? get lastSignInTime => DateTime.now();
}

class MockUserInfo implements UserInfo {
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? photoURL;
  @override
  final String providerId;
  @override
  final String? uid;

  MockUserInfo({
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoURL,
    required this.providerId,
    this.uid,
  });
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;

  @override
  final AdditionalUserInfo? additionalUserInfo = null;

  @override
  final AuthCredential? credential = null;

  MockUserCredential(this.user);
}
