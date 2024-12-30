import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSummaryCard(
              context,
              'Total Expenses',
              1000.0,
              Icons.money,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildSummaryCard(
              context,
              'Total Income',
              2000.0,
              Icons.attach_money,
              Colors.green,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildCategoryExpenseItem(
                    context,
                    const MapEntry('Category 1', 500.0),
                    1000.0,
                  ),
                  _buildCategoryExpenseItem(
                    context,
                    const MapEntry('Category 2', 300.0),
                    1000.0,
                  ),
                  _buildCategoryExpenseItem(
                    context,
                    const MapEntry('Category 3', 200.0),
                    1000.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, double amount, IconData icon, Color color) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              formattingProvider.formatAmount(amount),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryExpenseItem(BuildContext context, MapEntry<String, double> entry, double totalExpenses) {
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
