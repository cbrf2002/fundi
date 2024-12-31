import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class MonthlyTrendsSection extends StatelessWidget {
  final Map<String, List<double>> monthlyTrends;

  const MonthlyTrendsSection({
    super.key,
    required this.monthlyTrends,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);
    final sortedMonths = monthlyTrends.keys.toList()..sort();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildTrendsChart(context, sortedMonths),
            ),
            const SizedBox(height: 16),
            ...sortedMonths.map((month) {
              final expenses = monthlyTrends[month]![0];
              final income = monthlyTrends[month]![1];
              return Column(
                children: [
                  _buildMonthRow(
                    context,
                    month,
                    formatter.formatAmount(expenses),
                    formatter.formatAmount(income),
                  ),
                  if (month != sortedMonths.last) const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendsChart(BuildContext context, List<String> months) {
    final maxAmount = monthlyTrends.values
        .expand((list) => list)
        .reduce((a, b) => a > b ? a : b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - (months.length - 1) * 8) / (months.length * 2);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: months.expand((month) {
            final expenses = monthlyTrends[month]![0];
            final income = monthlyTrends[month]![1];
            final expensesHeight = (expenses / maxAmount) * constraints.maxHeight;
            final incomeHeight = (income / maxAmount) * constraints.maxHeight;

            return [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: expensesHeight,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.7 * 255).toInt()),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    month.split('-')[1],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Container(
                width: barWidth,
                height: incomeHeight,
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((0.7 * 255).toInt()),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              if (month != months.last) const SizedBox(width: 8),
            ];
          }).toList(),
        );
      },
    );
  }

  Widget _buildMonthRow(
    BuildContext context,
    String month,
    String expenses,
    String income,
  ) {
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final parts = month.split('-');
    final monthName = monthNames[int.parse(parts[1]) - 1];
    final year = parts[0];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$monthName $year',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  expenses,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  income,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
