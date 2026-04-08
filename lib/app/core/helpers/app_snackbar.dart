import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// Centralized snackbar helper for consistent messaging across the app.
///
/// Usage:
/// ```dart
/// AppSnackbar.success('Profil diperbarui');
/// AppSnackbar.error('Gagal menghapus post');
/// AppSnackbar.warning('Aktifkan layanan lokasi');
/// AppSnackbar.info('Mendapatkan posisi Anda...');
/// ```
class AppSnackbar {
  AppSnackbar._();

  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _retryDelay = Duration(milliseconds: 80);
  static const int _maxOverlayRetries = 5;
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static bool _isMessengerReady() {
    final state = messengerKey.currentState;
    final context = messengerKey.currentContext;
    return state != null && context != null;
  }

  static void _runSafely(
    VoidCallback showAction, {
    int attempt = 0,
  }) {
    if (!_isMessengerReady()) {
      if (attempt < _maxOverlayRetries) {
        Future<void>.delayed(_retryDelay, () {
          _runSafely(showAction, attempt: attempt + 1);
        });
        return;
      }

      debugPrint(
          'AppSnackbar: ScaffoldMessenger belum tersedia, snackbar dilewati.');
      return;
    }

    try {
      showAction();
    } catch (e) {
      if (attempt < _maxOverlayRetries) {
        Future<void>.delayed(_retryDelay, () {
          _runSafely(showAction, attempt: attempt + 1);
        });
        return;
      }

      debugPrint('AppSnackbar: gagal menampilkan snackbar: $e');
    }
  }

  static void _showMaterialSnackBar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Widget icon,
    required Duration duration,
    required SnackPosition position,
    TextButton? mainButton,
    bool showProgressIndicator = false,
    Color textColor = Colors.white,
  }) {
    final messengerState = messengerKey.currentState;
    final context = messengerKey.currentContext;

    if (messengerState == null || context == null) {
      return;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    final screenHeight = mediaQuery?.size.height ?? 812;
    final topInset = mediaQuery?.padding.top ?? 0;

    final margin = position == SnackPosition.TOP
        ? EdgeInsets.fromLTRB(12, topInset + 8, 12, screenHeight - 140)
        : const EdgeInsets.all(12);

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
        if (showProgressIndicator) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          ),
        ],
      ],
    );

    messengerState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: content,
          duration: duration,
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: margin,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: mainButton != null
              ? SnackBarAction(
                  label: (mainButton.child is Text)
                      ? ((mainButton.child as Text).data ?? 'OK')
                      : 'OK',
                  textColor: textColor,
                  onPressed: mainButton.onPressed ?? () {},
                )
              : null,
        ),
      );
  }

  // ─── Success ───────────────────────────────────────────────

  /// Show a success snackbar (green accent).
  static void success(
    String message, {
    String title = 'Berhasil',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration? duration,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        position: position,
        backgroundColor: AppColors.success,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
      );
    });
  }

  // ─── Error ─────────────────────────────────────────────────

  /// Show an error snackbar (red accent).
  static void error(
    String message, {
    String title = 'Gagal',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration? duration,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        position: position,
        backgroundColor: AppColors.error,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
      );
    });
  }

  // ─── Warning ───────────────────────────────────────────────

  /// Show a warning snackbar (amber/orange accent).
  static void warning(
    String message, {
    String title = 'Perhatian',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration? duration,
    TextButton? mainButton,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        position: position,
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        mainButton: mainButton,
      );
    });
  }

  // ─── Info ──────────────────────────────────────────────────

  /// Show an informational snackbar (primary color / neutral).
  static void info(
    String message, {
    String title = 'Info',
    SnackPosition position = SnackPosition.BOTTOM,
    Duration? duration,
    bool showProgressIndicator = false,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        position: position,
        backgroundColor: AppColors.primary.withValues(alpha: 0.95),
        icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        showProgressIndicator: showProgressIndicator,
      );
    });
  }

  // ─── Custom / Gamification ─────────────────────────────────

  /// Show a challenge-completed snackbar (special styling).
  static void challengeCompleted(
    String challengeName, {
    String? rewardText,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: 'Challenge Selesai!',
        message: '$challengeName - ${rewardText ?? "Tantangan selesai!"}',
        position: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withValues(alpha: 0.95),
        icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
        duration: const Duration(seconds: 4),
      );
    });
  }

  // ─── Generic ───────────────────────────────────────────────

  /// Show a fully custom snackbar for edge cases not covered by
  /// the convenience methods above.
  static void show({
    required String title,
    required String message,
    SnackPosition position = SnackPosition.BOTTOM,
    Color? backgroundColor,
    Color? colorText,
    Widget? icon,
    TextButton? mainButton,
    Duration? duration,
    bool showProgressIndicator = false,
  }) {
    _runSafely(() {
      _showMaterialSnackBar(
        title: title,
        message: message,
        position: position,
        backgroundColor: backgroundColor ?? AppColors.primary,
        icon: icon ??
            const Icon(Icons.info_outline, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        mainButton: mainButton,
        showProgressIndicator: showProgressIndicator,
        textColor: colorText ?? Colors.white,
      );
    });
  }
}
