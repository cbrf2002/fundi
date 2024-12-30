import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart' as model;
import '../models/user_preferences.dart';
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

  // User Preferences Methods
  Future<UserPreferences> getUserPreferences() async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data()!.containsKey('preferences')) {
        final prefData = doc.data()!['preferences'] as Map<String, dynamic>;
        return UserPreferences.fromMap({...prefData, 'uid': userId});
      } else {
        // Create default preferences
        final defaultPrefs = UserPreferences(
          uid: userId,
          currency: 'USD',
          useSystemTheme: true,
          isDarkMode: false,
          showCents: true,
          enableNotifications: true,
        );
        await saveUserPreferences(defaultPrefs);
        return defaultPrefs;
      }
    } catch (e) {
      print('Error getting user preferences: $e');
      // Return default preferences if there's an error
      return UserPreferences(
        uid: userId,
        currency: 'USD',
        useSystemTheme: true,
        isDarkMode: false,
        showCents: true,
        enableNotifications: true,
      );
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .set({
            'preferences': preferences.toMap()
          }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user preferences: $e');
      throw e;
    }
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
      final docRef = _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();
      transaction = transaction.copyWith(id: docRef.id);
      await docRef.set(transaction.toMap());
    } catch (e) {
      print('Error adding transaction: $e');
      throw e;
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
      throw e;
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
      throw e;
    }
  }

  Future<Map<String, dynamic>> getDocument(String collection, String docId) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error getting document: $e');
      return {};
    }
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _db.collection(collection).doc(docId).set(data);
    } catch (e) {
      print('Error setting document: $e');
      throw e;
    }
  }

  Future<int> getTransactionStats(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting transaction stats: $e');
      return 0;
    }
  }

  Future<double> getCurrentMonthStats(String uid) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final transaction = model.Transaction.fromMap(doc.data(), doc.id);
        if (transaction.type == model.TransactionType.income) {
          total += transaction.amount;
        } else {
          total -= transaction.amount;
        }
      }
      return total;
    } catch (e) {
      print('Error getting current month stats: $e');
      return 0;
    }
  }

  Future<int> getCategoryCount(String uid) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .get();

      final categories = snapshot.docs
          .map((doc) => model.Transaction.fromMap(doc.data(), doc.id).category)
          .toSet();

      return categories.length;
    } catch (e) {
      print('Error getting category count: $e');
      return 0;
    }
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      return snapshot.docs
          .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all transactions: $e');
      return [];
    }
  }
}
