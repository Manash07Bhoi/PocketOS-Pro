import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<int> _getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  static Future<bool> hasMediaPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt >= 33) {
        return await Permission.photos.isGranted &&
               await Permission.videos.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    } else if (Platform.isIOS) {
        return await Permission.photos.isGranted;
    }
    return false;
  }

  static Future<bool> requestMediaPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt >= 33) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
        ].request();
        return statuses[Permission.photos]!.isGranted &&
               statuses[Permission.videos]!.isGranted;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
       final status = await Permission.photos.request();
       return status.isGranted;
    }
    return false;
  }
}
