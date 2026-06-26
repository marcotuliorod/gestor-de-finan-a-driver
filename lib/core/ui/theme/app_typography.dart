import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _baseFamily = 'Roboto';

  static const displayLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const titleMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );

  static const bodyLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static const labelSmall = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  // Monetary value display
  static const moneyLarge = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
  );

  static const moneyMedium = TextStyle(
    fontFamily: _baseFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
}
