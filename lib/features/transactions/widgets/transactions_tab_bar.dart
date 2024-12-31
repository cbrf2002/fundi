import 'package:flutter/material.dart';

class TransactionsTabBar extends StatelessWidget implements PreferredSizeWidget {
  const TransactionsTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBar(
      labelColor: Theme.of(context).colorScheme.onPrimary,
      unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withAlpha((0.6 * 255).toInt()),
      tabs: const [
        Tab(text: 'Day'),
        Tab(text: 'Week'),
        Tab(text: 'Month'),
        Tab(text: 'Year'),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
