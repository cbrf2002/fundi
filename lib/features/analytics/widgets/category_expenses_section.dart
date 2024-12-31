import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class CategoryExpensesSection extends StatelessWidget {
  final Map<String, double> categoryExpenses;
  final double totalExpenses;

  const CategoryExpensesSection({
    super.key,
    required this.categoryExpenses,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildPieChart(context),
            ),
            const SizedBox(height: 16),
            ...categoryExpenses.entries.map((entry) {
              final percentage = (entry.value / totalExpenses * 100);
              return Column(
                children: [
                  _buildCategoryRow(
                    context,
                    entry.key,
                    formatter.formatAmount(entry.value),
                    percentage,
                  ),
                  if (entry.key != categoryExpenses.keys.last) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final List<PieChartSectionData> sections = categoryExpenses.entries.map((entry) {
      final percentage = (entry.value / totalExpenses * 100);
      final shouldShowLabel = percentage > 5; // Display label only for sections > 5%

      return PieChartSectionData(
        value: entry.value,
        title: shouldShowLabel ? '${percentage.toStringAsFixed(1)}%' : '',
        color: Colors.primaries[categoryExpenses.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        radius: 50, // Adjust for better spacing
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2, // Slight spacing between sections
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    String amount,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Text(
                amount,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
