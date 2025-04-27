import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionsHelper {
  static Future<bool> requestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      // On iOS, request storage (access to Files app) or photos.
      // 'storage' is generally better for saving arbitrary files.
      status = await Permission.storage.request();
    } else if (Platform.isAndroid) {
      // On Android, request storage permission.
      // permission_handler handles API level differences.
      status = await Permission.storage.request();
      // For Android 13+, if targeting SDK 33+, specific permissions like
      // photos, videos, audio might be needed instead of broad storage,
      // but for saving a CSV, 'storage' or MANAGE_EXTERNAL_STORAGE (less recommended)
      // are the relevant ones. Let's stick with 'storage' for now.
    } else {
      // Other platforms might not need explicit permissions or use different ones.
      return true; // Assume granted or not needed
    }

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Inform user they need to go to settings
      openAppSettings();
      return false;
    } else {
      // Denied but not permanently
      return false;
    }
  }
}
