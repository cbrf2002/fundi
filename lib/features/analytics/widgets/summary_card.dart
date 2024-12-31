import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
}
