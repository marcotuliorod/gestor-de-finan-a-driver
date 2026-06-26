import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF4A9EFF);

  // Income / positive
  static const income = Color(0xFF34A853);
  static const incomeDark = Color(0xFF4CAF50);

  // Expense / negative
  static const expense = Color(0xFFEA4335);
  static const expenseDark = Color(0xFFEF5350);

  // Neutral
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1E1E2E);
  static const background = Color(0xFFF8F9FA);
  static const backgroundDark = Color(0xFF12121F);

  // Text
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF5F6368);
  static const textPrimaryDark = Color(0xFFE8EAED);
  static const textSecondaryDark = Color(0xFF9AA0A6);

  // Semantic
  static const warning = Color(0xFFFBBC04);
  static const info = Color(0xFF4285F4);
}
