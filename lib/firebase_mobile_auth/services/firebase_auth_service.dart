import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_state.dart';

/// Core Firebase authentication service
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user phone number
  String? get currentUserPhone => _auth.currentUser?.phoneNumber;

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// User changes stream
  Stream<User?> get userChanges => _auth.userChanges();

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Reload current user
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Get ID token
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  /// Sign in with phone credential
  Future<PhoneAuthResult> signInWithCredential({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return PhoneAuthResult.success(
        userId: userCredential.user?.uid,
        phoneNumber: userCredential.user?.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      return PhoneAuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.unknown,
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  /// Verify phone number and send SMS code
  Future<PhoneAuthResult> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) codeSent,
    required Function(AuthError error) verificationFailed,
    Function(String verificationId, int? resendToken)? codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          try {
            await _auth.signInWithCredential(credential);
          } catch (e) {
            verificationFailed(AuthError.fromFirebaseException(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(AuthError.fromFirebaseException(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId);
          if (codeAutoRetrievalTimeout != null) {
            // Store resend token for later use if needed
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (codeAutoRetrievalTimeout != null) {
            codeAutoRetrievalTimeout(verificationId, null);
          }
        },
      );

      // Return a pending result - actual result will come through callbacks
      return PhoneAuthResult(success: false, phoneNumber: phoneNumber);
    } catch (e) {
      return PhoneAuthResult.failure(AuthError.fromFirebaseException(e));
    }
  }

  /// Re-authenticate user with phone credential
  Future<PhoneAuthResult> reauthenticateWithPhone({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return PhoneAuthResult.failure(
          AuthError.custom(
            type: AuthErrorType.unknown,
            message: 'No user is currently signed in',
          ),
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.reauthenticateWithCredential(credential);

      return PhoneAuthResult.success(
        userId: user.uid,
        phoneNumber: user.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      return PhoneAuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.unknown,
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  /// Update phone number
  Future<PhoneAuthResult> updatePhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return PhoneAuthResult.failure(
          AuthError.custom(
            type: AuthErrorType.unknown,
            message: 'No user is currently signed in',
          ),
        );
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await user.updatePhoneNumber(credential);

      return PhoneAuthResult.success(
        userId: user.uid,
        phoneNumber: user.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      return PhoneAuthResult.failure(AuthError.fromFirebaseException(e));
    } catch (e) {
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.unknown,
          message: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }
}
