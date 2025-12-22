import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snappie_app/app/core/constants/environment_config.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../../routes/api_endpoints.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class AppUpdateInfo {
  final String versionName;
  final int versionCode;
  final String apkUrl;
  final String changelogs;

  AppUpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.apkUrl,
    required this.changelogs,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['apk_url']?.toString() ?? '';
    final url = rawUrl.replaceAll('`', '').trim();
    final rawLogs = json['changelogs']?.toString() ?? '';
    final logs = rawLogs.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return AppUpdateInfo(
      versionName: json['version_name']?.toString() ?? '',
      versionCode: int.tryParse(json['version_code']?.toString() ?? '') ?? 0,
      apkUrl: url,
      changelogs: logs,
    );
  }
}

class AppUpdateService extends GetxService {
  static const platform = MethodChannel('com.justtffy.snappie_app/update');
  final DioClient dioClient;

  AppUpdateService({required this.dioClient});

  Future<AppUpdateInfo?> checkUpdate() async {
    final requestUrl = ApiEndpoints.localUrl + ApiEndpoints.appUpdate;
    print(requestUrl);
    final resp = await dioClient.dio.get(
      requestUrl,
      queryParameters: {
        'version_code': AppConstants.appVersionCode,
        'device_platform': 'android',
      },
      options: dio_lib.Options(
        headers: {
          'Authorization': 'Bearer ${EnvironmentConfig.registrationApiKey}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        extra: {
          DioClient.skipAuthRefreshKey:
              true, // Skip refresh interceptor for login
        },
      ),
    );
    if (resp.statusCode == 200 && resp.data is Map<String, dynamic>) {
      final map = resp.data as Map<String, dynamic>;
      final success = map['success'] == true;
      final data = map['data'];
      if (success && data is Map<String, dynamic>) {
        final info = AppUpdateInfo.fromJson(data);
        if (info.versionCode > AppConstants.appVersionCode && info.apkUrl.isNotEmpty) {
          return info;
        }
      }
      return null;
    }
    throw Exception('Server error: ${resp.statusCode}');
  }

  Future<void> checkAndPrompt({bool showNoUpdateDialog = false, bool showErrorDialog = false}) async {
    if (!Platform.isAndroid) return;
    AppUpdateInfo? info;
    try {
      info = await checkUpdate();
    } catch (e) {
      if (showErrorDialog) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Gagal memeriksa pembaruan'),
            content: Text('Terjadi kesalahan server. ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
      return;
    }
    if (info == null) {
      if (showNoUpdateDialog) {
        await Get.dialog(
          AlertDialog(
            title: const Text('Tidak ada pembaruan'),
            content: const Text('Versi aplikasi Anda sudah yang terbaru.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Tutup'),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
      return;
    }

    final i = info;
    await Get.dialog(
      AlertDialog(
        title: const Text('Pembaruan tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi ${i.versionName}'),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: SingleChildScrollView(
                child: Text(i.changelogs),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _downloadAndInstall(i.apkUrl, i.versionName);
            },
            child: const Text('Update sekarang'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _downloadAndInstall(String url, String versionName) async {
    try {
      final RxDouble progress = 0.0.obs;
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Mengunduh Pembaruan'),
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress.value),
                  const SizedBox(height: 10),
                  Text('${(progress.value * 100).toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final String filePath = '${dir.path}/update_v$versionName.apk';

      await dioClient.dio.download(
        url,
        filePath,
        onReceiveProgress: (rec, total) {
          if (total != -1) {
            progress.value = rec / total;
          }
        },
      );

      Get.back(); // Close progress dialog

      await Get.dialog(
        AlertDialog(
          title: const Text('Instal Pembaruan tersedia'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Nanti'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                try {
                  // await AppUpdateService.platform.invokeMethod('installApk', {'filePath': filePath});
                  await OpenFile.open(filePath);
                } on PlatformException catch (e) {
                  Get.snackbar(
                    'Gagal Menginstal',
                    '${e.message}',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 5),
                  );
                }
              },
              child: const Text('Install sekarang'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      if (Get.isDialogOpen == true) Get.back();
      Get.snackbar(
        'Gagal Mengunduh',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
