import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/providers/formatting_provider.dart'; // Import FormattingProvider
import '../controllers/transactions_controller.dart';
import 'transaction_list_item.dart';

class TransactionsListView extends StatelessWidget {
  final String timeFrame;
  final List<model.Transaction> transactions;
  // Add callbacks for tap and long press
  final Function(model.Transaction) onItemTap;
  final Function(model.Transaction) onItemLongPress;
  final TransactionsController _controller = TransactionsController();

  TransactionsListView({
    super.key,
    required this.timeFrame,
    required this.transactions,
    required this.onItemTap, // Require callbacks
    required this.onItemLongPress, // Require callbacks
  });

  @override
  Widget build(BuildContext context) {
    // Get formattingProvider here if needed by TransactionListItem directly,
    // or ensure it's provided higher up the tree.
    // final formattingProvider = Provider.of<FormattingProvider>(context);

    final filteredTransactions = _controller.filterTransactionsByTimeFrame(
      transactions,
      timeFrame,
    );

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
        final transaction = filteredTransactions[index];
        // Wrap with InkWell
        return InkWell(
          onTap: () => onItemTap(transaction),
          onLongPress: () => onItemLongPress(transaction),
          child: TransactionListItem(
            transaction: transaction,
            // Pass formattingProvider if TransactionListItem needs it directly
            // formattingProvider: formattingProvider,
          ),
        );
      },
    );
  }
}
