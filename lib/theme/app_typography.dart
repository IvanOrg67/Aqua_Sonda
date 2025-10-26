import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const _font = 'Roboto'; // cambia si usarás otra

  static TextTheme textTheme = const TextTheme(
    displaySmall: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w700,
        fontSize: 32,
        color: AppColors.textPrimary),
    headlineSmall: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: AppColors.textPrimary),
    titleMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: AppColors.textPrimary),
    bodyLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: AppColors.textPrimary),
    bodyMedium: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.textSecondary),
    labelLarge: TextStyle(
        fontFamily: _font,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.white),
  );
}
