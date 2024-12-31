import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/transaction_model.dart';
import '../../../core/services/firestore_service.dart';

class AnalyticsController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Transaction>> getTransactions() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestoreService.getTransactionsStream(user.uid);
  }

  double calculateTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double calculateTotalIncome(List<Transaction> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Map<String, double> calculateCategoryExpenses(List<Transaction> transactions) {
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

    // Sort by amount in descending order
    final sortedCategories = Map.fromEntries(
      expensesByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );

    return sortedCategories;
  }

  Future<Map<String, List<double>>> getMonthlyTrends() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final now = DateTime.now();
    final sixMonthsAgo = DateTime(now.year, now.month - 6, 1);
    
    final transactions = await _firestoreService.getTransactionsBetweenDates(
      user.uid,
      sixMonthsAgo,
      now,
    );

    final monthlyExpenses = <String, List<double>>{};
    
    for (var transaction in transactions) {
      final month = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      
      if (!monthlyExpenses.containsKey(month)) {
        monthlyExpenses[month] = [0.0, 0.0]; // [expenses, income]
      }
      
      if (transaction.type == TransactionType.expense) {
        monthlyExpenses[month]![0] += transaction.amount;
      } else {
        monthlyExpenses[month]![1] += transaction.amount;
      }
    }

    return monthlyExpenses;
  }

  Future<Map<String, double>> getAverageExpensesByDay() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final transactions = await _firestoreService.getTransactionsBetweenDates(
      user.uid,
      thirtyDaysAgo,
      now,
    );

    final expensesByDay = <String, List<double>>{
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        final dayName = _getDayName(transaction.date.weekday);
        expensesByDay[dayName]!.add(transaction.amount);
      }
    }

    return Map.fromEntries(
      expensesByDay.entries.map((entry) {
        final amounts = entry.value;
        final average = amounts.isEmpty
            ? 0.0
            : amounts.reduce((a, b) => a + b) / amounts.length;
        return MapEntry(entry.key, average);
      }),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }
}
