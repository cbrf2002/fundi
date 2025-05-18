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
    final formattingProvider = Provider.of<FormattingProvider>(context);

    final filteredTransactions = _controller.filterTransactionsByTimeFrame(
      transactions,
      timeFrame,
    );

    if (filteredTransactions.isEmpty) {
      return const Center(
        child: Text('No transactions for this period'),
      );
    }

    final totalExpenses =
        _controller.calculateTotalExpenses(filteredTransactions);
    final totalIncome = _controller.calculateTotalIncome(filteredTransactions);
    final netTotal = _controller.calculateNetTotal(filteredTransactions);

    Color netTotalColor;
    if (netTotal > 0) {
      netTotalColor = Colors.green;
    } else if (netTotal < 0) {
      netTotalColor = Colors.red;
    } else {
      netTotalColor = Theme.of(context).colorScheme.onSurface;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Income:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                formattingProvider.formatAmount(totalIncome),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Expenses:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                formattingProvider.formatAmount(totalExpenses),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Total:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                formattingProvider.formatAmount(netTotal),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: netTotalColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
