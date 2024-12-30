import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/models/budget_model.dart';
import '../../../core/services/firestore_service.dart';
import '../widgets/add_transaction_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
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

  Budget _calculateBudget(List<model.Transaction> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    }

    return Budget(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netAmount: totalIncome - totalExpenses,
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

    return Scaffold(
      body: StreamBuilder<List<model.Transaction>>(
        stream: _firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var transactions = snapshot.data ?? [];
            transactions.sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
            final budget = _calculateBudget(transactions);

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {}); // Trigger a rebuild to refresh the stream
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 16),
                          Text(formattedDate, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        children: [
                          _buildCard(
                            title: 'Expenses',
                            amount: budget.totalExpenses,
                            icon: Icons.money_off,
                            context: context,
                          ),
                          _buildCard(
                            title: 'Budget',
                            amount: budget.netAmount,
                            icon: Icons.account_balance_wallet,
                            context: context,
                          ),
                          _buildCard(
                            title: 'Income',
                            amount: budget.totalIncome,
                            icon: Icons.attach_money,
                            context: context,
                          ),
                          _buildTopExpensesCard(transactions, context),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                    Expanded(
                      child: transactions.isNotEmpty
                          ? ListView.separated(
                              itemCount: transactions.length > 6 ? 6 : transactions.length,
                              itemBuilder: (context, index) {
                                var transaction = transactions[index];
                                return ListTile(
                                  title: Text(transaction.category),
                                  trailing: Text(
                                    '${transaction.type == 'income' ? '+' : '-'}${_formatCurrency(transaction.amount)}',
                                    style: TextStyle(
                                      color: transaction.type == 'income'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Divider();
                              },
                            )
                          : const Center(child: Text('No recent transactions')),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddTransactionDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required double amount,
    required IconData icon,
    required BuildContext context,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopExpensesCard(List<model.Transaction> transactions, BuildContext context) {
    final topExpenses = transactions
        .where((t) => t.type == 'expense')
        .take(3)
        .toList();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          const Text('Top Expenses'),
          const SizedBox(height: 8),
          ...topExpenses.map(
            (t) => Text(
              '${t.category}: ${_formatCurrency(t.amount)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
