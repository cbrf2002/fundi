import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart' as model;
import '../models/user_preferences.dart';
// Import the correct AuthService path
import '../../features/auth/services/auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  // Keep AuthService instance to get current user ID
  final AuthService _authService = AuthService();

  String get userId {
    // Use the currentUser getter from AuthService
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      // This should ideally not happen if UI guards routes correctly
      print("FirestoreService Error: User is not authenticated.");
      throw Exception("User is not authenticated");
    }
    return userId;
  }

  // User Preferences Methods
  Future<UserPreferences> getUserPreferences() async {
    final currentUserId = userId; // Get userId safely once
    try {
      final docRef = _db.collection('users').doc(currentUserId);
      final doc = await docRef.get();

      // Check if the main user document exists first
      if (doc.exists) {
        // Check if the 'preferences' map exists within the user document
        if (doc.data()!.containsKey('preferences')) {
          final prefData = doc.data()!['preferences'] as Map<String, dynamic>;
          // Ensure UID is included when creating UserPreferences object
          return UserPreferences.fromMap({...prefData, 'uid': currentUserId});
        } else {
          // User document exists, but no preferences map - create default preferences
          print(
              "Preferences map not found for user $currentUserId, creating defaults.");
          final defaultPrefs = UserPreferences(
            uid: currentUserId,
            currency: 'USD',
            useSystemTheme: true,
            isDarkMode: false,
            showCents: true,
            enableNotifications: true,
            decimalSeparatorPreference: 'device',
            thousandsSeparatorPreference: 'device',
          );
          // Save the default preferences within the existing user document
          await saveUserPreferences(defaultPrefs);
          return defaultPrefs;
        }
      } else {
        // User document doesn't exist (should be rare if AuthService._initializeUserData works)
        // Log this case, but still create defaults.
        print(
            "User document not found for user $currentUserId, creating defaults.");
        final defaultPrefs = UserPreferences(
          uid: currentUserId,
          currency: 'USD',
          useSystemTheme: true,
          isDarkMode: false,
          showCents: true,
          enableNotifications: true,
          decimalSeparatorPreference: 'device',
          thousandsSeparatorPreference: 'device',
        );
        // This will create the user document AND the preferences map inside it
        await saveUserPreferences(defaultPrefs);
        return defaultPrefs;
      }
    } catch (e) {
      print('Error getting user preferences for $currentUserId: $e');
      // Return default preferences if there's an error
      return UserPreferences(
        uid: currentUserId, // Use the obtained userId
        currency: 'USD',
        useSystemTheme: true,
        isDarkMode: false,
        showCents: true,
        enableNotifications: true,
        decimalSeparatorPreference: 'device',
        thousandsSeparatorPreference: 'device',
      );
    }
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final currentUserId = userId; // Get userId safely once
    try {
      // Save preferences as a map within the user's document
      await _db.collection('users').doc(currentUserId).set(
          {
            // Use set with merge:true to create doc if not exists or update if exists
            'preferences': preferences
                .toMap() // Store preferences under the 'preferences' key
          },
          SetOptions(
              merge:
                  true)); // merge:true ensures other user data isn't overwritten
    } catch (e) {
      print('Error saving user preferences for $currentUserId: $e');
      rethrow; // Rethrow to allow UI to handle
    }
  }

  // --- Transaction Methods ---
  // Use 'currentUserId' obtained safely where 'userId' was used before

  Stream<List<model.Transaction>> getTransactions() {
    final currentUserId = userId;
    try {
      return _db
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .orderBy('date', descending: true) // Often useful to order here
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching transactions for $currentUserId: $e');
      return Stream.value([]); // Return empty stream on error
    }
  }

  Stream<List<model.Transaction>> getTransactionsStream(String uid) {
    try {
      return _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
              .toList());
    } catch (e) {
      print('Error fetching transactions stream: $e');
      return const Stream.empty();
    }
  }

  Future<List<model.Transaction>> getTransactionsBetweenDates(
      String uid, DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      return snapshot.docs
          .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching transactions between dates: $e');
      return [];
    }
  }

  Future<void> addTransaction(model.Transaction transaction) async {
    final currentUserId = userId;
    try {
      final docRef = _db
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .doc(); // Firestore generates ID
      // Use copyWith to set the generated ID before saving
      final transactionWithId = transaction.copyWith(id: docRef.id);
      await docRef.set(transactionWithId.toMap());
    } catch (e) {
      print('Error adding transaction for $currentUserId: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(model.Transaction transaction) async {
    final currentUserId = userId;
    if (transaction.id.isEmpty) {
      print('Error updating transaction: ID is empty.');
      throw Exception('Transaction ID cannot be empty for update.');
    }
    try {
      await _db
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      print(
          'Error updating transaction ${transaction.id} for $currentUserId: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    final currentUserId = userId;
    if (transactionId.isEmpty) {
      print('Error deleting transaction: ID is empty.');
      throw Exception('Transaction ID cannot be empty for deletion.');
    }
    try {
      await _db
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      print('Error deleting transaction $transactionId for $currentUserId: $e');
      rethrow;
    }
  }

  // --- New Method ---
  Future<void> deleteAllTransactions() async {
    final currentUserId = userId;
    try {
      final collectionRef =
          _db.collection('users').doc(currentUserId).collection('transactions');
      final snapshot = await collectionRef.get();

      if (snapshot.docs.isEmpty) {
        print("No transactions to delete for user $currentUserId.");
        return; // Nothing to delete
      }

      // Use a batch write for efficiency and atomicity (up to 500 operations)
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print(
          "Successfully deleted ${snapshot.docs.length} transactions for user $currentUserId.");
    } catch (e) {
      print('Error deleting all transactions for $currentUserId: $e');
      rethrow;
    }
  }

  // --- Generic Document Methods ---
  // These seem okay, but ensure docId passed is correct (e.g., userId for user docs)

  Future<Map<String, dynamic>> getDocument(
      String collection, String docId) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      return doc.data() ?? {};
    } catch (e) {
      print('Error getting document $collection/$docId: $e');
      return {}; // Return empty map on error
    }
  }

  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data,
      {bool merge = false}) async {
    try {
      await _db
          .collection(collection)
          .doc(docId)
          .set(data, SetOptions(merge: merge));
    } catch (e) {
      print('Error setting document $collection/$docId: $e');
      rethrow;
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
    final currentUserId = userId;
    try {
      final snapshot = await _db
          .collection('users')
          .doc(currentUserId)
          .collection('transactions')
          .get();

      return snapshot.docs
          .map((doc) => model.Transaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting all transactions for $currentUserId: $e');
      return []; // Return empty list on error
    }
  }

  // Remove the old getCurrentUserId method if it exists in FirestoreService
}
