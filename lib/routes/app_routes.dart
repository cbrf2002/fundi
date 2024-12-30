import 'package:flutter/material.dart';
import 'package:fundi/main_screen/main_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/account/screens/account_screen.dart';

class AppRoutes {
  static const String main = '/main';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';
  static const String account = '/account';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        main: (context) => const MainScreen(),
        dashboard: (context) => const DashboardScreen(),
        transactions: (context) => const TransactionsScreen(),
        analytics: (context) => const AnalyticsScreen(),
        account: (context) => const AccountScreen(),
      };
}
