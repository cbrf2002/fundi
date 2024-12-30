import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/models/budget_model.dart';
import '../widgets/add_transaction_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _configureStatusBar() {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent, // Use transparent or any preferred color
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent, // Use transparent or any preferred color
      ));
    }
  }

  late Future<void> _fetchData;
  List<model.Transaction> transactions = [];
  Budget budget = Budget(
      totalIncome: 0,
      totalExpenses: 0,
      netAmount: 0
  );

  @override
  void initState() {
    super.initState();
    _fetchData = _loadData();
  }

  Future<void> _loadData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('transactions').get();
    transactions = querySnapshot.docs.map((doc) => model.Transaction.fromMap(doc.data(), doc.id)).toList();
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort transactions by newest first
    _calculateBudget();
  }

  void _calculateBudget() {
    double totalIncome = 0;
    double totalExpenses = 0;
    transactions.forEach((transaction) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpenses += transaction.amount;
      }
    });
    setState(() {
      budget = Budget(
        totalIncome: totalIncome,
        totalExpenses: totalExpenses,
        netAmount: totalIncome - totalExpenses,
      );
    });
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    _configureStatusBar();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

    return Scaffold(
      body: FutureBuilder(
        future: _fetchData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0), // Adjust this value if needed to avoid the status bar
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
                          const SizedBox(height: 16),
                          Text(formattedDate, style: Theme.of(context).textTheme.titleSmall),
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
                          Card(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.money_off, color: Theme.of(context).colorScheme.primary, size: 24),
                                const SizedBox(height: 8),
                                Text('Expenses', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                Text(_formatCurrency(budget.totalExpenses), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary, size: 24),
                                const SizedBox(height: 8),
                                Text('Budget', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                Text(_formatCurrency(budget.netAmount), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary, size: 24),
                                const SizedBox(height: 8),
                                Text('Income', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                                const SizedBox(height: 8),
                                Text(_formatCurrency(budget.totalIncome), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                              ],
                            ),
                          ),
                          Card(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary, size: 24),
                                const SizedBox(height: 8),
                                const Text('Top Expenses'),
                                const SizedBox(height: 8),
                                ...transactions
                                    .where((t) => t.type == 'expense')
                                    .take(3)
                                    .map((t) => Text('${t.category}: ${_formatCurrency(t.amount)}')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium),
                    Expanded(
                      child: transactions.isNotEmpty
                          ? ListView.separated(
                              itemCount: transactions.length > 5 ? 5 : transactions.length,
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
                                return Divider();
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
          _loadData(); // Refresh data after adding transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
