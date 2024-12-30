import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String type; // 'expense' or 'income'

  Transaction({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  Transaction copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  factory Transaction.fromMap(Map<String, dynamic> data, String documentId) {
    return Transaction(
      id: documentId,
      category: data['category'] ?? '',
      amount: data['amount']?.toDouble() ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'expense',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': date,
      'type': type,
    };
  }
}
