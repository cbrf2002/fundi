import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class DailyExpensesSection extends StatelessWidget {
  final Map<String, double> averageExpensesByDay;

  const DailyExpensesSection({
    super.key,
    required this.averageExpensesByDay,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);
    final maxAmount = averageExpensesByDay.values.isEmpty
        ? 0.0
        : averageExpensesByDay.values.reduce((a, b) => a > b ? a : b);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Daily Expenses',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildDailyChart(context, maxAmount),
              ),
            ),
            const SizedBox(height: 16),
            ...averageExpensesByDay.entries.map((entry) {
              // Ensure percentage is non-negative and handle maxAmount <= 0
              final percentage =
                  (maxAmount > 0) ? max(0.0, entry.value / maxAmount) : 0.0;
              return Column(
                children: [
                  _buildDayRow(
                    context,
                    entry.key,
                    formatter.formatAmount(entry.value),
                    percentage,
                  ),
                  if (entry.key != averageExpensesByDay.keys.last)
                    const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(BuildContext context, double maxAmount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - 6 * 8;
        final barWidth = availableWidth / 7;
        final chartHeight = constraints.maxHeight - 28;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: averageExpensesByDay.entries.map((entry) {
            // Ensure normalized value is non-negative and handle maxAmount <= 0
            final normalizedValue =
                (maxAmount > 0) ? max(0.0, entry.value / maxAmount) : 0.0;
            final height = normalizedValue * chartHeight;
            final dayAbbr = entry.key.substring(0, 3);

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.7 * 255).toInt()),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    dayAbbr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDayRow(
    BuildContext context,
    String day,
    String amount,
    double percentage, // Percentage is now guaranteed non-negative
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                amount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage, // Use the safe percentage
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
