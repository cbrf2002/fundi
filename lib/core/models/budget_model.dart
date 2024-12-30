import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final double totalIncome;
  final double totalExpenses;
  final double netAmount;

  Budget({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
  });

  Budget copyWith({
    double? totalIncome,
    double? totalExpenses,
    double? netAmount,
  }) {
    return Budget(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      netAmount: netAmount ?? this.netAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netAmount': netAmount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      totalIncome: map['totalIncome'] ?? 0.0,
      totalExpenses: map['totalExpenses'] ?? 0.0,
      netAmount: map['netAmount'] ?? 0.0,
    );
  }

  static Budget fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget.fromMap(data);
  }

  Map<String, dynamic> toFirestore() {
    return toMap();
  }
}
