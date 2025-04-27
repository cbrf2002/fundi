import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
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
import '../widgets/separator_picker_dialog.dart';
import '../../../core/utils/permissions_helper.dart';
import '../widgets/delete_all_confirmation_dialog.dart';

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

  Future<void> _loadUserData() async {
    bool permissionGranted = await PermissionsHelper.requestStoragePermission();
    if (!permissionGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Storage permission is required to function properly.')),
      );
    }

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
        if (newPreferences.decimalSeparatorPreference !=
            oldPreferences.decimalSeparatorPreference) {
          formattingProvider.setDecimalSeparatorPreference(
              newPreferences.decimalSeparatorPreference);
        }
        if (newPreferences.thousandsSeparatorPreference !=
            oldPreferences.thousandsSeparatorPreference) {
          formattingProvider.setThousandsSeparatorPreference(
              newPreferences.thousandsSeparatorPreference);
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

  void _showDecimalSeparatorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SeparatorPickerDialog(
          title: 'Select Decimal Separator',
          currentPreference: _preferences.decimalSeparatorPreference,
          options: const {
            'device': 'Device Default',
            'dot': 'Dot (.)',
            'comma': 'Comma (,)',
          },
          onSelected: (preference) {
            final newPrefs =
                _preferences.copyWith(decimalSeparatorPreference: preference);
            _updatePreferences(newPrefs);
          },
        );
      },
    );
  }

  void _showThousandsSeparatorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SeparatorPickerDialog(
          title: 'Select Thousands Separator',
          currentPreference: _preferences.thousandsSeparatorPreference,
          options: const {
            'device': 'Device Default',
            'dot': 'Dot (.)',
            'comma': 'Comma (,)',
            'space': 'Space ( )',
            'none': 'None',
          },
          onSelected: (preference) {
            final newPrefs =
                _preferences.copyWith(thousandsSeparatorPreference: preference);
            _updatePreferences(newPrefs);
          },
        );
      },
    );
  }

  Future<void> _handleExport() async {
    // 1. Request Permission using the helper
    bool permissionGranted = await PermissionsHelper.requestStoragePermission();

    if (!permissionGranted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Storage access is needed to save or share the export file. Please grant permission in settings.')),
      );
      // Stop the export process if permission is denied
      return;
    }

    // Proceed only if permission is granted
    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Get CSV Data (existing code)
      final String csvData = await _accountController.exportData();

      // 3. Prepare file for sharing (existing code)
      final String timestamp =
          DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String fileName = 'fundi_export_$timestamp.csv';
      final XFile fileToShare = XFile.fromData(
        Uint8List.fromList(csvData.codeUnits),
        name: fileName,
        mimeType: 'text/csv',
      );

      // 4. Use Share Plugin (existing code)
      final result = await Share.shareXFiles(
        [fileToShare],
        subject: 'Fundi Data Export $timestamp',
        text: 'Here is your Fundi transaction data exported on $timestamp.',
      );

      // ... existing result handling ...
      if (mounted) {
        if (result.status == ShareResultStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data ready for sharing/saving.')),
          );
        } else if (result.status == ShareResultStatus.dismissed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export cancelled.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not initiate sharing.')),
          );
        }
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

  void _showDeleteAllConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing by tapping outside during operation
      builder: (BuildContext context) {
        return DeleteAllConfirmationDialog(
          onConfirm: () async {
            // Show loading indicator immediately after dialog closes
            setState(() {
              _isLoading = true;
            });
            try {
              await _accountController.deleteAllTransactions();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('All transactions deleted successfully.')),
                );
                // Optionally trigger a refresh of stats or other dependent data
                // For simplicity, we just stop loading here. A full refresh might be needed.
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete data: $e')),
                );
              }
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
        );
      },
    );
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
    final formattingProvider =
        Provider.of<FormattingProvider>(context, listen: false);
    formattingProvider.updateLocale(Localizations.localeOf(context));

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
            future: _accountController.getAccountScreenStats(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(
                    "Error getting stats in FutureBuilder: ${snapshot.error}");
                return StatsSection(
                  transactionCount: 0,
                  monthlyTotal: 0.0,
                  categoryCount: 0,
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ));
              }
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
            onShowDecimalSeparatorPicker: _showDecimalSeparatorPicker,
            onShowThousandsSeparatorPicker: _showThousandsSeparatorPicker,
          ),
          const Divider(),
          DataManagementSection(
            onExport: _handleExport,
            // Pass the new handler
            onDeleteAll: _showDeleteAllConfirmationDialog,
          ),
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
