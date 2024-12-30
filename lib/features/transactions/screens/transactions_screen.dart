import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/utils/util.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<void> _fetchData;
  List<model.Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData = _loadData();
  }

  Future<void> _loadData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('transactions').get();
    setState(() {
      transactions = querySnapshot.docs.map((doc) => model.Transaction.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Transactions', style: Theme.of(context).textTheme.headlineSmall),
          backgroundColor: Theme.of(context).colorScheme.primary,
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimary, // Active tab text color
            unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6), // Inactive tab text color
            tabs: const [
              Tab(text: 'Day'),
              Tab(text: 'Week'),
              Tab(text: 'Month'),
              Tab(text: 'Year'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: _fetchData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return RefreshIndicator(
                onRefresh: _loadData,
                child: TabBarView(
                  children: [
                    TransactionsListView(timeFrame: 'day', transactions: transactions),
                    TransactionsListView(timeFrame: 'week', transactions: transactions),
                    TransactionsListView(timeFrame: 'month', transactions: transactions),
                    TransactionsListView(timeFrame: 'year', transactions: transactions),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class TransactionsListView extends StatelessWidget {
  final String timeFrame;
  final List<model.Transaction> transactions;

  const TransactionsListView({super.key, required this.timeFrame, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        var transaction = transactions[index];
        return ListTile(
          title: Text(transaction.category, style: Theme.of(context).textTheme.bodyMedium),
          subtitle: Text('Amount: ${transaction.amount}', style: Theme.of(context).textTheme.bodySmall),
        );
      },
    );
  }
}
