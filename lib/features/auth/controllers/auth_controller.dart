import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  
  Future<User?> signInWithEmail(String email, String password) async {
    return await _authService.signInWithEmail(email, password);
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    return await _authService.signUpWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
