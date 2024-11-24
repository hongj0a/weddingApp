import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF6433F0); // 피그마에서 추출한 색상값
  static const backgroundColor = Color(0xFFFFFFFF);
  static const textColor = Color(0xFF000000);
  static const secondaryColor = Color(0xFF19236E);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
}


