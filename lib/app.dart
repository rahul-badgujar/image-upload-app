import 'package:flutter/material.dart';
import 'package:image_upload_app/constants.dart';
import 'package:image_upload_app/screens/home/home_screen.dart';

/// Top Level widget of App
class ImageUploadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Title of App
      title: appName,
      // Setting app theme
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // Removing Debug Banner from Screen
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
