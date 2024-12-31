import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEE, MMM d, yyyy').format(now);

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Dashboard', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(formattedDate, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
