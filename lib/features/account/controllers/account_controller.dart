import '../../../core/models/user_model.dart';
import '../../../core/models/user_preferences.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/models/transaction_model.dart' as fundi_transaction;
import '../../../core/services/export_service.dart';
import '../../auth/services/auth_service.dart';

class AccountController {
  final FirestoreService _firestoreService = FirestoreService();
  final ExportService _exportService = ExportService();
  // Use the updated AuthService
  final AuthService _authService = AuthService();

  Future<UserProfile> loadUserProfile() async {
    // Get the current user from AuthService
    final user = _authService.currentUser;
    if (user == null) throw Exception('No user logged in');

    // Fetch the document using FirestoreService
    final userProfileData =
        await _firestoreService.getDocument('users', user.uid);

    if (userProfileData.isEmpty) {
      print(
          "AccountController: User profile data empty in Firestore, creating default.");
      final defaultProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL ?? '',
      );
      // Use FirestoreService to set the document
      await _firestoreService.setDocument(
          'users', user.uid, defaultProfile.toMap());
      return defaultProfile;
    }
    userProfileData['uid'] = user.uid;
    return UserProfile.fromMap(userProfileData);
  }

  Future<UserPreferences> loadUserPreferences() async {
    // Delegate fully to FirestoreService, which handles user ID internally
    return await _firestoreService.getUserPreferences();
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    // Delegate fully to FirestoreService
    await _firestoreService.saveUserPreferences(preferences);
  }

  Future<List<num>> getAccountScreenStats() async {
    final user = _authService.currentUser; // Check user existence first
    if (user == null) {
      print("AccountController: Cannot get stats, user not logged in.");
      return [0, 0.0, 0];
    }

    try {
      // FirestoreService.getAllTransactions uses the correct userId internally
      final transactions = await _firestoreService.getAllTransactions();

      if (transactions.isEmpty) {
        return [0, 0.0, 0];
      }

      final int transactionCount = transactions.length;

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      double monthlyIncome = 0.0;
      double monthlyExpenses = 0.0;

      for (var transaction in transactions) {
        if (transaction.date.isAfter(startOfMonth) &&
            transaction.date.isBefore(endOfMonth)) {
          if (transaction.type == fundi_transaction.TransactionType.income) {
            monthlyIncome += transaction.amount;
          } else {
            monthlyExpenses += transaction.amount;
          }
        }
      }
      final double monthlyTotal = monthlyIncome - monthlyExpenses;

      final Set<String> categories =
          transactions.map((t) => t.category).toSet();
      final int categoryCount = categories.length;

      return [transactionCount, monthlyTotal, categoryCount];
    } catch (e) {
      print("Error calculating account screen stats: $e");
      return [0, 0.0, 0];
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Delegate to AuthService, which handles errors
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      print("AccountController: Password reset failed - $e");
      rethrow; // Rethrow the exception from AuthService
    }
  }

  Future<void> signOut() async {
    // Delegate to AuthService
    await _authService.signOut();
  }

  // Change return type to Future<String>
  Future<String> exportData() async {
    // Delegate to FirestoreService to get data, then ExportService
    try {
      final transactions = await _firestoreService.getAllTransactions();
      if (transactions.isEmpty) {
        throw Exception("No transactions available to export.");
      }
      // Return the CSV string from ExportService
      return await _exportService.exportTransactionsToCSV(transactions);
    } catch (e) {
      print("AccountController: Export failed - $e");
      rethrow; // Rethrow to be caught by the UI
    }
  }

  // --- New Method ---
  Future<void> deleteAllTransactions() async {
    // Delegate to FirestoreService
    try {
      await _firestoreService.deleteAllTransactions();
    } catch (e) {
      print("AccountController: Delete all transactions failed - $e");
      rethrow; // Rethrow to be caught by the UI
    }
  }

  bool isUserLoggedIn() {
    // Use AuthService to check
    return _authService.currentUser != null;
  }
}
