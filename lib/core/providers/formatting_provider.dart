import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';
import '../models/user_preferences.dart';

class FormattingProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  String _currency = 'USD';
  bool _showCents = true;
  String _decimalSeparatorPreference = 'device';
  String _thousandsSeparatorPreference = 'device';
  late NumberFormat _formatter;
  Locale? _currentLocale; // Store locale to detect changes
  String? _userId;

  FormattingProvider() {
    // Initialize with default locale before preferences are loaded
    _updateFormatter();
  }

  // Call this when locale changes (e.g., in main.dart or via context)
  void updateLocale(Locale locale) {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      _updateFormatter();
      notifyListeners();
    }
  }

  String get currency => _currency;
  bool get showCents => _showCents;
  String get decimalSeparatorPreference => _decimalSeparatorPreference;
  String get thousandsSeparatorPreference => _thousandsSeparatorPreference;

  Future<void> initializeFormatting(String userId) async {
    _userId = userId;
    try {
      // Load all relevant preferences
      final preferences = await _firestoreService.getUserPreferences();
      _currency = preferences.currency;
      _showCents = preferences.showCents;
      _decimalSeparatorPreference = preferences.decimalSeparatorPreference;
      _thousandsSeparatorPreference = preferences.thousandsSeparatorPreference;
      // Note: Theme preferences are handled by ThemeProvider
      _updateFormatter(); // Update formatter after loading prefs
      notifyListeners();
    } catch (e) {
      print('Error loading formatting preferences: $e');
      // Keep default formatting if loading fails
    }
  }

  // Helper to get current preferences as an object
  UserPreferences _getCurrentPreferencesObject() {
    // Fetching theme settings might require ThemeProvider or separate logic
    // For now, using potentially stale theme values if not updated elsewhere
    // A better approach might involve combining state or passing ThemeProvider
    return UserPreferences(
      uid: _userId ?? '', // Ensure uid is handled
      currency: _currency,
      showCents: _showCents,
      decimalSeparatorPreference: _decimalSeparatorPreference,
      thousandsSeparatorPreference: _thousandsSeparatorPreference,
      // Placeholder values for theme/notifications - these should ideally
      // come from the source of truth (e.g., ThemeProvider, another service)
      // or be loaded/saved separately if FormattingProvider shouldn't own them.
      useSystemTheme: true, // Example placeholder
      isDarkMode: false, // Example placeholder
      enableNotifications: false, // Example placeholder
    );
  }

  Future<void> setCurrency(String currency) async {
    if (_userId == null || _currency == currency) return;

    _currency = currency;
    _updateFormatter();
    notifyListeners();

    try {
      // Construct object from current provider state and save
      final updatedPreferences =
          _getCurrentPreferencesObject().copyWith(currency: currency);
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving currency preference: $e');
      // Optionally revert state change on error
    }
  }

  Future<void> setShowCents(bool showCents) async {
    if (_userId == null || _showCents == showCents) return;

    _showCents = showCents;
    _updateFormatter();
    notifyListeners();

    try {
      // Construct object from current provider state and save
      final updatedPreferences =
          _getCurrentPreferencesObject().copyWith(showCents: showCents);
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving showCents preference: $e');
      // Optionally revert state change on error
    }
  }

  Future<void> setDecimalSeparatorPreference(String preference) async {
    if (_userId == null || _decimalSeparatorPreference == preference) return;

    _decimalSeparatorPreference = preference;
    _updateFormatter();
    notifyListeners();

    try {
      // Construct object from current provider state and save
      final updatedPreferences = _getCurrentPreferencesObject()
          .copyWith(decimalSeparatorPreference: preference);
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving decimal separator preference: $e');
      // Optionally revert state change on error
    }
  }

  Future<void> setThousandsSeparatorPreference(String preference) async {
    if (_userId == null || _thousandsSeparatorPreference == preference) return;

    _thousandsSeparatorPreference = preference;
    _updateFormatter();
    notifyListeners();

    try {
      // Construct object from current provider state and save
      final updatedPreferences = _getCurrentPreferencesObject()
          .copyWith(thousandsSeparatorPreference: preference);
      await _firestoreService.saveUserPreferences(updatedPreferences);
    } catch (e) {
      print('Error saving thousands separator preference: $e');
      // Optionally revert state change on error
    }
  }

  String getDecimalSeparator() {
    final localeString = _currentLocale?.toString() ?? Intl.systemLocale;
    // Use NumberFormat to get locale-specific symbols
    final symbols = NumberFormat.decimalPattern(localeString).symbols;
    switch (_decimalSeparatorPreference) {
      case 'dot':
        return '.';
      case 'comma':
        return ',';
      case 'device':
      default:
        // Ensure DECIMAL_SEP is returned, not potentially GROUP_SEP if locale uses comma as decimal
        return symbols.DECIMAL_SEP;
    }
  }

  String getThousandsSeparator() {
    final localeString = _currentLocale?.toString() ?? Intl.systemLocale;
    // Use NumberFormat to get locale-specific symbols
    final symbols = NumberFormat.decimalPattern(localeString).symbols;
    switch (_thousandsSeparatorPreference) {
      case 'dot':
        return '.';
      case 'comma':
        return ',';
      case 'space':
        return '\u00A0'; // Use non-breaking space
      case 'none':
        return ''; // Empty string for no separator
      case 'device':
      default:
        return symbols.GROUP_SEP;
    }
  }

  void _updateFormatter() {
    final localeString = _currentLocale?.toString() ?? Intl.systemLocale;
    final decimalDigits = _showCents ? 2 : 0; // Standard decimal places

    // Create a currency formatter for the specified locale.
    // It will use the locale's default separators.
    // We provide the custom symbol and decimal digits.
    _formatter = NumberFormat.currency(
      locale: localeString,
      symbol: getCurrencySymbol(), // Use our method to get the symbol
      decimalDigits: decimalDigits,
    );

    // Note: We are NOT trying to override the locale's default separators for display formatting here.
    // The getDecimalSeparator/getThousandsSeparator methods are primarily for parsing input
    // where user preference might differ from locale default.
  }

  String formatAmount(double amount) {
    // Format using the locale-aware formatter.
    // It already includes the currency symbol.
    try {
      return _formatter.format(amount);
    } catch (e) {
      print("Error formatting amount: $e");
      // Fallback formatting
      return "${getCurrencySymbol()} ${amount.toStringAsFixed(_showCents ? 2 : 0)}";
    }
  }

  String formatAmountRaw(double amount) {
    // Format without currency symbol, using a decimal pattern formatter
    final localeString = _currentLocale?.toString() ?? Intl.systemLocale;
    final decimalDigits = _showCents ? 2 : 0;

    // Create a decimal formatter for the locale
    final rawFormatter = NumberFormat.decimalPatternDigits(
      locale: localeString,
      decimalDigits: decimalDigits,
    );

    try {
      String formatted = rawFormatter.format(amount);
      String localeGroupSep = rawFormatter.symbols.GROUP_SEP;
      String preferredGroupSep = getThousandsSeparator();

      if (localeGroupSep != preferredGroupSep) {
        if (localeGroupSep.isNotEmpty) {
          formatted = formatted.replaceAll(localeGroupSep, preferredGroupSep);
        } else if (preferredGroupSep.isNotEmpty) {
          // Injecting grouping separator if locale default is none is complex, skipping for now.
          // This case is less common. Focus on replacement.
        }
      }
      return formatted;
    } catch (e) {
      print("Error formatting raw amount: $e");
      // Fallback formatting
      return amount.toStringAsFixed(decimalDigits);
    }
  }

  String getCurrencySymbol() {
    // Simple lookup, consider a more robust solution for more currencies
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'PHP': '₱'
    };
    return symbols[_currency] ??
        _currency; // Fallback to code if symbol not found
  }
}
