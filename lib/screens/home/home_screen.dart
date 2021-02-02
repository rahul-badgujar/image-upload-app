import 'package:flutter/material.dart';
import 'package:image_upload_app/constants.dart';
import 'package:image_upload_app/screens/home/components/body.dart';

/// Home Screen of App
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(appName),
        ),
        body: Body(),
      ),
    );
  }
}
