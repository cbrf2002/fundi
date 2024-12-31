import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/providers/formatting_provider.dart';

class TransactionListItem extends StatelessWidget {
  final model.Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    final bool isExpense = transaction.type == model.TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;
    final icon = isExpense ? Icons.remove : Icons.add;
    final time = DateFormat('HH:mm').format(transaction.date);
    final date = DateFormat('MMM d, y').format(transaction.date);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withAlpha((0.2 * 255).toInt()),
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
  }
}
