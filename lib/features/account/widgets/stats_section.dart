import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';
import 'stats_card.dart';

class StatsSection extends StatelessWidget {
  final int transactionCount;
  final double monthlyTotal;
  final int categoryCount;

  const StatsSection({
    super.key,
    required this.transactionCount,
    required this.monthlyTotal,
    required this.categoryCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'Total Transactions',
                  value: transactionCount.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'This Month',
                  value: Provider.of<FormattingProvider>(context).formatAmount(monthlyTotal),
                  icon: Icons.calendar_today,
                  color: monthlyTotal >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsCard(
                  title: 'Categories',
                  value: categoryCount.toString(),
                  icon: Icons.category,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
