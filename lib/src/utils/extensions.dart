import 'dart:io';

import 'package:flutter/material.dart';

extension AmiAppExtensions on BuildContext {
  void showSnackBar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> showMessageDialog(String title, String message,
      {List<Widget>? actions, bool barrierDismissible = true}) {
    List<Widget> actionWidgets = actions ??
        [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(this).pop(),
          ),
        ];
    return showDialog<void>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: actionWidgets,
        );
      },
    );
  }
}

extension AmiAppStringExtensions on String {
  bool equalsIgnoreCase(String? other) => toLowerCase() == other?.toLowerCase();

  int? toIntOrNull() {
    if (isNotEmpty) {
      return int.tryParse(this);
    } else {
      return null;
    }
  }

  double? toDoubleOrNull() {
    if (isNotEmpty) {
      return double.tryParse(this);
    } else {
      return null;
    }
  }

  bool? toBoolOrNull() {
    if (equalsIgnoreCase('true')) {
      return true;
    } else if (equalsIgnoreCase('false')) {
      return false;
    } else {
      return null;
    }
  }

  bool isValidUrl() {
    // Currently only Android fails on URLs with empty host, so allow any URL
    // on other platforms.
    // Empty text is also considered valid.
    if (!Platform.isAndroid || isEmpty) {
      return true;
    }

    final Uri? uri = Uri.tryParse(this);
    if (uri == null) {
      return false;
    }
    // Valid URL with a host and http/https scheme
    return uri.hasAuthority && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
