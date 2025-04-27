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
  TrendsSectionState createState() => TrendsSectionState();
}

class TrendsSectionState extends State<TrendsSection> {
  bool _showWeekly = true;

  @override
  Widget build(BuildContext context) {
    final formatter = Provider.of<FormattingProvider>(context);
    final trends = _showWeekly ? widget.weeklyTrends : widget.monthlyTrends;
    final sortedKeys = trends.keys.toList()..sort();

    final projections = _generateProjections(
        trends, _showWeekly ? 4 : 3); // 4 weeks or 3 months

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
                  _buildRow(context, key, formatter.formatAmount(expenses),
                      formatter.formatAmount(income)),
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

  Widget _buildScrollableBarChart(BuildContext context, List<String> keys,
      Map<String, List<double>> projections) {
    final allKeys = keys + projections.keys.toList();

    // 1. Filter out non-finite values before calculating maxAmount
    final finiteValues = [
      ...widget.weeklyTrends.values,
      ...widget.monthlyTrends.values,
      ...projections.values,
      if (widget.dailyProjections != null) ...widget.dailyProjections!.values,
    ].expand((list) => list).where((v) => v.isFinite).toList();

    // 2. Calculate maxAmount safely, defaulting to 1.0 if no finite values
    double maxAmount = finiteValues.isEmpty
        ? 1.0
        : finiteValues.reduce((a, b) => a > b ? a : b);

    // Ensure maxAmount is positive and finite. Clamp to 1.0 if zero or negative.
    if (maxAmount <= 0) {
      maxAmount = 1.0;
    }
    // If maxAmount somehow became infinite (shouldn't happen with filtering, but as a safeguard)
    if (!maxAmount.isFinite) {
      maxAmount = 1000.0; // Or some other large default finite value
    }

    // Ensure interval is reasonable, avoid division by zero or very small/large numbers
    // Clamp interval to be at least 1.0 and finite.
    final double interval =
        (maxAmount / 5).clamp(1.0, maxAmount.isFinite ? maxAmount : 1000.0);

    // Calculate a finite maxY
    final double finalMaxY = maxAmount * 1.2;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: allKeys.length * 80.0, // Ensure width is double
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceBetween,
            maxY: finalMaxY, // Use finite maxY
            barGroups: allKeys.asMap().entries.map((entry) {
              final index = entry.key;
              final data = widget.weeklyTrends[entry.value] ??
                  widget.monthlyTrends[entry.value] ??
                  projections[entry.value] ??
                  widget.dailyProjections?[entry.value];

              // 3. Ensure toY values are finite, default to 0 otherwise
              final expenses =
                  (data != null && data.isNotEmpty && data[0].isFinite)
                      ? data[0]
                      : 0.0;
              final income =
                  (data != null && data.length > 1 && data[1].isFinite)
                      ? data[1]
                      : 0.0;

              return BarChartGroupData(
                x: index,
                barsSpace: 8,
                barRods: [
                  BarChartRodData(
                    toY: expenses, // Use sanitized finite value
                    color: index >= keys.length
                        ? Colors.red.withAlpha(
                            (0.5 * 255).toInt()) // Lighter for projections
                        : Colors.red.withAlpha((0.8 * 255).toInt()),
                    width: 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                  BarChartRodData(
                    toY: income, // Use sanitized finite value
                    color: index >= keys.length
                        ? Colors.green.withAlpha(
                            (0.5 * 255).toInt()) // Lighter for projections
                        : Colors.green.withAlpha((0.8 * 255).toInt()),
                    width: 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles:
                    SideTitles(showTitles: false), // Omit the top axis labels
              ),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: interval, // Use calculated finite interval
                  getTitlesWidget: (value, meta) {
                    // Check if value is finite and not zero when maxAmount is small
                    if (!value.isFinite || (value == 0 && maxAmount <= 1.0)) {
                      return const SizedBox.shrink();
                    }
                    // Check against the calculated finalMaxY
                    if (value > finalMaxY) {
                      return const SizedBox
                          .shrink(); // Avoid drawing labels outside the max Y
                    }
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
                    // Check if value is finite before using it
                    if (value.isFinite) {
                      final index = value.toInt(); // Convert double to int
                      if (index >= 0 && index < allKeys.length) {
                        final key = allKeys[index];
                        return Padding(
                          // Add padding for better spacing
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            key,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                    }
                    // Return empty if value is not finite or index is out of bounds
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            gridData: FlGridData(
              show: true,
              horizontalInterval: interval, // Use calculated finite interval
              getDrawingHorizontalLine: (value) {
                // Add check for finite value in grid lines too
                if (!value.isFinite) return FlLine(strokeWidth: 0);
                return FlLine(
                  color: Theme.of(context).dividerColor.withAlpha(51),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom:
                    BorderSide(color: Theme.of(context).dividerColor, width: 1),
                left:
                    BorderSide(color: Theme.of(context).dividerColor, width: 1),
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

  Map<String, List<double>> _generateProjections(
      Map<String, List<double>> trends, int periodsAhead) {
    final currentKeys = trends.keys.toList()..sort();
    if (currentKeys.isEmpty) return {}; // No data, no projections

    final lastKey = currentKeys.last;
    int year;
    int period;

    // Check if it's weekly or monthly format
    if (lastKey.contains('W')) {
      // Weekly format: "YYYY-WXX"
      final parts = lastKey.split('-');
      year = int.parse(parts[0]);
      period = int.parse(
          parts[1].substring(1)); // Remove "W" and parse the week number
    } else {
      // Monthly format: "YYYY-MM"
      final parts = lastKey.split('-');
      year = int.parse(parts[0]);
      period = int.parse(parts[1]); // Parse the month directly
    }

    double avgExpenses;
    double avgIncome;

    if (trends.length == 1) {
      // If only one data point, use it for projection
      avgExpenses = trends.values.first[0];
      avgIncome = trends.values.first[1];
    } else {
      // Calculate average based on existing data points
      avgExpenses = trends.values.map((v) => v[0]).reduce((a, b) => a + b) /
          trends.length;
      avgIncome = trends.values.map((v) => v[1]).reduce((a, b) => a + b) /
          trends.length;
    }

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
      // Project using the calculated average or single data point
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
