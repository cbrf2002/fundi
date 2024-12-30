import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/utils/util.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions', style: AppTextStyles.headlineSmall.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary, // Active tab text color
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6), // Inactive tab text color
            tabs: [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TransactionsListView(timeFrame: 'day', firestoreService: firestoreService),
            TransactionsListView(timeFrame: 'week', firestoreService: firestoreService),
            TransactionsListView(timeFrame: 'month', firestoreService: firestoreService),
            TransactionsListView(timeFrame: 'year', firestoreService: firestoreService),
          ],
        ),
      ),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  final String timeFrame;
  final FirestoreService firestoreService;

  const TransactionsListView({super.key, required this.timeFrame, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<model.Transaction>>(
      stream: firestoreService.getTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var transactions = snapshot.data!;
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            var transaction = transactions[index];
            return ListTile(
              title: Text(transaction.category, style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onBackground)),
              subtitle: Text('Amount: ${transaction.amount}', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface)),
            );
          },
        );
      },
    );
  }
}
