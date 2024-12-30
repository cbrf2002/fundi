import 'package:flutter/material.dart';
import '../../../core/models/transaction_model.dart' as model;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<model.Transaction> transactions = []; // Example data
    final double totalExpenses = 200.0; // Example calculation
    final double totalIncome = 500.0; // Example calculation

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              title: Text(
                'Total Expenses',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                '\$${totalExpenses.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text(
                'Total Income',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              subtitle: Text(
                '\$${totalIncome.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...transactions.map((transaction) => Card(
                child: ListTile(
                  title: Text(transaction.category),
                  subtitle: Text('Amount: \$${transaction.amount.toStringAsFixed(2)}'),
                ),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add transaction dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
