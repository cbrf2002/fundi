import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await authService.signInWithGoogle();
                Navigator.pushReplacementNamed(context, '/main');
              },
              child: Text('Login with Google'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/emailLogin'); // Implement email login screen
              },
              child: Text('Login with Email'),
            ),
          ],
        ),
      ),
    );
  }
}
