import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';
import 'auth_text_field.dart';
import '../controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailSignInForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Instantiate AuthController
  final AuthController _authController = AuthController();

  EmailSignInForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email.';
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
                  .hasMatch(value)) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: passwordController,
            label: 'Password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password.';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Show immediate feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Signing in...')),
                );
                try {
                  // Use AuthController
                  final User? user = await _authController.signInWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );

                  // Hide the "Signing in..." SnackBar before showing result
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  } else {
                    return; // Avoid further processing if context is lost
                  }

                  if (user != null) {
                    // context.mounted check already done
                    // Check email verification status AFTER successful sign-in
                    final bool isVerified =
                        await _authController.isEmailVerified();

                    if (!context.mounted) {
                      return; // Check context again after async gap
                    }

                    if (isVerified) {
                      // Initialize preferences before navigation
                      await Future.wait([
                        Provider.of<ThemeProvider>(context, listen: false)
                            .initializeTheme(user.uid),
                        Provider.of<FormattingProvider>(context, listen: false)
                            .initializeFormatting(user.uid),
                      ]);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Successfully signed in!')),
                      );
                      Navigator.pushReplacementNamed(
                          context, '/main'); // Use pushReplacementNamed
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Please verify your email (${user.email}). Check your inbox or spam folder.')),
                      );
                      await _authController
                          .signOut(); // Sign out unverified user
                    }
                  }
                  // No 'else' needed here, errors are thrown
                } catch (e) {
                  if (context.mounted) {
                    // Hide the "Signing in..." SnackBar before showing error
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Sign In Failed: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }
}
