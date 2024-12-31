import 'package:flutter/material.dart';
import '../controllers/transactions_controller.dart';
import '../widgets/transactions_list_view.dart';
import '../widgets/transactions_tab_bar.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../dashboard/widgets/add_transaction_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<List<model.Transaction>> _transactionsStream;
  final TransactionsController _transactionsController = TransactionsController();

  @override
  void initState() {
    super.initState();
    _transactionsStream = _transactionsController.getTransactions();
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
          bottom: const TransactionsTabBar(),
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
                    _transactionsStream = _transactionsController.getTransactions();
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
