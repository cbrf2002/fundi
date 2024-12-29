import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const Fundi());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

class Fundi extends StatelessWidget {
  const Fundi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fundi',
      theme: MaterialTheme(TextTheme()).light(),
      darkTheme: MaterialTheme(TextTheme()).dark(),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
