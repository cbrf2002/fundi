import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';
import 'auth_text_field.dart';
import 'package:fundi/core/services/auth_service.dart';

class EmailSignUpForm extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
            controller: emailController,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email.';
              if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(value)) {
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
              if (value == null || value.isEmpty) return 'Please enter your password.';
              if (value.length < 6) return 'Password must be at least 6 characters.';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: confirmPasswordController,
            label: 'Confirm Password',
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please confirm your password.';
              if (value != passwordController.text) return 'Passwords do not match.';
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
                final user = await AuthService().signUpWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null && context.mounted) {
                  // Initialize preferences before navigation
                  await Future.wait([
                    Provider.of<ThemeProvider>(context, listen: false)
                        .initializeTheme(user.uid),
                    Provider.of<FormattingProvider>(context, listen: false)
                        .initializeFormatting(user.uid),
                  ]);

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created successfully!')),
                  );
                  Navigator.pushNamed(context, '/main');
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to create account. Email might be already in use.')),
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
