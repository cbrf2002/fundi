import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0E5EC), Color(0xFFF1F2F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: RotatedBox(
                quarterTurns: 3,
                child: ImageFiltered( // Wrap with ImageFiltered
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // Adjust blur intensity
                  child: Image.asset(
                    'assets/images/jpg/allison-saeng-Zb4QHN8niIM-unsplash.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Top Center Background Image
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(
              'assets/images/png/login_bg.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: 250,
            ),
          ),
          // Content
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Larger Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/png/fundi_logotext_base.png',
                    width: 250, // Increased size
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Your expense tracking app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 128),
                // Buttons
                Column(
                  children: [
                    // Google Sign-In Button
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      icon: SvgPicture.asset(
                        'assets/images/svg/google.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text('Sign in with Google'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        minimumSize: const Size(200, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email Sign-In Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        minimumSize: const Size(200, 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Sign in with Email'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
