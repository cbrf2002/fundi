import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class CategoryExpenseItem extends StatelessWidget {
  final MapEntry<String, double> entry;
  final double totalExpenses;

  const CategoryExpenseItem({
    super.key,
    required this.entry,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    final percentage = (entry.value / totalExpenses * 100).toStringAsFixed(1);
    
    return ListTile(
      title: Text(entry.key),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formattingProvider.formatAmount(entry.value),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '$percentage%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
