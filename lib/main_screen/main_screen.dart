import 'package:flutter/material.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/account/screens/account_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final _screens = [
    const DashboardScreen(key: PageStorageKey('DashboardScreen')),
    const TransactionsScreen(key: PageStorageKey('TransactionsScreen')),
    const AnalyticsScreen(key: PageStorageKey('AnalyticsScreen')),
    const AccountScreen(key: PageStorageKey('AccountScreen')),
  ];

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),
    );
  }
}
