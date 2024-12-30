import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/services/firestore_service.dart';
import '../../../core/providers/formatting_provider.dart';
import '../../dashboard/widgets/add_transaction_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<List<model.Transaction>> _transactionsStream;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _transactionsStream = _firestoreService.getTransactions();
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Transactions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
            tabs: const [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddTransactionDialog,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<List<model.Transaction>>(
          stream: _transactionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final transactions = snapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _transactionsStream = _firestoreService.getTransactions();
                  });
                },
                child: TabBarView(
                  children: [
                    TransactionsListView(timeFrame: 'day', transactions: transactions),
                    TransactionsListView(timeFrame: 'week', transactions: transactions),
                    TransactionsListView(timeFrame: 'month', transactions: transactions),
                    TransactionsListView(timeFrame: 'year', transactions: transactions),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  final String timeFrame;
  final List<model.Transaction> transactions;

  const TransactionsListView({super.key, required this.timeFrame, required this.transactions});

  List<model.Transaction> _filterTransactions() {
    final now = DateTime.now();
    final startDate = switch (timeFrame) {
      'day' => DateTime(now.year, now.month, now.day),
      'week' => now.subtract(const Duration(days: 7)),
      'month' => DateTime(now.year, now.month, 1),
      'year' => DateTime(now.year, 1, 1),
      _ => now,
    };

    return transactions
        .where((t) => t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _filterTransactions();
    final formattingProvider = Provider.of<FormattingProvider>(context);

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Text('No transactions for this period'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        var transaction = filteredTransactions[index];
        final bool isExpense = transaction.type == model.TransactionType.expense;
        final color = isExpense ? Colors.red : Colors.green;
        final icon = isExpense ? Icons.remove : Icons.add;
        final time = DateFormat('HH:mm').format(transaction.date);
        final date = DateFormat('MMM d, y').format(transaction.date);

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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                time,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          trailing: Text(
            formattingProvider.formatAmount(transaction.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
          ),
        );
      },
    );
  }
}
