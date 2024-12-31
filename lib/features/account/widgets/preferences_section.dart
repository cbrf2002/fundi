import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/providers/formatting_provider.dart';

class PreferencesSection extends StatelessWidget {
  final UserPreferences preferences;
  final Function(UserPreferences) onPreferencesChanged;
  final VoidCallback onShowCurrencyPicker;

  const PreferencesSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    required this.onShowCurrencyPicker,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Currency & Format'),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            subtitle: Text('${preferences.currency} (${Provider.of<FormattingProvider>(context).getCurrencySymbol()})'),
            onTap: onShowCurrencyPicker,
          ),
          SwitchListTile(
            title: const Text('Show Cents'),
            subtitle: const Text('Display decimal places in amounts'),
            value: preferences.showCents,
            onChanged: (value) {
              final newPrefs = preferences.copyWith(showCents: value);
              onPreferencesChanged(newPrefs);
            },
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            title: const Text('Use System Theme'),
            subtitle: const Text('Match system dark/light mode'),
            value: preferences.useSystemTheme,
            onChanged: (value) {
              final newPrefs = preferences.copyWith(
                useSystemTheme: value,
                isDarkMode: value ? Theme.of(context).brightness == Brightness.dark : preferences.isDarkMode,
              );
              onPreferencesChanged(newPrefs);
            },
          ),
          if (!preferences.useSystemTheme)
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: preferences.isDarkMode,
              onChanged: (value) {
                final newPrefs = preferences.copyWith(isDarkMode: value);
                onPreferencesChanged(newPrefs);
              },
            ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get updates about your spending'),
            value: preferences.enableNotifications,
            onChanged: (value) {
              final newPrefs = preferences.copyWith(enableNotifications: value);
              onPreferencesChanged(newPrefs);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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
}
