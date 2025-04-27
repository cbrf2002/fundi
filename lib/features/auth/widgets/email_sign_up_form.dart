import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';
import 'auth_text_field.dart';
// Import AuthController instead of AuthService
import '../controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User

class EmailSignUpForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  // Add controller for display name
  final TextEditingController displayNameController = TextEditingController();

  // Instantiate AuthController
  final AuthController _authController = AuthController();

  EmailSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: displayNameController, // Add display name field
            label: 'Display Name',
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a display name.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email.';
              }
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
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
          AuthTextField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != passwordController.text) {
                return 'Passwords do not match.';
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
                // Capture context and messenger beforehand
                final messenger = ScaffoldMessenger.of(context);

                // Show immediate feedback
                messenger.showSnackBar(
                  const SnackBar(content: Text('Creating account...')),
                );

                User? user; // To store the result
                String? errorMessage; // To store potential error

                try {
                  // Use AuthController and pass display name
                  user = await _authController.signUpWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                    displayName: displayNameController.text.trim(),
                  );
                } catch (e) {
                  errorMessage = e.toString();
                }

                // Ensure the widget is still mounted before interacting with UI
                if (!context.mounted) return;

                // Hide the "Creating account..." SnackBar
                messenger.hideCurrentSnackBar();

                if (errorMessage != null) {
                  // Show error message if sign up failed
                  messenger.showSnackBar(
                    SnackBar(content: Text('Sign Up Failed: $errorMessage')),
                  );
                } else if (user != null) {
                  // Show success message
                  messenger.showSnackBar(
                    SnackBar(
                        content: Text(
                            'Account created! Please check ${user.email} for a verification link, then log in.')),
                  );
                } else {
                  // Handle unexpected null user without error (should not happen ideally)
                  messenger.showSnackBar(
                    const SnackBar(
                        content:
                            Text('Account creation completed, please log in.')),
                  );
                }
              }
            },
            child: const Text('Create Account'),
          ),
        ],
      ),
    );
  }
}
