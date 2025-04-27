import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email and Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Reload user data to get the latest state (including emailVerified)
      await result.user?.reload();
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      print("AuthService Error - signInWithEmail: ${e.message}");
      throw Exception(
          _handleFirebaseAuthError(e)); // Rethrow user-friendly message
    } catch (e) {
      print("AuthService Error - signInWithEmail: $e");
      throw Exception("An unexpected error occurred during sign in.");
    }
  }

  // Sign up with Email and Password
  Future<User?> signUpWithEmail(String email, String password,
      {String? displayName}) async {
    User? user; // Declare user variable outside try block
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user; // Assign user here

      if (user != null) {
        // 1. Update Firebase Auth profile
        await user.updateDisplayName(displayName ?? 'User');
        // Reload user to get updated info before saving to Firestore
        await user.reload();
        user = _auth.currentUser; // Get the reloaded user

        if (user != null) {
          // Check again after reload
          // 2. Create user profile and default preferences in Firestore
          await _initializeUserData(user);

          // 3. Send email verification
          await sendEmailVerification(); // This now uses the reloaded user internally

          // 4. *** Sign out the user immediately after creation ***
          await _auth.signOut();
          print("AuthService: Signed out user immediately after sign up.");
        }
      }
      // Return the user object (even though signed out) so the UI can show the email
      return user;
    } on FirebaseAuthException catch (e) {
      print("AuthService Error - signUpWithEmail: ${e.message}");
      // If sign-up failed, ensure user is signed out just in case
      await _auth.signOut();
      throw Exception(
          _handleFirebaseAuthError(e)); // Rethrow user-friendly message
    } catch (e) {
      print("AuthService Error - signUpWithEmail: $e");
      // If any other error occurred, ensure user is signed out
      await _auth.signOut();
      throw Exception("An unexpected error occurred during sign up.");
    }
  }

  // Initialize User Data in Firestore (Profile & Preferences)
  Future<void> _initializeUserData(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    // Preferences are now stored under users/{uid}/preferences/{uid} or similar based on FirestoreService logic
    // We only need to ensure the main user document is created here.
    // Preferences document creation is handled by FirestoreService.getUserPreferences if it doesn't exist.

    // Check if user document exists
    final userDoc = await userRef.get();
    if (!userDoc.exists) {
      final newUserProfile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User', // Use updated display name
        photoUrl: user.photoURL ?? '', // Use photo URL if available
      );
      // Only set the main user profile data. Preferences subcollection/map is handled elsewhere.
      await userRef.set(newUserProfile.toMap());
      print('Created user document in Firestore for ${user.uid}');
    } else {
      // Optionally update existing user doc if needed (e.g., display name changed)
      await userRef.update({
        'displayName': user.displayName ?? 'User',
        'photoUrl': user.photoURL ?? '',
      });
      print('Checked/Updated user document in Firestore for ${user.uid}');
    }
  }

  // Send Email Verification
  Future<void> sendEmailVerification() async {
    // Use currentUser which might be null if sign out happened too early,
    // but the user object passed to _initializeUserData is guaranteed non-null
    // Let's rely on the state *before* the immediate sign-out for sending.
    // The user object obtained *before* signOut() is the one we need.
    // Note: The logic inside signUpWithEmail ensures this is called before signOut.
    User? userToSendVerification = _auth.currentUser;
    if (userToSendVerification != null &&
        !userToSendVerification.emailVerified) {
      try {
        await userToSendVerification.sendEmailVerification();
        print('Verification email sent to ${userToSendVerification.email}');
      } on FirebaseAuthException catch (e) {
        print("AuthService Error - sendEmailVerification: ${e.message}");
        // Avoid throwing an exception here if sending fails, maybe just log it.
        // The user can try again from the verification screen.
        // throw Exception(_handleFirebaseAuthError(e));
      } catch (e) {
        print("AuthService Error - sendEmailVerification: $e");
      }
    } else if (userToSendVerification == null) {
      print(
          "AuthService Warning: Cannot send verification email, user is null (likely already signed out). This might indicate a logic issue.");
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    if (user == null) return false;
    // Reload user data to get the latest verification status
    try {
      await user.reload();
      user = _auth.currentUser; // Get reloaded user
      return user?.emailVerified ?? false;
    } catch (e) {
      print("AuthService Error - isEmailVerified (reload failed): $e");
      // If reload fails, return the current known status
      return user?.emailVerified ?? false;
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print("AuthService Error - sendPasswordResetEmail: ${e.message}");
      throw Exception(_handleFirebaseAuthError(e));
    } catch (e) {
      print("AuthService Error - sendPasswordResetEmail: $e");
      throw Exception("An unexpected error occurred.");
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("AuthService Error - signOut: $e");
      // Usually, sign out errors are less critical to bubble up, but can if needed
      // throw Exception("Error signing out.");
    }
  }

  // Helper to convert Firebase errors to user-friendly messages
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential': // Covers invalid email/password combination
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      // Add other specific cases as needed
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}
