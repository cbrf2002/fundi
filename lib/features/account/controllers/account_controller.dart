import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/export_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/user_preferences.dart';

class AccountController {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExportService _exportService = ExportService();

  Future<UserProfile> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');

    final userProfileData = await _firestoreService.getDocument('users', user.uid);
    if (userProfileData.isEmpty) {
      // Create default user profile if none exists
      final defaultProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: '',
      );
      await _firestoreService.setDocument('users', user.uid, defaultProfile.toMap());
      return defaultProfile;
    }
    return UserProfile.fromMap(userProfileData);
  }

  Future<UserPreferences> loadUserPreferences() async {
    return await _firestoreService.getUserPreferences();
  }

  Future<void> saveUserPreferences(UserPreferences preferences) async {
    await _firestoreService.saveUserPreferences(preferences);
  }

  Future<List<num>> getStats(String uid) async {
    return await Future.wait([
      _firestoreService.getTransactionStats(uid),
      _firestoreService.getCurrentMonthStats(uid),
      _firestoreService.getCategoryCount(uid),
    ]);
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String?> exportData() async {
    return await _exportService.exportTransactionsToCSV();
  }

  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }
}
