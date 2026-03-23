import 'package:flutter/material.dart';

class AppAlerts {
  AppAlerts._();

  static void showError(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.red.shade600,
      icon: Icons.error_outline,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context: context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle_outline,
    );
  }

  static void _show({
    required BuildContext context,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
