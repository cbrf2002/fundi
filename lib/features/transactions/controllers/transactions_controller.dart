import '../../../core/models/transaction_model.dart' as model;
import '../../../core/services/firestore_service.dart';

class TransactionsController {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<model.Transaction>> getTransactions() {
    return _firestoreService.getTransactions();
  }

  List<model.Transaction> filterTransactionsByTimeFrame(
    List<model.Transaction> transactions,
    String timeFrame,
  ) {
    final now = DateTime.now();
    final startDate = switch (timeFrame) {
      'day' => DateTime(now.year, now.month, now.day),
      'week' => now.subtract(const Duration(days: 7)),
      'month' => DateTime(now.year, now.month, 1),
      'year' => DateTime(now.year, 1, 1),
      _ => now,
    };

    return transactions
        .where((t) =>
            t.date.isAfter(startDate) || t.date.isAtSameMomentAs(startDate))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by newest first
  }

  double calculateTotalExpenses(List<model.Transaction> transactions) {
    return transactions
        .where((t) => t.type == model.TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateTotalIncome(List<model.Transaction> transactions) {
    return transactions
        .where((t) => t.type == model.TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateNetTotal(List<model.Transaction> transactions) {
    final totalIncome = calculateTotalIncome(transactions);
    final totalExpenses = calculateTotalExpenses(transactions);
    return totalIncome - totalExpenses;
  }
}
