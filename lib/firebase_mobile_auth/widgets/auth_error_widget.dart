import 'package:flutter/material.dart';
import '../config/auth_config.dart';
import '../models/auth_state.dart';

/// Widget for displaying authentication errors
class AuthErrorWidget extends StatelessWidget {
  final AuthError error;
  final AuthConfig config;
  final VoidCallback? onRetry;

  const AuthErrorWidget({
    super.key,
    required this.error,
    required this.config,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.errorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: config.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.message,
                  style: TextStyle(
                    color: config.errorColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: config.errorColor,
                  side: BorderSide(color: config.errorColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

