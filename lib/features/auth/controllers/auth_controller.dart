import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart'; // Correct path

class AuthController {
  final AuthService _authService = AuthService();

  // Expose auth state changes stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Get current user
  User? get currentUser => _authService.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    // Error handling is done in the service, just call and return/rethrow
    try {
      return await _authService.signInWithEmail(email, password);
    } catch (e) {
      print("AuthController: SignIn failed - $e");
      rethrow; // Let the UI handle the display of the error message from service
    }
  }

  Future<User?> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    try {
      return await _authService.signUpWithEmail(email, password,
          displayName: displayName);
    } catch (e) {
      print("AuthController: SignUp failed - $e");
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      // No need to throw error here, service handles logging
    } catch (e) {
      // This catch might not be needed if service doesn't throw for sendEmailVerification
      print("AuthController: Send verification failed - $e");
      rethrow; // Rethrow if service does throw an exception
    }
  }

  Future<bool> isEmailVerified() async {
    // Directly return the result from the service
    return await _authService.isEmailVerified();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      print("AuthController: Password reset failed - $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    // No return value needed, UI should react to authStateChanges
  }
}
