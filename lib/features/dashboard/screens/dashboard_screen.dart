import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/formatting_provider.dart';
import '../widgets/add_transaction_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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

  List<double> _calculateStats(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpenses += transaction.amount;
      }
    }

    double balance = totalIncome - totalExpenses;
    return [totalIncome, balance, totalExpenses];
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

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
        stream: _firestoreService.getTransactions(),
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
          final stats = _calculateStats(transactions);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
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
                      const SizedBox(height: 64),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildStatCard(
                        'Expenses',
                        stats[2],
                        Icons.money_off,
                        Colors.red,
                      ),
                      _buildStatCard(
                        'Budget',
                        stats[1],
                        Icons.account_balance_wallet,
                        null,
                      ),
                      _buildStatCard(
                        'Income',
                        stats[0],
                        Icons.attach_money,
                        Colors.green,
                      ),
                      _buildTopExpensesCard(transactions),
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
                        child: Card(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          elevation: 4,
                          margin: const EdgeInsets.only(left: 16, right: 16, top: 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                Expanded(
                                  child: transactions.isNotEmpty
                                      ? ListView.separated(
                                          itemCount: transactions.length > 7 ? 7 : transactions.length,
                                          itemBuilder: (context, index) {
                                            var transaction = transactions[index];
                                            return _buildRecentTransactionTile(transaction);
                                          },
                                          separatorBuilder: (context, index) {
                                            return const Divider();
                                          },
                                        )
                                      : const Center(
                                          child: Text('No recent transactions'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildStatCard(String title, double amount, IconData icon, Color? iconColor) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              formattingProvider.formatAmount(amount),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionTile(Transaction transaction) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    final bool isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final icon = isExpense ? Icons.remove : Icons.add;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(
          icon,
          color: color,
        ),
      ),
      title: Text(
        transaction.category,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        DateFormat('MMM d, y').format(transaction.date),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        formattingProvider.formatAmount(transaction.amount),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
            ),
      ),
    );
  }

  Widget _buildTopExpensesCard(List<Transaction> transactions) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    final topExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .take(3)
        .toList();

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Top Expenses',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 8),
            ...topExpenses.map(
              (t) => Text(
                '${t.category}: ${formattingProvider.formatAmount(t.amount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
