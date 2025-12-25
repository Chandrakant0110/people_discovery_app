import 'package:flutter/material.dart';
import 'package:people_discovery_app/firebase_mobile_auth/firebase_mobile_auth.dart';
import 'package:people_discovery_app/screens/home_screen.dart';
import 'package:people_discovery_app/screens/auth_screen.dart';
import 'package:people_discovery_app/screens/profile_setup_screen.dart';
import 'package:people_discovery_app/services/firestore_service.dart';

/// Wrapper widget that handles authentication state and routing
/// 
/// This widget listens to Firebase auth state changes and automatically
/// redirects users to the appropriate screen based on their authentication status.
/// Firebase Auth automatically persists authentication state, so logged-in users
/// will remain logged in across app restarts.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state (initial load)
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Check synchronously if user is already authenticated
          // This provides immediate feedback while waiting for stream
          final currentUser = authService.currentUser;
          if (currentUser != null) {
            debugPrint('[AuthWrapper] User authenticated (sync check): ${currentUser.uid}');
            // Check if profile exists asynchronously
            return _ProfileCheckWidget(
              userId: currentUser.uid,
              phoneNumber: currentUser.phoneNumber,
            );
          }
          
          // Show loading while waiting for auth state
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        // snapshot.data will be null if user is not authenticated
        final user = snapshot.data;
        if (user != null) {
          // User is authenticated - check if profile exists
          debugPrint('[AuthWrapper] User authenticated: ${user.uid}');
          return _ProfileCheckWidget(
            userId: user.uid,
            phoneNumber: user.phoneNumber,
          );
        } else {
          // User is not authenticated - show auth screen
          debugPrint('[AuthWrapper] User not authenticated - showing auth screen');
          return const AuthScreen();
        }
      },
    );
  }
}

/// Widget that checks if user profile exists and routes accordingly
class _ProfileCheckWidget extends StatefulWidget {
  final String userId;
  final String? phoneNumber;

  const _ProfileCheckWidget({
    required this.userId,
    this.phoneNumber,
  });

  @override
  State<_ProfileCheckWidget> createState() => _ProfileCheckWidgetState();
}

class _ProfileCheckWidgetState extends State<_ProfileCheckWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isChecking = true;
  bool _profileExists = false;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final exists = await _firestoreService.userProfileExists(widget.userId);
    if (mounted) {
      setState(() {
        _isChecking = false;
        _profileExists = exists;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_profileExists) {
      // Profile exists - go to home screen
      debugPrint('[AuthWrapper] Profile exists - navigating to home');
      return HomeScreen(
        userId: widget.userId,
        phoneNumber: widget.phoneNumber,
      );
    } else {
      // Profile doesn't exist - go to profile setup
      debugPrint('[AuthWrapper] Profile does not exist - navigating to profile setup');
      return ProfileSetupScreen(
        userId: widget.userId,
        phoneNumber: widget.phoneNumber ?? '',
      );
    }
  }
}

