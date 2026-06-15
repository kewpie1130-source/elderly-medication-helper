import 'package:flutter/material.dart';

// [邱靖喻] 全組統一主題，禁止其他組員修改
// 需修改請先找邱靖喻確認
class AppTheme {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFF81C784);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF222222);

  static const double borderRadius = 20.0;
  static const double cardElevation = 3.0;
  static const double titleFontSize = 24.0;
  static const double sectionFontSize = 20.0;
  static const double bodyFontSize = 16.0;
  static const double buttonFontSize = 18.0;

  static ThemeData get appTheme => ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
          titleLarge: TextStyle(
            fontSize: sectionFontSize,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyMedium: TextStyle(
            fontSize: bodyFontSize,
            color: textDark,
          ),
          labelLarge: TextStyle(
            fontSize: buttonFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
