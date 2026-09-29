import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme_extension.dart';

class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      backgroundColor: context.semanticColors.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      backgroundColor: Theme.of(context).colorScheme.error,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      backgroundColor: Theme.of(context).colorScheme.primary,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: backgroundColor,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusChip),
        content: Row(
          children: <Widget>[
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
