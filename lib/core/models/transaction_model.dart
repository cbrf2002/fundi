import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  expense,
  income,
}

class Transaction {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

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
    TransactionType? type,
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
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': date,
      'type': type == TransactionType.income ? 'income' : 'expense',
    };
  }

  DateTime get timestamp => date;
}
