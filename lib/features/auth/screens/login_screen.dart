import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/util.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Easily track your expenses and make smart financial decisions here at Fundi.',
              style: AppTextStyles.bodyLarge.copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/emailLogin'); // Implement email login screen
              },
              icon: Icon(Icons.email),
              label: Text('Sign Up With Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                await authService.signInWithGoogle();
                Fluttertoast.showToast(msg: 'Signed in with Google');
                Navigator.pushReplacementNamed(context, '/main');
              },
              icon: Icon(Icons.login),
              label: Text('Continue With Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signIn'); // Implement sign in screen
              },
              child: Text('Already have an account? Sign In', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
            ),
          ],
        ),
      ),
    );
  }
}
