import 'package:flutter/material.dart';

extension CustomerIOExtensions on BuildContext {
  void showSnackBar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
  }
}
