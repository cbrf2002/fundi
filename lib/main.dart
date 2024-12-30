import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/utils/theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const Fundi());
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Light icons for dark mode
      statusBarBrightness: Brightness.dark, // Dark icons for light mode
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
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
