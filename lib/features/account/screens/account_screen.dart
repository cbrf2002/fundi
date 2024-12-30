import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Change Currency'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Implement currency selection logic
            },
          ),
          SwitchListTile(
            title: const Text('Toggle Dark Mode'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (bool value) {
              // Implement theme toggle logic
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
