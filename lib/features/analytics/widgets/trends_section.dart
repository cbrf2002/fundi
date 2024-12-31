import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class TrendsSection extends StatefulWidget {
  final Map<String, List<double>> weeklyTrends;
  final Map<String, List<double>> monthlyTrends;
  final Map<String, List<double>>? dailyProjections;

  const TrendsSection({
    super.key,
    required this.weeklyTrends,
    required this.monthlyTrends,
    this.dailyProjections,
  });

  @override
  _TrendsSectionState createState() => _TrendsSectionState();
}

class _TrendsSectionState extends State<TrendsSection> {
  bool _showWeekly = true;

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);
    final trends = _showWeekly ? widget.weeklyTrends : widget.monthlyTrends;
    final sortedKeys = trends.keys.toList()..sort();

    final projections = _generateProjections(trends, _showWeekly ? 4 : 3); // 4 weeks or 3 months

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showWeekly ? 'Weekly Trends' : 'Monthly Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _showWeekly,
                  onChanged: (value) {
                    setState(() {
                      _showWeekly = value!;
                    });
                  },
                ),
                const Text('Weekly'),
                Radio<bool>(
                  value: false,
                  groupValue: _showWeekly,
                  onChanged: (value) {
                    setState(() {
                      _showWeekly = value!;
                    });
                  },
                ),
                const Text('Monthly'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: _buildScrollableBarChart(context, sortedKeys, projections),
            ),
            const SizedBox(height: 16),
            ...sortedKeys.map((key) {
              final expenses = trends[key]![0];
              final income = trends[key]![1];
              return Column(
                children: [
                  _buildRow(context, key, formatter.formatAmount(expenses), formatter.formatAmount(income)),
                  if (key != sortedKeys.last) const Divider(),
                ],
              );
            }),
            if (projections.isNotEmpty) ...[
              const Divider(),
              Text(
                'Projections',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ...projections.entries.map((entry) {
                final expenses = entry.value[0];
                final income = entry.value[1];
                return _buildRow(
                  context,
                  entry.key,
                  formatter.formatAmount(expenses),
                  formatter.formatAmount(income),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableBarChart(
      BuildContext context, List<String> keys, Map<String, List<double>> projections) {
    final allKeys = keys + projections.keys.toList();
    final maxAmount = [
      ...widget.weeklyTrends.values,
      ...widget.monthlyTrends.values,
      ...projections.values,
      if (widget.dailyProjections != null) ...widget.dailyProjections!.values,
    ].expand((list) => list).reduce((a, b) => a > b ? a : b);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: allKeys.length * 80,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: maxAmount * 1.2,
            barGroups: allKeys.asMap().entries.map((entry) {
              final index = entry.key;
              final data = widget.weeklyTrends[entry.value] ??
                  widget.monthlyTrends[entry.value] ??
                  projections[entry.value] ??
                  widget.dailyProjections?[entry.value];
              final expenses = data?[0] ?? 0;
              final income = data?[1] ?? 0;

              return BarChartGroupData(
                x: index,
                barsSpace: 8,
                barRods: [
                  BarChartRodData(
                    toY: expenses,
                    color: index >= keys.length
                        ? Colors.red.withAlpha((0.5 * 255).toInt()) // Lighter for projections
                        : Colors.red.withAlpha((0.8 * 255).toInt()),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: income,
                    color: index >= keys.length
                        ? Colors.green.withAlpha((0.5 * 255).toInt()) // Lighter for projections
                        : Colors.green.withAlpha((0.8 * 255).toInt()),
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false), // Omit the top axis labels
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxAmount / 5,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        value.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < allKeys.length) {
                      final key = allKeys[value.toInt()];
                      return Text(
                        key,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxAmount / 5,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                left: BorderSide(color: Theme.of(context).dividerColor, width: 1),
                top: BorderSide(
                  color: Colors.transparent, // Transparent padding at the top
                  width: 20, // Add padding for top labels
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, List<double>> _generateProjections(Map<String, List<double>> trends, int periodsAhead) {
  final currentKeys = trends.keys.toList()..sort();
  if (currentKeys.isEmpty) return {};

  final lastKey = currentKeys.last;

  int year;
  int period;

  // Check if it's weekly or monthly format
  if (lastKey.contains('W')) {
    // Weekly format: "YYYY-WXX"
    final parts = lastKey.split('-');
    year = int.parse(parts[0]);
    period = int.parse(parts[1].substring(1)); // Remove "W" and parse the week number
  } else {
    // Monthly format: "YYYY-MM"
    final parts = lastKey.split('-');
    year = int.parse(parts[0]);
    period = int.parse(parts[1]); // Parse the month directly
  }

  final avgExpenses = trends.values.map((v) => v[0]).reduce((a, b) => a + b) / trends.length;
  final avgIncome = trends.values.map((v) => v[1]).reduce((a, b) => a + b) / trends.length;

  final projections = <String, List<double>>{};
  for (int i = 1; i <= periodsAhead; i++) {
    period++;
    if (_showWeekly && period > 52) {
      period = 1;
      year++;
    } else if (!_showWeekly && period > 12) {
      period = 1;
      year++;
    }

    final key = _showWeekly
        ? '$year-W${period.toString().padLeft(2, '0')}' // Weekly format
        : '$year-${period.toString().padLeft(2, '0')}'; // Monthly format
    projections[key] = [avgExpenses, avgIncome];
  }

  return projections;
  }

  Widget _buildRow(
    BuildContext context,
    String key,
    String expenses,
    String income,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key,
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
