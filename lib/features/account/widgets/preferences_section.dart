import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/providers/formatting_provider.dart';

class PreferencesSection extends StatelessWidget {
  final UserPreferences preferences;
  final Function(UserPreferences) onPreferencesChanged;
  final VoidCallback onShowCurrencyPicker;
  final VoidCallback onShowDecimalSeparatorPicker;
  final VoidCallback onShowThousandsSeparatorPicker;

  const PreferencesSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    required this.onShowCurrencyPicker,
    required this.onShowDecimalSeparatorPicker,
    required this.onShowThousandsSeparatorPicker,
  });

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Currency & Format'),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            subtitle: Text(
                '${preferences.currency} (${formattingProvider.getCurrencySymbol()})'),
            onTap: onShowCurrencyPicker,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.paid_rounded),
            title: const Text('Show Cents'),
            subtitle: const Text('Display decimal places in amounts'),
            value: preferences.showCents,
            onChanged: (value) {
              final newPrefs = preferences.copyWith(showCents: value);
              onPreferencesChanged(newPrefs);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_rounded),
            title: const Text('Decimal Separator'),
            subtitle: Text(preferences.decimalSeparatorDescription),
            onTap: onShowDecimalSeparatorPicker,
          ),
          ListTile(
            leading: const Icon(Icons.space_bar_rounded),
            title: const Text('Thousands Separator'),
            subtitle: Text(preferences.thousandsSeparatorDescription),
            onTap: onShowThousandsSeparatorPicker,
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6_rounded),
            title: const Text('Use System Theme'),
            subtitle: const Text('Match system dark/light mode'),
            value: preferences.useSystemTheme,
            onChanged: (value) {
              final newPrefs = preferences.copyWith(
                useSystemTheme: value,
                isDarkMode: value
                    ? Theme.of(context).brightness == Brightness.dark
                    : preferences.isDarkMode,
              );
              onPreferencesChanged(newPrefs);
            },
          ),
          if (!preferences.useSystemTheme)
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded),
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
            secondary: const Icon(Icons.notifications_rounded),
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
