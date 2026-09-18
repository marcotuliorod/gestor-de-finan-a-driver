import 'package:flutter/material.dart';

abstract final class AppColors {
  // DFA Design System — dark-only palette
  static const dfaBg = Color(0xFF06080A);
  static const dfaSurface = Color(0xFF0B0E11);
  static const dfaRaised = Color(0xFF0F141A);
  static const dfaPanel = Color(0xFF111721);
  static const dfaLine = Color(0xFF1F2733);
  static const dfaLine2 = Color(0xFF171C22);

  static const dfaInk = Color(0xFFE6EDF3);
  static const dfaInk2 = Color(0xFF9AA7B4);
  static const dfaInk3 = Color(0xFF8B98A5);
  static const dfaInk4 = Color(0xFF5C6875);
  static const dfaInk5 = Color(0xFF4A5561);

  static const dfaGreen = Color(0xFF35D07F);
  static const dfaGreen2 = Color(0xFF5FE0A0);
  static const dfaAmber = Color(0xFFF2B441);
  static const dfaRed = Color(0xFFFF7A7A);
  static const dfaBlue = Color(0xFF4C8DFF);
  static const dfaViolet = Color(0xFFA78BFA);

  // Legacy aliases kept for existing non-redesigned pages
  static const primary = dfaBlue;
  static const primaryDark = dfaBlue;
  static const income = dfaGreen;
  static const incomeDark = dfaGreen;
  static const expense = dfaRed;
  static const expenseDark = dfaRed;
  static const surface = dfaSurface;
  static const surfaceDark = dfaSurface;
  static const background = dfaBg;
  static const backgroundDark = dfaBg;
  static const textPrimary = dfaInk;
  static const textSecondary = dfaInk3;
  static const textPrimaryDark = dfaInk;
  static const textSecondaryDark = dfaInk3;
  static const warning = dfaAmber;
  static const info = dfaBlue;
}
