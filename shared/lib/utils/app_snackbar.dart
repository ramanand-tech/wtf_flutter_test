import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'humanize_error.dart';
import 'theme.dart';

/// Consistent snackbars with human-readable errors and copy action.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      backgroundColor: AppColors.success,
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message: message);
  }

  static void showError(
    BuildContext context,
    String message, {
    String? copyText,
  }) {
    final friendly = humanizeError(message);
    final payload = copyText ?? message;
    _show(
      context,
      message: friendly,
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 6),
      action: SnackBarAction(
        label: 'Copy error',
        textColor: Colors.white,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: payload));
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showInfo(context, 'Error details copied');
        },
      ),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          action: action,
        ),
      );
  }
}
