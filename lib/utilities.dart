import 'package:flutter/material.dart';

/// Helper function to show Snackbar within given [context], showing [content] provided
void showSnackbar(BuildContext context, Widget content) {
  Scaffold.of(context).showSnackBar(
    SnackBar(content: content),
  );
}
