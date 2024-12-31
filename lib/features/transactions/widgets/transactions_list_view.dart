import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../controllers/transactions_controller.dart';
import 'transaction_list_item.dart';

class TransactionsListView extends StatelessWidget {
  final String timeFrame;
  final List<model.Transaction> transactions;
  final TransactionsController _controller = TransactionsController();

  TransactionsListView({
    super.key,
    required this.timeFrame,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
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
        return TransactionListItem(
          transaction: filteredTransactions[index],
        );
      },
    );
  }
}
