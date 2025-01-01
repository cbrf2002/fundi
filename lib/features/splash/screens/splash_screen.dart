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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await Future.wait([
        Provider.of<ThemeProvider>(context, listen: false)
            .initializeTheme(currentUser.uid),
        Provider.of<FormattingProvider>(context, listen: false)
            .initializeFormatting(currentUser.uid),
      ]);

      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the logo based on the theme
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String logoPath = isDarkMode ? 'lib/assets/logo/logoDark.svg' : 'lib/assets/logo/logoLight.svg';

    // Set transparent status bar with appropriate icon brightness
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
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
