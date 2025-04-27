import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';
import '../controllers/account_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/stats_section.dart';
import '../widgets/preferences_section.dart';
import '../widgets/data_management_section.dart';
import '../widgets/account_actions_section.dart';
import '../widgets/currency_picker_dialog.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AccountController _accountController = AccountController();
  late UserProfile _userProfile;
  late UserPreferences _preferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _loadUserData() async {
    await requestStoragePermission();
    try {
      if (!_accountController.isUserLoggedIn()) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final userProfile = await _accountController.loadUserProfile();
      final preferences = await _accountController.loadUserPreferences();

      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _preferences = preferences;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: $e')),
        );
      }
    }
  }

  Future<void> _updatePreferences(UserPreferences newPreferences) async {
    UserPreferences oldPreferences = _preferences;
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    try {
      setState(() {
        _preferences = newPreferences;
      });

      await _accountController.saveUserPreferences(newPreferences);

      // Update providers
      if (mounted) {
        if (newPreferences.currency != oldPreferences.currency) {
          formattingProvider.setCurrency(newPreferences.currency);
        }
        if (newPreferences.showCents != oldPreferences.showCents) {
          formattingProvider.setShowCents(newPreferences.showCents);
        }
        if (newPreferences.useSystemTheme != oldPreferences.useSystemTheme ||
            newPreferences.isDarkMode != oldPreferences.isDarkMode) {
          themeProvider.setTheme(
              useSystemTheme: newPreferences.useSystemTheme,
              isDarkMode: newPreferences.isDarkMode);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _preferences = oldPreferences;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preferences: $e')),
        );
      }
    }
  }

  void _showCurrencyPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CurrencyPickerDialog(
          selectedCurrency: _preferences.currency,
          onCurrencySelected: (currency) {
            final newPrefs = _preferences.copyWith(currency: currency);
            _updatePreferences(newPrefs);
          },
        );
      },
    );
  }

  Future<void> _handleExport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final filePath = await _accountController.exportData();

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported to: $filePath')),
        );
      } else {
        throw Exception('Export failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleChangePassword() async {
    try {
      await _accountController.sendPasswordResetEmail(_userProfile.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _accountController.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      backgroundColor: Colors.transparent,
      body: ListView(
        children: [
          ProfileHeader(userProfile: _userProfile),
          const Divider(),
          FutureBuilder<List<num>>(
            // Check if uid is valid before creating the future
            future: (_userProfile.uid.isNotEmpty)
                ? _accountController.getStats(_userProfile.uid)
                : Future.value(
                    [0, 0.0, 0]), // Return default stats if uid is invalid
            builder: (context, snapshot) {
              // Handle potential errors from the future
              if (snapshot.hasError) {
                print(
                    "Error getting stats in FutureBuilder: ${snapshot.error}");
                // Optionally show an error message in the UI
                return StatsSection(
                  transactionCount: 0,
                  monthlyTotal: 0.0,
                  categoryCount: 0,
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _userProfile.uid.isNotEmpty) {
                // Show loading only if we actually initiated the fetch
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }
              // Use snapshot data or default if uid was invalid or future failed
              final stats = snapshot.data ?? [0, 0.0, 0];
              return StatsSection(
                transactionCount: stats[0] as int,
                monthlyTotal: stats[1] as double,
                categoryCount: stats[2] as int,
              );
            },
          ),
          const Divider(),
          PreferencesSection(
            preferences: _preferences,
            onPreferencesChanged: _updatePreferences,
            onShowCurrencyPicker: _showCurrencyPicker,
          ),
          const Divider(),
          DataManagementSection(onExport: _handleExport),
          const Divider(),
          AccountActionsSection(
            onChangePassword: _handleChangePassword,
            onLogout: _handleLogout,
          ),
        ],
      ),
    );
  }
}
