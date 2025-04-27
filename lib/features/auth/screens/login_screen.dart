import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/circle_gradient_background.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form_container.dart';
// Import AuthController
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instantiate AuthController
  final AuthController _authController = AuthController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStatusBar();
  }

  void _configureStatusBar() {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

  // Method to show Forgot Password Dialog
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Enter your email',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty &&
                  RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(email)) {
                Navigator.pop(context); // Close dialog immediately
                try {
                  // Show loading indicator maybe?
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sending password reset email...')),
                  );
                  await _authController.sendPasswordResetEmail(email);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // Hide loading message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Password reset email sent (if account exists).')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // Hide loading message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              } else {
                // Keep dialog open if email is invalid
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email.')),
                );
              }
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevent resize when keyboard appears to avoid background distortion
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const CircleGradientBackground(),
          Center(
            // Wrap the Padding/Column with SingleChildScrollView
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoginHeader(),
                    const SizedBox(height: 24),
                    const LoginFormContainer(),
                    const SizedBox(height: 16),
                    // Add Forgot Password button
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
