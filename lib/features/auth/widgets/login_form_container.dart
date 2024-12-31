import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'email_sign_in_form.dart';
import 'email_sign_up_form.dart';

class LoginFormContainer extends StatefulWidget {
  const LoginFormContainer({super.key});

  @override
  State<LoginFormContainer> createState() => _LoginFormContainerState();
}

class _LoginFormContainerState extends State<LoginFormContainer> {
  final AuthController _authController = AuthController();
  bool isSignUp = false;
  bool isEmailExpanded = false;

  void toggleEmailExpansion() {
    setState(() {
      isEmailExpanded = !isEmailExpanded;
      if (!isEmailExpanded) {
        isSignUp = false; // Reset to sign-in when collapsing
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: isEmailExpanded
            ? Column(
                key: const ValueKey('ExpandedForm'),
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSignUp
                        ? EmailSignUpForm(key: const ValueKey('signUp'))
                        : EmailSignInForm(key: const ValueKey('signIn')),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignUp = !isSignUp;
                      });
                    },
                    child: Text(
                      isSignUp
                          ? 'Already have an account? Sign In'
                          : "Don't have an account? Sign Up",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: toggleEmailExpansion,
                    child: const Text('Back to Login Options'),
                  ),
                ],
              )
            : Column(
                key: const ValueKey('CollapsedForm'),
                children: [
                  OutlinedButton(
                    onPressed: toggleEmailExpansion,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Sign In With Email'),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      final user = await _authController.signInWithGoogle();
                      if (user != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Welcome, ${user.displayName}!')),
                        );
                        Navigator.pushNamed(context, '/dashboard');
                      }
                    },
                    icon: const Icon(Icons.g_translate),
                    label: const Text('Sign In With Google'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignUp = true;
                        isEmailExpanded = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Create Account'),
                  ),
                ],
              ),
      ),
    );
  }
}
