import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../config/auth_config.dart';
import '../models/auth_state.dart';
import '../services/phone_auth_service.dart';
import '../utils/phone_validator.dart';
import '../utils/country_code_helper.dart';
import 'auth_error_widget.dart';

/// Phone number input screen for authentication
class PhoneInputScreen extends StatefulWidget {
  final AuthConfig config;
  final Function(String phoneNumber, String verificationId) onCodeSent;
  final Function(AuthError error)? onError;

  const PhoneInputScreen({
    super.key,
    this.config = const AuthConfig(),
    required this.onCodeSent,
    this.onError,
  });

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneAuthService = PhoneAuthService();
  String _selectedCountryCode = '+1';
  bool _isLoading = false;
  AuthError? _error;

  @override
  void initState() {
    super.initState();
    _selectedCountryCode =
        CountryCodeHelper.getDialCode(
          widget.config.defaultCountryCode ??
              CountryCodeHelper.getDefaultCountryCode(),
        ) ??
        '+1';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneAuthService.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('[Phone Auth] Validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final phoneNumber = _phoneController.text.trim();
    final fullPhoneNumber = '$_selectedCountryCode$phoneNumber';

    debugPrint('[Phone Auth] Sending verification code to: $fullPhoneNumber');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending verification code...'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue,
      ),
    );

    final result = await _phoneAuthService.sendVerificationCode(
      phoneNumber: fullPhoneNumber,
      onCodeSent: (verificationId) {
        debugPrint(
          '[Phone Auth] Code sent successfully. Verification ID: $verificationId',
        );
        // Ensure we're still mounted before updating state
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        // Use a post-frame callback to ensure context is valid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code sent! Check your SMS.'),
                duration: Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
            widget.onCodeSent(fullPhoneNumber, verificationId);
          }
        });
      },
      onError: (error) {
        debugPrint('[Phone Auth] Error sending code: ${error.message}');
        // Ensure we're still mounted before updating state
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = error;
        });
        // Use a post-frame callback to ensure context is valid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.message}'),
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.red,
              ),
            );
            widget.onError?.call(error);
          }
        });
      },
    );

    if (!result.success && result.error != null) {
      debugPrint('[Phone Auth] Failed to send code: ${result.error?.message}');
      setState(() {
        _isLoading = false;
        _error = result.error;
      });
    }
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final phoneNumber = value.trim();
    if (!PhoneValidator.isValid(phoneNumber)) {
      return 'Please enter a valid phone number';
    }

    return null;
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Title
                Text(
                  'Enter Your Phone Number',
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
                  widget.config.phoneInputLabel ??
                      'We\'ll send you a verification code',
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
                  AuthErrorWidget(
                    error: _error!,
                    config: widget.config,
                    onRetry: _error != null ? _sendCode : null,
                  ),
                  const SizedBox(height: 16),
                ],
                // Phone input field
                if (widget.config.showCountryCodePicker)
                  Row(
                    children: [
                      // Country code picker
                      CountryCodePicker(
                        onChanged: (CountryCode countryCode) {
                          setState(() {
                            _selectedCountryCode = countryCode.dialCode ?? '+1';
                          });
                        },
                        initialSelection:
                            widget.config.defaultCountryCode ?? 'US',
                        favorite: const ['US', 'IN', 'GB'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        padding: EdgeInsets.zero,
                        textStyle: TextStyle(
                          color: widget.config.textColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Phone number input
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          // maxLength: 10, different countries have different max lengths (so planning to use some package for this)
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText:
                                widget.config.phoneInputHint ?? 'Phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: widget.config.backgroundColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: _validatePhoneNumber,
                          enabled: !_isLoading,
                        ),
                      ),
                    ],
                  )
                else
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: widget.config.phoneInputHint ?? 'Phone number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: widget.config.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: _validatePhoneNumber,
                    enabled: !_isLoading,
                  ),
                const SizedBox(height: 32),
                // Send code button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode,
                    style:
                        widget.config.buttonStyle ??
                        ElevatedButton.styleFrom(
                          backgroundColor: widget.config.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.config.backgroundColor,
                              ),
                            ),
                          )
                        : Text(
                            widget.config.sendCodeButtonText ?? 'Send Code',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
