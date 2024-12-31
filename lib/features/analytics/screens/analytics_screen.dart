import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/summary_section.dart';
import '../widgets/category_expenses_section.dart';
import '../widgets/trends_section.dart';
import '../widgets/daily_expenses_section.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final AnalyticsController _analyticsController = AnalyticsController();
  Map<String, List<double>>? _dailyProjections;
  Map<String, List<double>>? _monthlyTrends;
  Map<String, List<double>>? _weeklyTrends;
  Map<String, double>? _averageExpensesByDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final monthlyTrends = await _analyticsController.getMonthlyTrends();
      final weeklyTrends = await _analyticsController.getWeeklyTrends();
      final averageExpensesByDay = await _analyticsController.getAverageExpensesByDay();
      final dailyProjections = await _analyticsController.getDailyProjections(7); // Project for 7 days

      if (mounted) {
        setState(() {
          _monthlyTrends = monthlyTrends;
          _weeklyTrends = weeklyTrends;
          _averageExpensesByDay = averageExpensesByDay;
          _dailyProjections = dailyProjections;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Transaction>>(
              stream: _analyticsController.getTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions yet'));
                }

                final totalExpenses = _analyticsController.calculateTotalExpenses(transactions);
                final totalIncome = _analyticsController.calculateTotalIncome(transactions);
                final categoryExpenses = _analyticsController.calculateCategoryExpenses(transactions);

                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    children: [
                      SummarySection(
                        totalExpenses: totalExpenses,
                        totalIncome: totalIncome,
                        transactionCount: transactions.length,
                      ),
                      if (categoryExpenses.isNotEmpty)
                        CategoryExpensesSection(
                          categoryExpenses: categoryExpenses,
                          totalExpenses: totalExpenses,
                        ),
                      if (_weeklyTrends != null && _monthlyTrends != null)
                        TrendsSection(
                          weeklyTrends: _weeklyTrends!,
                          monthlyTrends: _monthlyTrends!,
                          dailyProjections: _dailyProjections,
                        ),
                      if (_averageExpensesByDay != null && _averageExpensesByDay!.isNotEmpty)
                        DailyExpensesSection(
                          averageExpensesByDay: _averageExpensesByDay!,
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
