/// Firebase Mobile Authentication Module
/// 
/// A standalone, reusable Firebase phone authentication module with SMS verification.
/// 
/// Usage:
/// ```dart
/// import 'package:splitwise_clone/firebase_mobile_auth/firebase_mobile_auth.dart';
/// 
/// // Navigate to phone input screen
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => PhoneInputScreen(
///       config: AuthConfig.defaultConfig(),
///       onCodeSent: (phoneNumber, verificationId) {
///         Navigator.pushReplacement(
///           context,
///           MaterialPageRoute(
///             builder: (context) => OtpVerificationScreen(
///               phoneNumber: phoneNumber,
///               verificationId: verificationId,
///               onVerified: (userId, phoneNumber) {
///                 // Handle successful authentication
///               },
///             ),
///           ),
///         );
///       },
///     ),
///   ),
/// );
/// ```

// Models
export 'models/auth_state.dart';

// Services
export 'services/firebase_auth_service.dart';
export 'services/phone_auth_service.dart';

// Widgets
export 'widgets/phone_input_screen.dart';
export 'widgets/otp_verification_screen.dart';
export 'widgets/auth_error_widget.dart';

// Configuration
export 'config/auth_config.dart';

// Utilities
export 'utils/phone_validator.dart';
export 'utils/country_code_helper.dart';

