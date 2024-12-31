import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Initiate Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled the sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a credential using the Google token
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> trySilentSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        print('User silently signed in: ${_auth.currentUser?.displayName}');
      } else {
        print('No previous Google session found.');
      }
    } catch (e) {
      print('Error during silent Google Sign-In: $e');
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error during Email Sign-Up: $e');
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error during Email Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Stream<User?> get userChanges => _auth.authStateChanges();

  /// Method to get the current user's ID safely
  String? getCurrentUserId() {
    final user = _auth.currentUser;
    return user?.uid;
  }
}
