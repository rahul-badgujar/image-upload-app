import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  // Initialize FlutterFire.
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ImageUploadApp());
}
