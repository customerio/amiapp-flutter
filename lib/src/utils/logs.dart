import 'package:flutter/foundation.dart';

void debugPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}
