import 'package:flutter/material.dart';

/// Configuration class for customizing the authentication UI and behavior
class AuthConfig {
  /// Primary color for buttons and highlights
  final Color primaryColor;
  
  /// Error color for error messages
  final Color errorColor;
  
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Secondary text color
  final Color secondaryTextColor;
  
  /// Button text style
  final TextStyle? buttonTextStyle;
  
  /// Title text style
  final TextStyle? titleTextStyle;
  
  /// Body text style
  final TextStyle? bodyTextStyle;
  
  /// Input decoration theme
  final InputDecorationTheme? inputDecorationTheme;
  
  /// Button style
  final ButtonStyle? buttonStyle;
  
  /// Resend code timeout in seconds (default: 60)
  final int resendCodeTimeout;
  
  /// Code expiration timeout in seconds (default: 300)
  final int codeExpirationTimeout;
  
  /// Custom phone input label
  final String? phoneInputLabel;
  
  /// Custom phone input hint
  final String? phoneInputHint;
  
  /// Custom OTP input label
  final String? otpInputLabel;
  
  /// Custom OTP input hint
  final String? otpInputHint;
  
  /// Custom send code button text
  final String? sendCodeButtonText;
  
  /// Custom verify button text
  final String? verifyButtonText;
  
  /// Custom resend code button text
  final String? resendCodeButtonText;
  
  /// Show country code picker
  final bool showCountryCodePicker;
  
  /// Default country code (e.g., 'US', 'IN')
  final String? defaultCountryCode;

  const AuthConfig({
    this.primaryColor = Colors.blue,
    this.errorColor = Colors.red,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.secondaryTextColor = Colors.black54,
    this.buttonTextStyle,
    this.titleTextStyle,
    this.bodyTextStyle,
    this.inputDecorationTheme,
    this.buttonStyle,
    this.resendCodeTimeout = 60,
    this.codeExpirationTimeout = 300,
    this.phoneInputLabel,
    this.phoneInputHint,
    this.otpInputLabel,
    this.otpInputHint,
    this.sendCodeButtonText,
    this.verifyButtonText,
    this.resendCodeButtonText,
    this.showCountryCodePicker = true,
    this.defaultCountryCode,
  });

  /// Default configuration
  factory AuthConfig.defaultConfig() {
    return const AuthConfig();
  }

  /// Create a copy with modified values
  AuthConfig copyWith({
    Color? primaryColor,
    Color? errorColor,
    Color? backgroundColor,
    Color? textColor,
    Color? secondaryTextColor,
    TextStyle? buttonTextStyle,
    TextStyle? titleTextStyle,
    TextStyle? bodyTextStyle,
    InputDecorationTheme? inputDecorationTheme,
    ButtonStyle? buttonStyle,
    int? resendCodeTimeout,
    int? codeExpirationTimeout,
    String? phoneInputLabel,
    String? phoneInputHint,
    String? otpInputLabel,
    String? otpInputHint,
    String? sendCodeButtonText,
    String? verifyButtonText,
    String? resendCodeButtonText,
    bool? showCountryCodePicker,
    String? defaultCountryCode,
  }) {
    return AuthConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      errorColor: errorColor ?? this.errorColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      buttonTextStyle: buttonTextStyle ?? this.buttonTextStyle,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      inputDecorationTheme: inputDecorationTheme ?? this.inputDecorationTheme,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      resendCodeTimeout: resendCodeTimeout ?? this.resendCodeTimeout,
      codeExpirationTimeout: codeExpirationTimeout ?? this.codeExpirationTimeout,
      phoneInputLabel: phoneInputLabel ?? this.phoneInputLabel,
      phoneInputHint: phoneInputHint ?? this.phoneInputHint,
      otpInputLabel: otpInputLabel ?? this.otpInputLabel,
      otpInputHint: otpInputHint ?? this.otpInputHint,
      sendCodeButtonText: sendCodeButtonText ?? this.sendCodeButtonText,
      verifyButtonText: verifyButtonText ?? this.verifyButtonText,
      resendCodeButtonText: resendCodeButtonText ?? this.resendCodeButtonText,
      showCountryCodePicker: showCountryCodePicker ?? this.showCountryCodePicker,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
    );
  }
}

