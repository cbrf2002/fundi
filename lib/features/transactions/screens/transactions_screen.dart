import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart' as model;

class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions'),
          bottom: TabBar(
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

  TransactionsListView({required this.timeFrame, required this.firestoreService});

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
              title: Text(transaction.category),
              subtitle: Text('Amount: ${transaction.amount}'),
            );
          },
        );
      },
    );
  }
}
