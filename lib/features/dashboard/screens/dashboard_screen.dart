import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/top_expenses_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../../core/models/transaction_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _dashboardController = DashboardController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureStatusBar();
  }

  void _configureStatusBar() {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: brightness,
      ),
    );
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _dashboardController.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No transactions yet'),
            );
          }

          var transactions = snapshot.data ?? [];
          transactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
          final stats = _dashboardController.calculateStats(transactions);
          final topExpenses = _dashboardController.getTopExpenses(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: Column(
              children: [
                const DashboardHeader(),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      StatCard(
                        title: 'Expenses',
                        amount: stats[2],
                        icon: Icons.money_off,
                        iconColor: Colors.red,
                      ),
                      StatCard(
                        title: 'Budget',
                        amount: stats[1],
                        icon: Icons.account_balance_wallet,
                      ),
                      StatCard(
                        title: 'Income',
                        amount: stats[0],
                        icon: Icons.attach_money,
                        iconColor: Colors.green,
                      ),
                      TopExpensesCard(topExpenses: topExpenses),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Recent Transactions',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RecentTransactionsList(transactions: transactions),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
