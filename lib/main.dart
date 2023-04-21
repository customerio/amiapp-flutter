import 'package:customer_io/customer_io.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';
import 'src/app.dart';
import 'src/utils/logs.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // For any other Firebase services in the background, make sure to call
  // `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  CustomerIO.messagingPush()
      .onBackgroundMessageReceived(message.toMap())
      .then((handled) {
    // handled is true if notification was handled by Customer.io SDK; false otherwise
    debugLog(
        'Message received in background was handled by Customer.io SDK: $handled');
    return handled;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const AmiApp());
}
