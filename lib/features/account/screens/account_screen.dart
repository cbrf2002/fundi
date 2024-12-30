import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fundi/core/services/export_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late UserProfile _userProfile;
  late UserPreferences _preferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Load user profile
        final userProfileData = await _firestoreService.getDocument('users', user.uid);
        if (userProfileData.isEmpty) {
          // Create default user profile if none exists
          final defaultProfile = UserProfile(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? 'User',
            photoUrl: '',
          );
          await _firestoreService.setDocument('users', user.uid, defaultProfile.toMap());
          _userProfile = defaultProfile;
        } else {
          _userProfile = UserProfile.fromMap(userProfileData);
        }

        // Load user preferences
        final preferences = await _firestoreService.getUserPreferences();
        setState(() {
          _preferences = preferences;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading user data: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading user data: $e')),
          );
        }
      }
    } else {
      // Handle not logged in state
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _updatePreferences(UserPreferences newPreferences) async {
    UserPreferences oldPreferences = _preferences;
    try {
      // Update state first
      setState(() {
        _preferences = newPreferences;
      });

      // Save to Firestore
      await _firestoreService.saveUserPreferences(newPreferences);

      // Update providers
      if (newPreferences.currency != oldPreferences.currency) {
        Provider.of<FormattingProvider>(context, listen: false)
            .setCurrency(newPreferences.currency);
      }
      if (newPreferences.showCents != oldPreferences.showCents) {
        Provider.of<FormattingProvider>(context, listen: false)
            .setShowCents(newPreferences.showCents);
      }
      if (newPreferences.useSystemTheme != oldPreferences.useSystemTheme ||
          newPreferences.isDarkMode != oldPreferences.isDarkMode) {
        Provider.of<ThemeProvider>(context, listen: false)
            .setTheme(useSystemTheme: newPreferences.useSystemTheme, isDarkMode: newPreferences.isDarkMode);
      }
    } catch (e) {
      // Revert state if save fails
      setState(() {
        _preferences = oldPreferences;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update preferences: $e')),
        );
      }
    }
  }

  void _showCurrencyPicker() {
    final currencies = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'PHP': '₱',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select Currency',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...currencies.entries.map((entry) {
                  final isSelected = _preferences.currency == entry.key;
                  return InkWell(
                    onTap: () {
                      final newPrefs = _preferences.copyWith(currency: entry.key);
                      _updatePreferences(newPrefs);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                entry.value,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${entry.value} ${entry.key}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection({
    required int transactionCount,
    required double monthlyTotal,
    required int categoryCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Total Transactions',
                  transactionCount.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'This Month',
                  Provider.of<FormattingProvider>(context).formatAmount(monthlyTotal),
                  Icons.calendar_today,
                  monthlyTotal >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatsCard(
                  'Categories',
                  categoryCount.toString(),
                  Icons.category,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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
          // Profile Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _userProfile.displayName.isNotEmpty
                        ? _userProfile.displayName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userProfile.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _userProfile.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                // Quick Stats
                FutureBuilder<List<num>>(
                  future: Future.wait([
                    _firestoreService.getTransactionStats(_userProfile.uid),
                    _firestoreService.getCurrentMonthStats(_userProfile.uid),
                    _firestoreService.getCategoryCount(_userProfile.uid),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    final stats = snapshot.data ?? [0, 0.0, 0];
                    return _buildStatsSection(
                      transactionCount: stats[0] as int,
                      monthlyTotal: stats[1] as double,
                      categoryCount: stats[2] as int,
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          // Preferences Sections
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Currency & Format'),
                ListTile(
                  leading: const Icon(Icons.currency_exchange),
                  title: const Text('Currency'),
                  subtitle: Text('${_preferences.currency} (${Provider.of<FormattingProvider>(context).getCurrencySymbol()})'),
                  onTap: _showCurrencyPicker,
                ),
                SwitchListTile(
                  title: const Text('Show Cents'),
                  subtitle: const Text('Display decimal places in amounts'),
                  value: _preferences.showCents,
                  onChanged: (value) {
                    final newPrefs = _preferences.copyWith(showCents: value);
                    _updatePreferences(newPrefs);
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Appearance'),
                SwitchListTile(
                  title: const Text('Use System Theme'),
                  subtitle: const Text('Match system dark/light mode'),
                  value: _preferences.useSystemTheme,
                  onChanged: (value) {
                    final newPrefs = _preferences.copyWith(
                      useSystemTheme: value,
                      isDarkMode: value ? Theme.of(context).brightness == Brightness.dark : _preferences.isDarkMode,
                    );
                    _updatePreferences(newPrefs);
                  },
                ),
                if (!_preferences.useSystemTheme)
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: _preferences.isDarkMode,
                    onChanged: (value) {
                      final newPrefs = _preferences.copyWith(isDarkMode: value);
                      _updatePreferences(newPrefs);
                    },
                  ),
                const SizedBox(height: 16),
                _buildSectionHeader('Notifications'),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Get updates about your spending'),
                  value: _preferences.enableNotifications,
                  onChanged: (value) {
                    final newPrefs = _preferences.copyWith(enableNotifications: value);
                    _updatePreferences(newPrefs);
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Data Management'),
                _buildExportSection(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup Data'),
                  onTap: () async {
                    // TODO: Implement data backup
                  },
                ),
                const SizedBox(height: 16),
                _buildSectionHeader('Account'),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Change Password'),
                  onTap: () async {
                    try {
                      await _auth.sendPasswordResetEmail(email: _userProfile.email);
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
                  },
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FilledButton(
                    onPressed: () async {
                      await _auth.signOut();
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: const Text('Log Out'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildExportSection() {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Export Data'),
      subtitle: const Text('Export your transactions as CSV'),
      onTap: () async {
        setState(() {
          _isLoading = true;
        });
        try {
          final exportService = ExportService();
          final filePath = await exportService.exportTransactionsToCSV();
          
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
      },
    );
  }
}
