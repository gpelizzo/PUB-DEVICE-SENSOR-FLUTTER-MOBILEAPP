import 'package:flutter/material.dart';

class SnackBarErrorWidget extends SnackBar {
  SnackBarErrorWidget(String message)
      : super(
          content: Text(
            message,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        );
}
