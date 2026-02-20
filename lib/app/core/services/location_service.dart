import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../helpers/app_snackbar.dart';

/// Service for handling location-related functionality
///
/// Usage:
/// ```dart
/// final locationService = Get.find<LocationService>();
/// final position = await locationService.getCurrentPosition();
/// if (position != null) {
///   // Use position.latitude and position.longitude
/// }
/// ```
class LocationService extends GetxService {
  /// Get current position with permission handling
  ///
  /// [showSnackbars] - Whether to show snackbars for errors/status (default: true)
  /// [accuracy] - Location accuracy level (default: LocationAccuracy.medium)
  /// [timeLimit] - Timeout for getting position (default: 10 seconds)
  ///
  /// Returns [Position] if successful, null if failed or permission denied
  Future<Position?> getCurrentPosition({
    bool showSnackbars = true,
    LocationAccuracy accuracy = LocationAccuracy.medium,
    Duration timeLimit = const Duration(seconds: 10),
  }) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (showSnackbars) {
        AppSnackbar.warning(
          'Aktifkan layanan lokasi untuk menggunakan fitur ini',
          title: 'Lokasi Tidak Aktif',
        );
      }
      // return null;
    }

    // Check and request location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (showSnackbars) {
          AppSnackbar.error(
            'Izin lokasi diperlukan untuk menggunakan fitur ini',
            title: 'Izin Ditolak',
          );
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (showSnackbars) {
        AppSnackbar.error(
          'Buka pengaturan untuk mengizinkan akses lokasi',
          title: 'Izin Lokasi Diblokir',
        );
      }
      return null;
    }

    // Permission granted, get current position
    try {
      if (showSnackbars) {
        AppSnackbar.info(
          'Mendapatkan posisi Anda...',
          title: 'Mencari Lokasi',
          duration: const Duration(seconds: 2),
          showProgressIndicator: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: timeLimit,
        ),
      );

      return position;
    } catch (e) {
      if (showSnackbars) {
        AppSnackbar.error(
          'Coba lagi dalam beberapa saat',
          title: 'Gagal Mendapatkan Lokasi',
        );
      }
      return null;
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings for location permission
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Calculate distance between two points in meters
  double distanceBetween({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
