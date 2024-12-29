import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart' as model;
import '../../../core/utils/util.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: AppTextStyles.headlineSmall),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<List<model.Transaction>>(
        stream: firestoreService.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var transactions = snapshot.data!;
          double totalExpenses = transactions
              .where((t) => t.type == 'expense')
              .fold(0.0, (sum, t) => sum + t.amount);
          double totalIncome = transactions
              .where((t) => t.type == 'income')
              .fold(0.0, (sum, t) => sum + t.amount);
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                Text('Expenses: $totalExpenses', style: AppTextStyles.bodyLarge),
                Text('Income: $totalIncome', style: AppTextStyles.bodyLarge),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    var transaction = transactions[index];
                    return ListTile(
                      title: Text(transaction.category, style: AppTextStyles.bodyMedium),
                      subtitle: Text('Amount: ${transaction.amount}', style: AppTextStyles.bodySmall),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open add transaction dialog
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation.
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
        ],
      ),
    );
  }
}
