import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/formatting_provider.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color? iconColor;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final formattingProvider = Provider.of<FormattingProvider>(context);
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8), // Fixed padding instead of responsive
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive sizes based on card dimensions
            final maxIconSize = constraints.maxHeight * 0.2;  
            final maxTitleSize = constraints.maxHeight * 0.12; 
            final maxAmountSize = constraints.maxHeight * 0.3; 

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: maxIconSize.clamp(14, 24),  
                ),
                const SizedBox(height: 4),  // Fixed spacing
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: maxTitleSize.clamp(12, 16),  
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),  // Fixed spacing
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formattingProvider.formatAmount(amount),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1,
                              fontSize: maxAmountSize.clamp(16, 24),  
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
