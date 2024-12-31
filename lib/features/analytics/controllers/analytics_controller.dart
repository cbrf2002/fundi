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
    return Map.fromEntries(
      expensesByCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<Map<String, List<double>>> getDailyProjections(int daysAhead) async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final transactions = await _firestoreService.getTransactionsBetweenDates(
      user.uid,
      thirtyDaysAgo,
      now,
    );

    if (transactions.isEmpty) return {};

    // Prepare daily aggregated data
    final dailyData = <DateTime, List<double>>{};
    for (var transaction in transactions) {
      final dateKey = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailyData.putIfAbsent(dateKey, () => [0.0, 0.0]);
      if (transaction.type == TransactionType.expense) {
        dailyData[dateKey]![0] += transaction.amount;
      } else {
        dailyData[dateKey]![1] += transaction.amount;
      }
    }

    // Sort dates
    final sortedDates = dailyData.keys.toList()..sort();

    // Prepare data for regression
    final days = List<int>.generate(sortedDates.length, (index) => index);
    final expenses = sortedDates.map((date) => dailyData[date]![0]).toList();
    final incomes = sortedDates.map((date) => dailyData[date]![1]).toList();

    // Perform regression
    final expenseCoefficients = _calculateLinearRegression(days, expenses);
    final incomeCoefficients = _calculateLinearRegression(days, incomes);

    // Generate projections
    final projections = <String, List<double>>{};
    for (int i = 1; i <= daysAhead; i++) {
      final futureDayIndex = days.length + i - 1;
      final projectedDate = now.add(Duration(days: i));
      final key = '${projectedDate.year}-${projectedDate.month.toString().padLeft(2, '0')}-${projectedDate.day.toString().padLeft(2, '0')}';

      final projectedExpenses = expenseCoefficients[0] * futureDayIndex + expenseCoefficients[1];
      final projectedIncome = incomeCoefficients[0] * futureDayIndex + incomeCoefficients[1];

      projections[key] = [projectedExpenses.clamp(0, double.infinity), projectedIncome.clamp(0, double.infinity)];
    }

    return projections;
  }

  List<double> _calculateLinearRegression(List<int> x, List<double> y) {
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((xi) => xi * xi).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    return [slope, intercept];
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
      monthlyExpenses.putIfAbsent(month, () => [0.0, 0.0]);
      if (transaction.type == TransactionType.expense) {
        monthlyExpenses[month]![0] += transaction.amount;
      } else {
        monthlyExpenses[month]![1] += transaction.amount;
      }
    }

    return monthlyExpenses;
  }

  Future<Map<String, List<double>>> getWeeklyTrends() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final now = DateTime.now();
    final eightWeeksAgo = now.subtract(const Duration(days: 56)); // 8 weeks
    final transactions = await _firestoreService.getTransactionsBetweenDates(
      user.uid,
      eightWeeksAgo,
      now,
    );

    final weeklyExpenses = <String, List<double>>{};
    for (var transaction in transactions) {
      final week = _getWeekKey(transaction.date);
      weeklyExpenses.putIfAbsent(week, () => [0.0, 0.0]);
      if (transaction.type == TransactionType.expense) {
        weeklyExpenses[week]![0] += transaction.amount;
      } else {
        weeklyExpenses[week]![1] += transaction.amount;
      }
    }

    return weeklyExpenses;
  }

  String _getWeekKey(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final weekNumber = ((date.difference(firstDayOfYear).inDays + firstDayOfYear.weekday) / 7).ceil();
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
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
