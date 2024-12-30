import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(
        context,
        '/login', // Update navigation logic based on user state
      );
    });

    return Scaffold(
      body: Center(
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
    );
  }
}
