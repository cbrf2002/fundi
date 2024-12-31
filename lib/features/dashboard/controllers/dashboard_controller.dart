import '../../../core/models/transaction_model.dart';
import '../../../core/services/firestore_service.dart';

class DashboardController {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<Transaction>> getTransactions() {
    return _firestoreService.getTransactions();
  }

  List<double> calculateStats(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpenses += transaction.amount;
      }
    }

    double balance = totalIncome - totalExpenses;
    return [totalIncome, balance, totalExpenses];
  }

  List<Map<String, dynamic>> getTopExpenses(List<Transaction> transactions) {
    final expensesByCategory = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        expensesByCategory.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    // Sort categories by total expenses and get the top 3
    final topExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(3);

    return topExpenses.map((entry) => {
      'category': entry.key,
      'amount': entry.value,
    }).toList();
  }
}
