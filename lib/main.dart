import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:permission_handler/permission_handler.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    enableFlutterDriverExtension();
  } catch (exception) {
    if (kDebugMode) {
      print(exception);
    }
  }

  await dotenv.load(fileName: ".env");
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  runApp(const AmiApp());
}
