import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/formatting_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/circle_gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Listen to the stream of authentication state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      // Ensure the widget is still mounted before proceeding
      if (!mounted) return;

      if (user == null) {
        // User is signed out -> Go to Login
        _scheduleNavigation(AppRoutes.login);
      } else {
        // User is signed in, BUT check verification status
        bool verified = false;
        String? userId;
        try {
          // Reload user data to get the latest verification status
          await user.reload();
          // Get the potentially updated user object
          final freshUser = FirebaseAuth.instance.currentUser;

          // Check mount status again after await
          if (!mounted) return;

          if (freshUser != null && freshUser.emailVerified) {
            verified = true;
            userId = freshUser.uid;
          }
        } catch (e) {
          // Error reloading user (e.g., network issue) -> Treat as unverified
          print("Error reloading user during auth check: $e");
          verified = false;
        }

        // Check mount status again before final logic
        if (!mounted) return;

        if (verified && userId != null) {
          // User is signed in AND verified -> Initialize providers and go to Main
          try {
            // Initialize providers *before* navigating to main
            await Future.wait([
              Provider.of<ThemeProvider>(context, listen: false)
                  .initializeTheme(userId),
              Provider.of<FormattingProvider>(context, listen: false)
                  .initializeFormatting(userId),
            ]);
            if (mounted) _scheduleNavigation(AppRoutes.main);
          } catch (e) {
            print("Error initializing providers: $e");
            // Handle error, maybe sign out and go to login
            await FirebaseAuth.instance.signOut();
            if (mounted) _scheduleNavigation(AppRoutes.login);
          }
        } else {
          // User is signed in BUT NOT verified (or reload failed) -> Sign out and go to Login
          await FirebaseAuth.instance.signOut();
          if (mounted) _scheduleNavigation(AppRoutes.login);
        }
      }
    });
  }

  void _scheduleNavigation(String routeName) {
    // Schedule navigation to occur after the current frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if mounted AGAIN before navigating, as the callback might fire later
      if (mounted) {
        Navigator.pushReplacementNamed(context, routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the logo based on the theme
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode
        ? 'lib/assets/logo/logoDark.svg'
        : 'lib/assets/logo/logoLight.svg';

    // Set transparent status bar with appropriate icon brightness
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          const CircleGradientBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(logoPath, width: 150, height: 150),
                const SizedBox(height: 16),
                Text(
                  'Fundi',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
