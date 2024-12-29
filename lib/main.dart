import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/theme.dart';
import 'routes/app_routes.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'main_screen/main_screen.dart';

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
      initialRoute: AppRoutes.splash,
      routes: {
        '/splash': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}
