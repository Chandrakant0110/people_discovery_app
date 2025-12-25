import 'package:flutter/material.dart';
import 'package:people_discovery_app/firebase_mobile_auth/firebase_mobile_auth.dart';

/// Home screen for authenticated users
/// 
/// This is a placeholder screen that will be replaced with the actual
/// discovery/home screen in later phases.
class HomeScreen extends StatelessWidget {
  final String userId;
  final String? phoneNumber;

  const HomeScreen({
    super.key,
    required this.userId,
    this.phoneNumber,
  });

  Future<void> _handleSignOut(BuildContext context) async {
    final authService = FirebaseAuthService();
    try {
      await authService.signOut();
      debugPrint('[HomeScreen] User signed out successfully');
      // Navigation will be handled automatically by AuthWrapper
      // via authStateChanges stream
    } catch (e) {
      debugPrint('[HomeScreen] Error signing out: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People Discovery'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 32),
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You are successfully authenticated',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('User ID', userId),
                      if (phoneNumber != null)
                        _buildInfoRow('Phone', phoneNumber!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'This is a placeholder home screen.\n'
                'The discovery features will be implemented in the next phase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

