import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionsManager {
  static final PermissionsManager _instance = PermissionsManager._internal();
  factory PermissionsManager() => _instance;
  PermissionsManager._internal();

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return false;
  }

  Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      return await Permission.storage.status.isGranted;
    } else if (Platform.isIOS) {
      return await Permission.photos.status.isGranted;
    }
    return false;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    return await Permission.camera.status.isGranted;
  }

  Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    return await [
      Permission.storage,
      Permission.photos,
      Permission.camera,
    ].request();
  }
}
