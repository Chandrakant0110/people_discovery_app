# Firebase Mobile Authentication Module

A standalone, reusable Firebase phone authentication module with SMS verification. This module can be easily copied to other projects with minimal configuration.

## Features

- ✅ Phone number authentication with Firebase
- ✅ SMS verification code
- ✅ Auto-detect SMS code on Android
- ✅ Manual OTP entry with 6-digit input
- ✅ Resend code functionality with countdown timer
- ✅ Country code picker
- ✅ Phone number validation
- ✅ Comprehensive error handling
- ✅ Customizable UI (colors, text styles, messages)
- ✅ Clean architecture with separation of concerns

## Setup Instructions

### 1. Firebase Configuration

1. **Enable Phone Authentication in Firebase Console:**
   - Go to Firebase Console → Authentication → Sign-in method
   - Enable "Phone" as a sign-in provider
   - Add your app's SHA-1 fingerprint (Android) or configure APNs (iOS)

2. **Android Setup:**
   - Add SMS permission to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.RECEIVE_SMS"/>
   <uses-permission android:name="android.permission.READ_SMS"/>
   ```
   - Configure SHA-1 fingerprint in Firebase Console

3. **iOS Setup:**
   - Configure APNs in Firebase Console
   - Add reCAPTCHA verification support (handled automatically by Firebase)

### 2. Dependencies

The following packages are required (already added to `pubspec.yaml`):

```yaml
dependencies:
  firebase_core: ^4.2.1
  firebase_auth: ^4.15.0
  country_code_picker: ^3.0.0
  flutter_sms_autofill: ^2.2.0
```

### 3. Initialize Firebase

Make sure Firebase is initialized in your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
```

## Usage

### Basic Usage

```dart
import 'package:splitwise_clone/firebase_mobile_auth/firebase_mobile_auth.dart';

// Navigate to phone input screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PhoneInputScreen(
      config: AuthConfig.defaultConfig(),
      onCodeSent: (phoneNumber, verificationId) {
        // Navigate to OTP screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
              onVerified: (userId, phoneNumber) {
                // Handle successful authentication
                print('User authenticated: $userId');
                print('Phone number: $phoneNumber');
                // Navigate to home screen
              },
              onError: (error) {
                // Handle error
                print('Error: ${error.message}');
              },
            ),
          ),
        );
      },
      onError: (error) {
        // Handle error
        print('Error: ${error.message}');
      },
    ),
  ),
);
```

### Custom Configuration

```dart
final customConfig = AuthConfig(
  primaryColor: Colors.blue,
  errorColor: Colors.red,
  backgroundColor: Colors.white,
  textColor: Colors.black87,
  resendCodeTimeout: 60, // seconds
  codeExpirationTimeout: 300, // seconds
  phoneInputLabel: 'Enter your phone number',
  phoneInputHint: '1234567890',
  sendCodeButtonText: 'Send OTP',
  verifyButtonText: 'Verify',
  defaultCountryCode: 'US',
  showCountryCodePicker: true,
);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PhoneInputScreen(
      config: customConfig,
      onCodeSent: (phoneNumber, verificationId) {
        // Handle code sent
      },
    ),
  ),
);
```

### Using Services Directly

If you need more control, you can use the services directly:

```dart
import 'package:splitwise_clone/firebase_mobile_auth/firebase_mobile_auth.dart';

final phoneAuthService = PhoneAuthService();
final authService = FirebaseAuthService();

// Send verification code
final result = await phoneAuthService.sendVerificationCode(
  phoneNumber: '+1234567890',
  onCodeSent: (verificationId) {
    print('Code sent. Verification ID: $verificationId');
  },
  onError: (error) {
    print('Error: ${error.message}');
  },
);

// Verify code
final verifyResult = await phoneAuthService.verifyCode('123456');
if (verifyResult.success) {
  print('User authenticated: ${verifyResult.userId}');
} else {
  print('Error: ${verifyResult.error?.message}');
}
```

### Check Authentication Status

```dart
final authService = FirebaseAuthService();

// Check if user is authenticated
if (authService.isAuthenticated) {
  print('User ID: ${authService.currentUserId}');
  print('Phone: ${authService.currentUserPhone}');
}

// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  if (user != null) {
    print('User signed in: ${user.uid}');
  } else {
    print('User signed out');
  }
});
```

