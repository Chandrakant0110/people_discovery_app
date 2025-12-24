/// Authentication status enum
enum AuthStatus {
  /// Initial state - no authentication in progress
  unauthenticated,
  
  /// Verification code has been sent
  codeSent,
  
  /// Code verification is in progress
  verifying,
  
  /// User is successfully authenticated
  authenticated,
  
  /// An error occurred during authentication
  error,
}

/// Result of phone authentication operation
class PhoneAuthResult {
  final bool success;
  final String? verificationId;
  final String? phoneNumber;
  final AuthError? error;
  final String? userId;

  const PhoneAuthResult({
    required this.success,
    this.verificationId,
    this.phoneNumber,
    this.error,
    this.userId,
  });

  factory PhoneAuthResult.success({
    String? verificationId,
    String? phoneNumber,
    String? userId,
  }) {
    return PhoneAuthResult(
      success: true,
      verificationId: verificationId,
      phoneNumber: phoneNumber,
      userId: userId,
    );
  }

  factory PhoneAuthResult.failure(AuthError error) {
    return PhoneAuthResult(
      success: false,
      error: error,
    );
  }
}

/// Authentication error types
enum AuthErrorType {
  /// Invalid phone number format
  invalidPhoneNumber,
  
  /// Network connection error
  networkError,
  
  /// Invalid or expired verification code
  invalidCode,
  
  /// Too many verification attempts
  tooManyAttempts,
  
  /// SMS code expired
  codeExpired,
  
  /// Quota exceeded
  quotaExceeded,
  
  /// User cancelled the operation
  userCancelled,
  
  /// Unknown error
  unknown,
}

/// Authentication error model
class AuthError {
  final AuthErrorType type;
  final String message;
  final String? code;
  final dynamic originalError;

  const AuthError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
  });

  /// Create AuthError from Firebase Auth exception
  factory AuthError.fromFirebaseException(dynamic exception) {
    String errorCode = '';
    String errorMessage = 'An unknown error occurred';
    
    if (exception != null) {
      try {
        errorCode = exception.code?.toString() ?? '';
        errorMessage = exception.message?.toString() ?? errorMessage;
      } catch (e) {
        errorMessage = exception.toString();
      }
    }

    AuthErrorType errorType = AuthErrorType.unknown;

    // Map Firebase error codes to our error types
    switch (errorCode) {
      case 'invalid-phone-number':
        errorType = AuthErrorType.invalidPhoneNumber;
        errorMessage = 'Invalid phone number format';
        break;
      case 'invalid-verification-code':
        errorType = AuthErrorType.invalidCode;
        errorMessage = 'Invalid verification code';
        break;
      case 'session-expired':
        errorType = AuthErrorType.codeExpired;
        errorMessage = 'Verification code has expired';
        break;
      case 'too-many-requests':
        errorType = AuthErrorType.tooManyAttempts;
        errorMessage = 'Too many attempts. Please try again later';
        break;
      case 'quota-exceeded':
        errorType = AuthErrorType.quotaExceeded;
        errorMessage = 'SMS quota exceeded. Please try again later';
        break;
      case 'network-request-failed':
        errorType = AuthErrorType.networkError;
        errorMessage = 'Network error. Please check your connection';
        break;
      case 'user-disabled':
        errorMessage = 'This account has been disabled';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Phone authentication is not enabled';
        break;
    }

    return AuthError(
      type: errorType,
      message: errorMessage,
      code: errorCode,
      originalError: exception,
    );
  }

  /// Create AuthError from custom message
  factory AuthError.custom({
    required AuthErrorType type,
    required String message,
  }) {
    return AuthError(
      type: type,
      message: message,
    );
  }

  @override
  String toString() => message;
}

