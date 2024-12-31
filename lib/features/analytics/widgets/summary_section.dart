import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class SummarySection extends StatelessWidget {
  final double totalExpenses;
  final double totalIncome;
  final int transactionCount;

  const SummarySection({
    super.key,
    required this.totalExpenses,
    required this.totalIncome,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);
    final balance = totalIncome - totalExpenses;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Total Income',
              formatter.formatAmount(totalIncome),
              Colors.green,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Total Expenses',
              formatter.formatAmount(totalExpenses),
              Colors.red,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Balance',
              formatter.formatAmount(balance),
              balance >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Transactions',
              transactionCount.toString(),
              Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
