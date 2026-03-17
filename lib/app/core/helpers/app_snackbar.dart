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

  static bool _hasOverlay() {
    final overlayState = Get.key.currentState?.overlay;
    return overlayState != null && overlayState.mounted;
  }

  static void _runSafely(VoidCallback showAction) {
    if (!_hasOverlay()) {
      debugPrint('AppSnackbar: Overlay belum tersedia, snackbar dilewati.');
      return;
    }

    try {
      showAction();
    } catch (e) {
      debugPrint('AppSnackbar: gagal menampilkan snackbar: $e');
    }
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
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        isDismissible: true,
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
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        isDismissible: true,
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
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        isDismissible: true,
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
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: AppColors.primary.withValues(alpha: 0.95),
        colorText: Colors.white,
        icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        isDismissible: true,
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
      Get.snackbar(
        '🎯 Challenge Selesai!',
        '$challengeName — ${rewardText ?? "Tantangan selesai!"}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary.withValues(alpha: 0.95),
        colorText: Colors.white,
        icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
        borderRadius: 12,
        isDismissible: true,
        forwardAnimationCurve: Curves.easeOutBack,
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
      Get.snackbar(
        title,
        message,
        snackPosition: position,
        backgroundColor: backgroundColor,
        colorText: colorText,
        icon: icon,
        mainButton: mainButton,
        duration: duration ?? _defaultDuration,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        isDismissible: true,
        showProgressIndicator: showProgressIndicator,
      );
    });
  }
}
