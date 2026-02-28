import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/app_snackbar.dart';
import '../../../core/helpers/error_handler.dart';
import '../../../core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/mission_controller.dart';

/// Halaman untuk mengambil foto misi
class MissionPhotoView extends GetView<MissionController> {
  const MissionPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MissionPhotoViewStateful();
  }
}

class _MissionPhotoViewStateful extends StatefulWidget {
  const _MissionPhotoViewStateful();

  @override
  State<_MissionPhotoViewStateful> createState() =>
      _MissionPhotoViewStatefulState();
}

class _MissionPhotoViewStatefulState extends State<_MissionPhotoViewStateful>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  final MissionController controller = Get.find<MissionController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kamera tersedia';
        });
        return;
      }

      await _setupCameraController(_cameras[_selectedCameraIndex]);

      // Pre-request lokasi setelah kamera berhasil diinisialisasi,
      // agar saat submit foto, lokasi sudah tersedia.
      _preRequestLocationPermission();
    } catch (e) {
      setState(() {
        _errorMessage =
            ErrorHandler.getReadableMessage(e, tag: 'MissionPhotoView');
      });
    }
  }

  /// Minta izin lokasi di background setelah kamera aktif.
  /// Tidak memblokir UI — jika gagal, akan diminta ulang saat submit.
  Future<void> _preRequestLocationPermission() async {
    try {
      final locationService = Get.find<LocationService>();
      await locationService.getCurrentPosition(
        showSnackbars: false,
        accuracy: LocationAccuracy.medium,
      );
    } catch (_) {
      // Abaikan — akan diminta ulang saat submitPhoto
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            ErrorHandler.getReadableMessage(e, tag: 'MissionPhotoView');
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    FlashMode newFlashMode;
    switch (_flashMode) {
      case FlashMode.off:
        newFlashMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newFlashMode = FlashMode.always;
        break;
      case FlashMode.always:
        newFlashMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newFlashMode = FlashMode.off;
        break;
    }

    try {
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _flashMode = newFlashMode;
      });
    } catch (e) {
      AppSnackbar.error('Gagal mengubah mode flash');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });

    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();

      // Save to app directory
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'mission_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${directory.path}/$fileName';

      await File(image.path).copy(filePath); // Re-inserted line
      controller.setCapturedImage(filePath);
      // PERBAIKAN: Gunakan offNamed agar MissionPhotoView (dan kameranya)
      // langsung di-dispose sebelum masuk ke halaman preview.
      Get.offNamed('/mission-photo-preview');
    } catch (e) {
      AppSnackbar.error(
          ErrorHandler.getReadableMessage(e, tag: 'MissionPhotoView'));
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  String _getFlashLabel() {
    switch (_flashMode) {
      case FlashMode.off:
        return 'Off';
      case FlashMode.auto:
        return 'Auto';
      case FlashMode.always:
        return 'On';
      case FlashMode.torch:
        return 'Torch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            _buildTopBar(),

            // Camera view area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.grey[900],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildCameraPreview(),
                ),
              ),
            ),

            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        if (_isCapturing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          // Back button
          TextButton.icon(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.primary,
              size: 20,
            ),
            label: Text(
              'Kembali',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            onPressed: _switchCamera,
            icon: Icon(
              Icons.cameraswitch,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),

          // Capture button
          // GestureDetector(
          //   onTap: _isCapturing ? null : _capturePhoto,
          //   child: Container(
          //     width: 72,
          //     height: 72,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       border: Border.all(
          //         color: Colors.white,
          //         width: 4,
          //       ),
          //     ),
          //     child: Container(
          //       margin: const EdgeInsets.all(4),
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: _isCapturing
          //             ? AppColors.primary.withOpacity(0.5)
          //             : AppColors.primary,
          //       ),
          //     ),
          //   ),
          // ),

          GestureDetector(
            onTap: _isCapturing ? null : _capturePhoto,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isCapturing
                      ? AppColors.primary.withAlpha(50)
                      : AppColors.primary,
                ),
              ),
            ),
          ),

          // Flash button
          GestureDetector(
            onTap: _toggleFlash,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getFlashIcon(),
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                Text(
                  _getFlashLabel(),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