### Sign Out

```dart
final authService = FirebaseAuthService();
await authService.signOut();
```

## Architecture

The module follows a clean architecture pattern:

```
lib/firebase_mobile_auth/
├── models/
│   └── auth_state.dart              # Auth state enums and models
├── services/
│   ├── firebase_auth_service.dart   # Core Firebase auth logic
│   └── phone_auth_service.dart      # Phone-specific auth operations
├── widgets/
│   ├── phone_input_screen.dart     # Phone number entry screen
│   ├── otp_verification_screen.dart # OTP entry/verification screen
│   └── auth_error_widget.dart      # Error display widget
├── utils/
│   ├── phone_validator.dart         # Phone number validation
│   └── country_code_helper.dart     # Country code utilities
├── config/
│   └── auth_config.dart             # Configuration class
└── firebase_mobile_auth.dart        # Main export file
```

## API Reference

### Models

- **AuthStatus**: Enum for authentication status
  - `unauthenticated`: Initial state
  - `codeSent`: Verification code sent
  - `verifying`: Code verification in progress
  - `authenticated`: User authenticated
  - `error`: Error occurred

- **PhoneAuthResult**: Result of phone authentication
  - `success`: Whether operation was successful
  - `verificationId`: Verification ID from Firebase
  - `phoneNumber`: Phone number used
  - `userId`: Authenticated user ID
  - `error`: Error if operation failed

- **AuthError**: Authentication error
  - `type`: Error type enum
  - `message`: User-friendly error message
  - `code`: Firebase error code

### Services

- **FirebaseAuthService**: Core Firebase authentication
  - `currentUser`: Get current user
  - `isAuthenticated`: Check authentication status
  - `signOut()`: Sign out user
  - `verifyPhoneNumber()`: Send verification code
  - `signInWithCredential()`: Sign in with verification code

- **PhoneAuthService**: Phone authentication with SMS
  - `sendVerificationCode()`: Send SMS code
  - `verifyCode()`: Verify SMS code
  - `resendCode()`: Resend verification code
  - `startListeningToSms()`: Auto-detect SMS code (Android)

### Widgets

- **PhoneInputScreen**: Phone number input with country code picker
- **OtpVerificationScreen**: OTP verification with auto-fill support
- **AuthErrorWidget**: Error display widget

### Configuration

- **AuthConfig**: Customization options
  - Colors (primary, error, background, text)
  - Text styles
  - Button styles
  - Timeout durations
  - Custom messages
  - Country code settings

## Troubleshooting

### SMS Code Not Received

1. Check Firebase Console → Authentication → Sign-in method → Phone
2. Verify phone number format (include country code)
3. Check SMS quota in Firebase Console
4. For Android: Verify SHA-1 fingerprint is configured
5. For iOS: Verify APNs is configured

### Auto-fill Not Working (Android)

1. Ensure SMS permissions are granted
2. Check that `flutter_sms_autofill` is properly configured
3. Verify the SMS format matches Firebase's expected format
4. Try manual entry as fallback

### Invalid Phone Number Error

- Ensure phone number includes country code
- Format: `+[country code][number]` (e.g., `+1234567890`)
- Use country code picker for correct format

### Code Expired

- Default expiration: 5 minutes (300 seconds)
- Use resend code functionality
- Request a new code if expired

## Integration Guide

### Copying to Another Project

1. Copy the entire `lib/firebase_mobile_auth/` folder to your project
2. Add required dependencies to `pubspec.yaml`
3. Update import paths in your code
4. Configure Firebase in your project
5. Initialize Firebase in `main.dart`

### Customization

The module is designed to be customizable:

- **UI Customization**: Use `AuthConfig` to customize colors, styles, and messages
- **Error Handling**: Customize error messages in `AuthError` class
- **Validation**: Modify `PhoneValidator` for custom validation rules
- **Country Codes**: Update `CountryCodeHelper` for additional countries

## License

This module is part of the Splitwise Clone project and follows the same license.

## Support

For issues or questions, please refer to the main project documentation or create an issue in the project repository.
