import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart';
import 'recent_transaction_tile.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> transactions;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      elevation: 4,
      margin: const EdgeInsets.only(left: 16, right: 16, top: 48),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: transactions.isNotEmpty
                  ? ListView.separated(
                      itemCount: transactions.length > 7 ? 7 : transactions.length,
                      itemBuilder: (context, index) {
                        return RecentTransactionTile(
                          transaction: transactions[index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    )
                  : const Center(
                      child: Text('No recent transactions'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
