# Configuration System

This directory contains the centralized configuration system for the Fundi app. It provides a unified way to manage permissions, versions, and platform-specific settings.

## Usage Example

```dart
// Get platform-specific settings
final platformConfig = PlatformConfig();
if (platformConfig.isAndroid) {
  // Handle Android-specific logic
}

// Request permissions
final permissionsManager = PermissionsManager();
final hasStoragePermission = await permissionsManager.requestStoragePermission();

// Access app configuration
final appName = AppConfig.appName;
final appVersion = AppConfig.appVersion;
```

## Files

- `app_config.dart`: Contains app-wide configuration constants
- `permissions_manager.dart`: Manages permissions across different platforms
- `platform_config.dart`: Handles platform-specific configurations and feature flags

## Best Practices

1. Always use these configuration classes instead of hardcoding values
2. Add new permissions to `PermissionsManager` when needed
3. Update platform-specific settings in `PlatformConfig`
4. Keep version numbers and build numbers in sync with `pubspec.yaml`
