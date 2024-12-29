import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart' as model;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<model.Transaction>> getTransactions() {
    return _db.collection('transactions').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => model.Transaction.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> addTransaction(model.Transaction transaction) {
    return _db.collection('transactions').add(transaction.toMap());
  }

  Future<void> updateTransaction(model.Transaction transaction) {
    return _db.collection('transactions').doc(transaction.id).update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) {
    return _db.collection('transactions').doc(id).delete();
  }
}
