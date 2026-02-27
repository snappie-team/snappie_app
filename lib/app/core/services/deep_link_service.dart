import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/services/logger_service.dart';
import 'package:snappie_app/app/core/helpers/app_snackbar.dart';
import 'package:snappie_app/app/data/repositories/place_repository_impl.dart';
import 'package:snappie_app/app/data/repositories/user_repository_impl.dart';
import 'package:snappie_app/app/routes/app_pages.dart';

/// Deep Link & App Links handler.
///
/// Supports two schemes:
///   - Custom scheme:  `snappie://place/123`, `snappie://u/johndoe`, `snappie://post/42`
///   - HTTPS App Link: `https://snappie-team.github.io/place/123`, etc.
///
/// Initialised once in [main.dart] after auth is resolved.
class DeepLinkService {
  static const String _tag = 'DeepLinkService';
  static const String webHost = 'snappie-team.github.io';
  static const String customScheme = 'snappie';

  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _subscription;

  /// Call once after [GetMaterialApp] is running (e.g. in [MainApp.initState]).
  static Future<void> init() async {
    // --- Handle link that opened / cold-started the app ---
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        Logger.info('Initial deep link: $initialUri', _tag);
        // Slight delay so GetX navigation stack is ready
        await Future.delayed(const Duration(milliseconds: 500));
        _handleUri(initialUri);
      }
    } catch (e) {
      Logger.error('Error reading initial link', e, null, _tag);
    }

    // --- Listen for links while app is already running ---
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) {
        Logger.info('Incoming deep link: $uri', _tag);
        _handleUri(uri);
      },
      onError: (err) {
        Logger.error('Deep link stream error', err, null, _tag);
      },
    );
  }

  /// Clean up when app shuts down (optional, defensive).
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ─── URL → Route mapping ─────────────────────────────────

  static void _handleUri(Uri uri) {
    // Normalise: treat both `snappie://place/123` and
    // `https://snappie-team.github.io/place/123` the same way.
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      Logger.debug('Deep link has no path segments: $uri', _tag);
      return;
    }

    final first = pathSegments[0];
    final second = pathSegments.length > 1 ? pathSegments[1] : null;

    switch (first) {
      // ── Place Detail ────────────────────────────
      case 'place':
        if (second != null) {
          _navigateToPlace(second);
        }
        break;

      // ── Post Detail ─────────────────────────────
      case 'post':
        if (second != null) {
          _navigateToPost(second);
        }
        break;

      // ── User Profile ────────────────────────────
      case 'u':
        if (second != null) {
          _navigateToProfile(second);
        }
        break;

      default:
        Logger.debug('Unknown deep link path: $uri', _tag);
    }
  }

  // ─── Navigation helpers ───────────────────────────────────

  static Future<void> _navigateToPlace(String idString) async {
    final placeId = int.tryParse(idString);
    if (placeId == null) {
      AppSnackbar.error('Link tempat tidak valid');
      return;
    }

    try {
      final placeRepo = Get.find<PlaceRepository>();
      final place = await placeRepo.getPlaceById(placeId);
      Get.toNamed(AppPages.PLACE_DETAIL, arguments: place);
    } catch (e) {
      Logger.error('Failed to open place from deep link', e, null, _tag);
      AppSnackbar.error('Gagal memuat tempat');
    }
  }

  static void _navigateToPost(String idString) {
    final postId = int.tryParse(idString);
    if (postId == null) {
      AppSnackbar.error('Link postingan tidak valid');
      return;
    }

    Get.toNamed(AppPages.POST_DETAIL, arguments: {'postId': postId});
  }

  static Future<void> _navigateToProfile(String username) async {
    try {
      final userRepo = Get.find<UserRepository>();
      final result = await userRepo.searchUsers(username, perPage: 1);
      final match = result.users?.firstWhereOrNull(
        (u) => u.username?.toLowerCase() == username.toLowerCase(),
      );

      if (match?.id != null) {
        Get.toNamed(AppPages.USER_PROFILE, arguments: {'userId': match!.id});
      } else {
        AppSnackbar.error('Pengguna "$username" tidak ditemukan');
      }
    } catch (e) {
      Logger.error('Failed to open profile from deep link', e, null, _tag);
      AppSnackbar.error('Gagal memuat profil');
    }
  }

  // ─── Helper: generate shareable deep link URLs ────────────

  /// Returns an HTTPS App-Link URL for the given path.
  /// E.g. `DeepLinkService.url('/place/42')` → `https://snappie-team.github.io/place/42`
  static String url(String path) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return 'https://$webHost/$cleanPath';
  }

  /// Convenience getters
  static String placeUrl(int placeId) => url('place/$placeId');
  static String postUrl(int postId) => url('post/$postId');
  static String profileUrl(String username) => url('u/$username');
}
