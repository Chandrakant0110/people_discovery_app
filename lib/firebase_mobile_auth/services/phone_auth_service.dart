import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/auth_state.dart';
import '../utils/phone_validator.dart';
import 'firebase_auth_service.dart';

/// Phone authentication service with SMS auto-detection support
class PhoneAuthService {
  final FirebaseAuthService _authService = FirebaseAuthService();
  String? _verificationId;
  String? _phoneNumber;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _isListeningToSms = false;

  /// Get current verification ID
  String? get verificationId => _verificationId;

  /// Get current phone number
  String? get phoneNumber => _phoneNumber;

  /// Get resend countdown
  int get resendCountdown => _resendCountdown;

  /// Check if can resend code
  bool get canResendCode => _resendCountdown == 0;

  /// Send verification code to phone number
  Future<PhoneAuthResult> sendVerificationCode({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(AuthError error) onError,
    int resendTimeout = 60,
  }) async {
    try {
      debugPrint('[PhoneAuthService] Validating phone number: $phoneNumber');
      // Validate phone number
      if (!PhoneValidator.isValid(phoneNumber)) {
        debugPrint('[PhoneAuthService] ❌ Invalid phone number format');
        final error = AuthError.custom(
          type: AuthErrorType.invalidPhoneNumber,
          message: 'Invalid phone number format',
        );
        onError(error);
        return PhoneAuthResult.failure(error);
      }
      debugPrint('[PhoneAuthService] ✅ Phone number is valid');

      // Format phone number with country code if needed
      String formattedPhone = phoneNumber;
      if (!formattedPhone.startsWith('+')) {
        // Extract country code or use default
        final countryCode = PhoneValidator.extractCountryCode(phoneNumber);
        if (countryCode != null) {
          formattedPhone = PhoneValidator.formatWithCountryCode(
            phoneNumber,
            countryCode,
          );
        } else {
          // Default to +1 if no country code found
          formattedPhone = '+1$phoneNumber';
        }
      }

      _phoneNumber = formattedPhone;
      debugPrint(
        '[PhoneAuthService] Requesting verification code for: $formattedPhone',
      );

      final result = await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        codeSent: (verificationId) {
          debugPrint('[PhoneAuthService] ✅ Code sent successfully');
          debugPrint('[PhoneAuthService] Verification ID: $verificationId');
          _verificationId = verificationId;
          _startResendTimer(resendTimeout);
          onCodeSent(verificationId);
        },
        verificationFailed: (error) {
          debugPrint(
            '[PhoneAuthService] ❌ Verification failed: ${error.message}',
          );
          _verificationId = null;
          onError(error);
        },
        codeAutoRetrievalTimeout: (verificationId, resendToken) {
          _verificationId = verificationId;
        },
      );

      return result;
    } catch (e) {
      final error = AuthError.fromFirebaseException(e);
      onError(error);
      return PhoneAuthResult.failure(error);
    }
  }

  /// Verify SMS code
  Future<PhoneAuthResult> verifyCode(String smsCode) async {
    debugPrint('[PhoneAuthService] Verifying SMS code...');
    if (_verificationId == null) {
      debugPrint('[PhoneAuthService] ❌ No verification ID found');
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.unknown,
          message: 'No verification ID found. Please request a new code.',
        ),
      );
    }

    if (smsCode.isEmpty || smsCode.length != 6) {
      debugPrint('[PhoneAuthService] ❌ Invalid code length: ${smsCode.length}');
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.invalidCode,
          message: 'Please enter a valid 6-digit code',
        ),
      );
    }

    try {
      debugPrint('[PhoneAuthService] Signing in with credential...');
      final result = await _authService.signInWithCredential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      if (result.success) {
        debugPrint('[PhoneAuthService] ✅ Sign in successful!');
        debugPrint('[PhoneAuthService] User ID: ${result.userId}');
        debugPrint('[PhoneAuthService] Phone: ${result.phoneNumber}');
        _stopResendTimer();
        _stopListeningToSms();
      } else {
        debugPrint(
          '[PhoneAuthService] ❌ Sign in failed: ${result.error?.message}',
        );
      }

      return result;
    } catch (e) {
      return PhoneAuthResult.failure(AuthError.fromFirebaseException(e));
    }
  }

  /// Start listening for SMS auto-fill (Android)
  /// Note: This is a placeholder. Implement SMS auto-fill using platform-specific code
  /// or use a package like `sms_autofill` if available
  Future<String?> startListeningToSms({
    required Function(String code) onCodeReceived,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (_isListeningToSms) {
      return null;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        _isListeningToSms = true;
        // TODO: Implement SMS auto-fill using platform channels or a package
        // For now, this is a placeholder
        debugPrint('SMS auto-fill not implemented. Use manual entry.');
        _stopListeningToSms();
      }
    } catch (e) {
      debugPrint('Error starting SMS listener: $e');
      _stopListeningToSms();
    }

    return null;
  }

  /// Stop listening for SMS auto-fill
  void _stopListeningToSms() {
    _isListeningToSms = false;
    // Note: flutter_sms_autofill doesn't expose a stop method
    // The listener will automatically stop after timeout
  }

  /// Resend verification code
  Future<PhoneAuthResult> resendCode({
    required Function(String verificationId) onCodeSent,
    required Function(AuthError error) onError,
    int resendTimeout = 60,
  }) async {
    if (_phoneNumber == null) {
      return PhoneAuthResult.failure(
        AuthError.custom(
          type: AuthErrorType.unknown,
          message: 'No phone number found. Please enter a phone number first.',
        ),
      );
    }

    _stopResendTimer();
    return await sendVerificationCode(
      phoneNumber: _phoneNumber!,
      onCodeSent: onCodeSent,
      onError: onError,
      resendTimeout: resendTimeout,
    );
  }

  /// Start resend countdown timer
  void _startResendTimer(int timeout) {
    _stopResendTimer();
    _resendCountdown = timeout;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _resendCountdown--;
      if (_resendCountdown <= 0) {
        _stopResendTimer();
      }
    });
  }

  /// Stop resend timer
  void _stopResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _resendCountdown = 0;
  }

  /// Clear verification data
  void clear() {
    _verificationId = null;
    _phoneNumber = null;
    _stopResendTimer();
    _stopListeningToSms();
  }

  /// Dispose resources
  void dispose() {
    clear();
  }
}
