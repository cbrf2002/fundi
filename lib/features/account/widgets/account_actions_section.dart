import 'package:flutter/material.dart';

class AccountActionsSection extends StatelessWidget {
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;

  const AccountActionsSection({
    super.key,
    required this.onChangePassword,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Account'),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Change Password'),
          onTap: onChangePassword,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FilledButton(
            onPressed: onLogout,
            child: const Text('Log Out'),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
