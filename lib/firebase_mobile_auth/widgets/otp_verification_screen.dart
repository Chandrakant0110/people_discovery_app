import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/auth_config.dart';
import '../models/auth_state.dart';
import '../services/firebase_auth_service.dart';
import 'auth_error_widget.dart';

/// OTP verification screen with auto-fill SMS support
class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final AuthConfig config;
  final Function(String userId, String phoneNumber) onVerified;
  final Function(AuthError error)? onError;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    this.config = const AuthConfig(),
    required this.onVerified,
    this.onError,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _authService = FirebaseAuthService();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  AuthError? _error;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('[OTP Verification] Screen initialized');
    debugPrint('[OTP Verification] Phone number: ${widget.phoneNumber}');
    debugPrint('[OTP Verification] Verification ID: ${widget.verificationId}');
    _startResendTimer();
    // Note: SMS autofill can be implemented using sms_autofill package
    // For now, manual entry is supported and works well
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = widget.config.resendCodeTimeout;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCountdown--;
          if (_resendCountdown <= 0) {
            _resendTimer?.cancel();
          }
        });
      }
    });
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, verify code
        _focusNodes[index].unfocus();
        final code = _getOtpCode();
        if (code.length == 6) {
          _verifyCode(code);
        }
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 6) {
      debugPrint('[OTP Verification] Invalid code length: ${code.length}');
      return;
    }

    debugPrint('[OTP Verification] Verifying code: $code');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verifying code...'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );

    // Use the verification ID from widget
    final result = await _authService.signInWithCredential(
      verificationId: widget.verificationId,
      smsCode: code,
    );

    if (result.success) {
      debugPrint('[OTP Verification] ✅ Verification successful!');
      debugPrint('[OTP Verification] User ID: ${result.userId}');
      debugPrint('[OTP Verification] Phone: ${result.phoneNumber}');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Verification successful!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
      widget.onVerified(
        result.userId ?? '',
        result.phoneNumber ?? widget.phoneNumber,
      );
    } else {
      debugPrint(
        '[OTP Verification] ❌ Verification failed: ${result.error?.message}',
      );
      setState(() {
        _isLoading = false;
        _error = result.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Verification failed: ${result.error?.message ?? 'Unknown error'}',
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        ),
      );
      widget.onError?.call(result.error!);
      // Clear OTP fields on error
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0) {
      debugPrint(
        '[OTP Verification] Resend not available yet. Countdown: $_resendCountdown',
      );
      return;
    }

    debugPrint(
      '[OTP Verification] Resending verification code to: ${widget.phoneNumber}',
    );
    setState(() {
      _isLoading = true;
      _error = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resending verification code...'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );

    await _authService.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      codeSent: (verificationId) {
        debugPrint(
          '[OTP Verification] Code resent successfully. New Verification ID: $verificationId',
        );
        setState(() {
          _isLoading = false;
        });
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Verification code resent! Check your SMS.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      },
      verificationFailed: (error) {
        debugPrint(
          '[OTP Verification] ❌ Failed to resend code: ${error.message}',
        );
        setState(() {
          _isLoading = false;
          _error = error;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to resend: ${error.message}'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
        widget.onError?.call(error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.config.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.config.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: widget.config.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Title
              Text(
                'Enter Verification Code',
                style:
                    widget.config.titleTextStyle ??
                    TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.config.textColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                widget.config.otpInputLabel ??
                    'We sent a code to ${widget.phoneNumber}',
                style:
                    widget.config.bodyTextStyle ??
                    TextStyle(
                      fontSize: 16,
                      color: widget.config.secondaryTextColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Error widget
              if (_error != null) ...[
                AuthErrorWidget(error: _error!, config: widget.config),
                const SizedBox(height: 24),
              ],
              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    height: 80,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      textAlignVertical: TextAlignVertical.center,
                      maxLength: 1,
                      enabled: !_isLoading,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.config.textColor,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.config.primaryColor.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.config.primaryColor.withOpacity(0.3),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: widget.config.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: widget.config.backgroundColor,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) => _onOtpChanged(index, value),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              // Loading indicator or verify button
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.config.primaryColor,
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final code = _getOtpCode();
                      if (code.length == 6) {
                        _verifyCode(code);
                      }
                    },
                    style:
                        widget.config.buttonStyle ??
                        ElevatedButton.styleFrom(
                          backgroundColor: widget.config.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    child: Text(
                      widget.config.verifyButtonText ?? 'Verify',
                      style:
                          widget.config.buttonTextStyle ??
                          TextStyle(
                            color: widget.config.backgroundColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // Resend code button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive the code? ',
                    style: TextStyle(
                      color: widget.config.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: _resendCountdown > 0 || _isLoading
                        ? null
                        : _resendCode,
                    child: Text(
                      _resendCountdown > 0
                          ? 'Resend in ${_resendCountdown}s'
                          : widget.config.resendCodeButtonText ?? 'Resend',
                      style: TextStyle(
                        color: _resendCountdown > 0 || _isLoading
                            ? widget.config.secondaryTextColor
                            : widget.config.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
