import 'package:flutter/material.dart';
import 'package:people_discovery_app/firebase_mobile_auth/firebase_mobile_auth.dart';

/// Authentication screen that handles phone number authentication
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 32),
              const Text(
                'People Discovery',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connect with talented professionals in your area',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  debugPrint('[AuthScreen] Starting phone authentication flow...');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneInputScreen(
                        config: AuthConfig.defaultConfig(),
                        onCodeSent: (phoneNumber, verificationId) {
                          debugPrint(
                            '[AuthScreen] Code sent, navigating to OTP screen...',
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpVerificationScreen(
                                phoneNumber: phoneNumber,
                                verificationId: verificationId,
                                onVerified: (userId, phoneNumber) {
                                  debugPrint(
                                    '[AuthScreen] ✅ Authentication successful!',
                                  );
                                  debugPrint(
                                    '[AuthScreen] User ID: $userId, Phone: $phoneNumber',
                                  );
                                  // Navigation will be handled automatically by AuthWrapper
                                  // via authStateChanges stream
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                onError: (error) {
                                  debugPrint(
                                    '[AuthScreen] ❌ Authentication error: ${error.message}',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Error: ${error.message}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        onError: (error) {
                          debugPrint(
                            '[AuthScreen] ❌ Error sending code: ${error.message}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error: ${error.message}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Continue with Phone Number'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

