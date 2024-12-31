import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/providers/formatting_provider.dart';

class RecentTransactionTile extends StatelessWidget {
  final Transaction transaction;

  const RecentTransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
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
}
