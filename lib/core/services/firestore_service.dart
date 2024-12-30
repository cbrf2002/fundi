import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart' as model;
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String get userId {
    final userId = _authService.getCurrentUserId();
    if (userId == null) {
      throw Exception("User is not authenticated");
    }
    return userId;
  }

  Stream<List<model.Transaction>> getTransactions() {
    try {
      return _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching transactions: $e');
      return const Stream.empty();
    }
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    try {
      final docRef = _db.collection('users').doc(userId).collection('transactions').doc();
      transaction = transaction.copyWith(id: docRef.id);
      await docRef.set(transaction.toMap());
    } catch (e) {
      print('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      print('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(id)
          .delete();
    } catch (e) {
      print('Error deleting transaction: $e');
    }
  }
}
