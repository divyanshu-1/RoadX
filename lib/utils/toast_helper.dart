import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Toast + snackbar helpers for consistent user feedback.
class ToastHelper {
  static void show(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  static void success(String message) => show(message);
  static void error(String message) => show(message, isError: true);
}
