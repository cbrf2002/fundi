import 'dart:io';
import 'package:flutter/foundation.dart';

class PlatformConfig {
  static final PlatformConfig _instance = PlatformConfig._internal();
  factory PlatformConfig() => _instance;
  PlatformConfig._internal();

  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isWeb => kIsWeb;
  bool get isDesktop => !kIsWeb && (isWindows || isMacOS || isLinux);
  bool get isMobile => !kIsWeb && (isAndroid || isIOS);

  String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  Map<String, dynamic> getPlatformSpecificSettings() {
    if (isAndroid) {
      return {
        'storagePermission': 'android.permission.WRITE_EXTERNAL_STORAGE',
        'cameraPermission': 'android.permission.CAMERA',
        'internetPermission': 'android.permission.INTERNET',
      };
    } else if (isIOS || isMacOS) {
      return {
        'photoLibraryUsage': 'NSPhotoLibraryUsageDescription',
        'cameraUsage': 'NSCameraUsageDescription',
      };
    } else if (isWeb) {
      return {
        'requiredApis': ['FileSystem', 'WebStorage', 'IndexedDB'],
        'supportedBrowsers': ['Chrome', 'Firefox', 'Safari', 'Edge'],
      };
    } else if (isWindows || isLinux) {
      return {
        'requiredPermissions': ['fileSystem', 'network'],
      };
    }
    return {};
  }

  bool shouldShowFeature(String featureName) {
    switch (featureName) {
      case 'biometrics':
        return isMobile;
      case 'fileSharing':
        return !isWeb;
      case 'camera':
        return isMobile;
      case 'localStorage':
        return !isWeb || (isWeb && kIsWeb);
      case 'notifications':
        return !isLinux;
      default:
        return true;
    }
  }

  bool get supportsHapticFeedback => isMobile;
  bool get supportsFileSystem => !isWeb;
  bool get supportsBiometrics => isMobile;
  bool get supportsCamera => isMobile;
  bool get supportsNotifications => !isLinux;
}
