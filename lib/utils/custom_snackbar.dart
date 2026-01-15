import 'package:flutter/material.dart';
import '../theme.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color background;
    Color textColor = Colors.white;

    switch (type) {
      case SnackBarType.success:
        background = Colors.green.shade600;
        break;
      case SnackBarType.error:
        background = theme.colorScheme.error;
        break;
      case SnackBarType.info:
      default:
        background = AppColors.primarySkyBlue;
        break;
    }

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }
}

