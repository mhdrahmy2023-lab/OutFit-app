import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        '421634876367-eq5mnr8qr8t24reuvvkr46chc85vurh5.apps.googleusercontent.com',
  );

  /// Get the current user (null if not signed in).
  static User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password Sign In ──────────────────────────────────────────────

  /// Sign in with email & password.
  /// Returns the [User] on success, throws [FirebaseAuthException] on failure.
  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  // ── Email / Password Sign Up ──────────────────────────────────────────────

  /// Create a new account with email & password, then set the display name.
  /// Returns the [User] on success, throws [FirebaseAuthException] on failure.
  static Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Store the user's display name
    await credential.user?.updateDisplayName(name.trim());

    // After creating the user account, save their profile to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return credential.user;
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  /// Sign in with Google — returns display name or null on failure/cancel.
  static Future<String?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final UserCredential userCredential =
            await _auth.signInWithPopup(googleProvider);
        return userCredential.user?.displayName;
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? account = await googleSignIn.signIn();
        if (account == null) return null;
        final GoogleSignInAuthentication googleAuth =
            await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential.user?.displayName;
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      return null;
    }
  }

  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────────────

  /// Sign in with Apple — returns credential or null on failure/cancel.
  static Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(oauthCredential);

      return appleCredential;
    } catch (e) {
      debugPrint('Apple sign-in error: $e');
      return null;
    }
  }

  // ── Helper: human-readable error message ──────────────────────────────────

  /// Converts a [FirebaseAuthException] code to a user-friendly message.
  static String friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
