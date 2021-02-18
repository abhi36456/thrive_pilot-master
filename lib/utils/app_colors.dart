import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color.fromRGBO(41, 167, 243, 1);
  static const Color secondary = Color.fromRGBO(0, 138, 255, 1);
  static const LinearGradient gradient = LinearGradient(
    colors: [
      secondary,
      primaryColor,
    ],
  );
}
