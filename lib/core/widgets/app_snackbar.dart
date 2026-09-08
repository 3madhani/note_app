import 'package:flutter/material.dart';

abstract final class AppSnackbar {
  static void show(BuildContext context, String message) {
    if (message.trim().isEmpty) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
