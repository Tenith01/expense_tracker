// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Authentication – email/password and Google sign-in.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// The currently signed-in user (null if signed out).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth-state changes (sign-in / sign-out).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ────────────────────────────────────────────────────

  /// Register a new account with email & password.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Sign in with an existing email & password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  /// Send a password-reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ── Google Sign-In (google_sign_in v7.x) ────────────────────────────────

  /// Sign in with Google (interactive picker).
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      // Initialize if not already done (safe to call multiple times).
      await googleSignIn.initialize();

      // Trigger interactive authentication.
      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      // Get the ID token from the authentication result.
      final idToken = googleUser.authentication.idToken;

      // Build a Firebase credential with only the idToken.
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      // User cancelled or interrupted – treat as a "no-op" rather than error.
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw e.description ?? 'Google Sign-In failed.';
    } on FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────

  /// Sign out of both Firebase and Google.
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google sign-out may fail if user wasn't signed in with Google.
    }
    await _auth.signOut();
  }

  // ── Error Mapping ──────────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] into a user-friendly message.
  String _mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in instead.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
