import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/firestore_service.dart';

class ThemeProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  bool _useSystemTheme = true;
  bool _isDarkMode = false;
  String? _userId;

  bool get useSystemTheme => _useSystemTheme;
  bool get isDarkMode => _isDarkMode;

  Future<void> initializeTheme(String userId) async {
    _userId = userId;
    try {
      final preferences = await _firestoreService.getUserPreferences();
      _useSystemTheme = preferences.useSystemTheme;
      _isDarkMode = preferences.isDarkMode;
      _updateSystemUI();
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
    }
  }

  Future<void> setTheme({required bool useSystemTheme, required bool isDarkMode}) async {
    if (_userId == null) return;

    _useSystemTheme = useSystemTheme;
    _isDarkMode = isDarkMode;
    _updateSystemUI();
    notifyListeners();

    try {
      final currentPreferences = await _firestoreService.getUserPreferences();
      final updatedPreferences = currentPreferences.copyWith(
        useSystemTheme: useSystemTheme,
        isDarkMode: isDarkMode,
      );

      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  ThemeMode get themeMode {
    if (_useSystemTheme) return ThemeMode.system;
    return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
