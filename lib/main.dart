import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load SDK configurations
  await dotenv.load(fileName: ".env");
  // Initialize and run app
  runApp(const AmiApp());
}
