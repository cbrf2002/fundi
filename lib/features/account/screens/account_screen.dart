import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Change Currency'),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Open currency selection.
              },
            ),
            ListTile(
              title: Text('Toggle Dark Mode'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
