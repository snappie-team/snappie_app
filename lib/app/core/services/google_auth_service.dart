import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'logger_service.dart';

class GoogleAuthService extends GetxService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Observable untuk status login
  final _isSigningIn = false.obs;
  final _currentUser = Rxn<User>();

  // Getters
  bool get isSigningIn => _isSigningIn.value;
  User? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser.value = user;
    });
  }

  /// Sign in dengan Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isSigningIn.value = true;
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (kDebugMode) {
          Logger.debug('Google Sign In canceled by user', 'GoogleAuthService');
        }
        return null;
      }

      if (kDebugMode) {
        Logger.debug('Google user selected: ${googleUser.email}', 'GoogleAuthService');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (kDebugMode) {
        Logger.debug('Google authentication tokens obtained', 'GoogleAuthService');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (kDebugMode) {
        Logger.debug('Firebase sign in successful: ${userCredential.user?.email}', 'GoogleAuthService');
        Logger.debug('User display name: ${userCredential.user?.displayName}', 'GoogleAuthService');
        Logger.debug('User photo URL: ${userCredential.user?.photoURL}', 'GoogleAuthService');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        Logger.error('Google Sign In error', e, null, 'GoogleAuthService');
      }
      rethrow;
    } finally {
      _isSigningIn.value = false;
    }
  }

  /// Sign out dari Google dan Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      
      if (kDebugMode) {
        Logger.debug('Sign out successful', 'GoogleAuthService');
      }
    } catch (e) {
      if (kDebugMode) {
        Logger.error('Sign out error', e, null, 'GoogleAuthService');
      }
      rethrow;
    }
  }

  /// Disconnect Google account (revoke access)
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Get current Firebase user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Get Firebase ID Token
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is signed in with Google
  bool isSignedInWithGoogle() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.providerData.any((info) => info.providerId == 'google.com');
    }
    return false;
  }

  /// Get user profile data
  Map<String, dynamic>? getUserProfile() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'emailVerified': user.emailVerified,
        'isAnonymous': user.isAnonymous,
        'creationTime': user.metadata.creationTime?.toIso8601String(),
        'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
      };
    }
    return null;
  }

  /// Stream untuk mendengarkan perubahan auth state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Stream untuk mendengarkan perubahan user
  Stream<User?> get userChanges => _firebaseAuth.userChanges();
}