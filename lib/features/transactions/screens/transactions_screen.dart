import 'package:flutter/material.dart';
import '../controllers/transactions_controller.dart';
import '../widgets/transactions_list_view.dart';
import '../widgets/transactions_tab_bar.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../dashboard/widgets/add_transaction_dialog.dart';
import '../../../core/services/firestore_service.dart';
import '../widgets/edit_transaction_dialog.dart'; // Make sure this is imported

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Stream<List<model.Transaction>> _transactionsStream;
  final TransactionsController _transactionsController =
      TransactionsController();

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

  void _showDeleteConfirmationDialog(
      BuildContext context, model.Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction?'),
          content: const Text(
              'Are you sure you want to permanently delete this transaction?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close the dialog
                try {
                  final firestoreService = FirestoreService();
                  await firestoreService.deleteTransaction(transaction.id);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Transaction deleted successfully.')),
                    );
                    // The stream builder will automatically update the list
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting transaction: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTransactionDialog(
      BuildContext context, model.Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Assuming EditTransactionDialog exists and takes a transaction
        return EditTransactionDialog(transaction: transaction);
      },
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
                    _transactionsStream =
                        _transactionsController.getTransactions();
                  });
                },
                child: TabBarView(
                  children: [
                    TransactionsListView(
                      timeFrame: 'day',
                      transactions: transactions,
                      onItemTap: (transaction) =>
                          _showEditTransactionDialog(context, transaction),
                      onItemLongPress: (transaction) =>
                          _showDeleteConfirmationDialog(context, transaction),
                    ),
                    TransactionsListView(
                      timeFrame: 'week',
                      transactions: transactions,
                      onItemTap: (transaction) =>
                          _showEditTransactionDialog(context, transaction),
                      onItemLongPress: (transaction) =>
                          _showDeleteConfirmationDialog(context, transaction),
                    ),
                    TransactionsListView(
                      timeFrame: 'month',
                      transactions: transactions,
                      onItemTap: (transaction) =>
                          _showEditTransactionDialog(context, transaction),
                      onItemLongPress: (transaction) =>
                          _showDeleteConfirmationDialog(context, transaction),
                    ),
                    TransactionsListView(
                      timeFrame: 'year',
                      transactions: transactions,
                      onItemTap: (transaction) =>
                          _showEditTransactionDialog(context, transaction),
                      onItemLongPress: (transaction) =>
                          _showDeleteConfirmationDialog(context, transaction),
                    ),
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
