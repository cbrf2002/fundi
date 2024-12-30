import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/services/firestore_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<List<model.Transaction>> _transactionsStream;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _transactionsStream = _firestoreService.getTransactions();
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        String formattedDate = DateFormat('EEE, MMM d, yyyy').format(transaction.date);
        return ListTile(
          title: Text(transaction.category, style: Theme.of(context).textTheme.bodyMedium),
          subtitle: Text(
            'Amount: ${transaction.amount.toStringAsFixed(2)}\nDate: $formattedDate',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          isThreeLine: true, // Ensures the subtitle fits without truncation
        );
      },
    );
  }
}
