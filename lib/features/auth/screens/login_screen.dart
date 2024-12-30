import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fundi/core/services/auth_service.dart';
import '../widgets/email_sign_in_form.dart';
import '../widgets/email_sign_up_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool isEmailExpanded = false;

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
        statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

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
    // Determine the logo based on the theme
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode ? 'lib/assets/logo/logoDark.svg' : 'lib/assets/logo/logoLight.svg';

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Image.asset(
              'lib/assets/images/ell2.png',
              width: 500,
              height: 500,
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees in radians
              child: Image.asset(
                'lib/assets/images/ell2.png',
                width: 500,
                height: 500,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    logoPath,
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Easily track your expenses and make smart financial decisions with Fundi.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedSize(
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
                                  child: Text(isSignUp
                                      ? 'Already have an account? Sign In'
                                      : 'Don’t have an account? Sign Up'),
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
                                  child: const Text('Sign In With Email'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () async {
                                    final user = await AuthService().signInWithGoogle();
                                    if (user != null) {
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
                                  child: const Text('Create Account'),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
