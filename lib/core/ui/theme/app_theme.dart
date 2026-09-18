import 'package:driver_finance/core/ui/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static ThemeData light() => _build();
  static ThemeData dark() => _build();

  static ThemeData _build() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dfaBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.dfaGreen,
        secondary: AppColors.dfaBlue,
        surface: AppColors.dfaSurface,
        error: AppColors.dfaRed,
        onPrimary: Color(0xFF06210F),
        onSurface: AppColors.dfaInk,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.ibmPlexSansTextTheme(base.textTheme).apply(
        bodyColor: AppColors.dfaInk,
        displayColor: AppColors.dfaInk,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.dfaRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: AppColors.dfaLine),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.dfaSurface,
        foregroundColor: AppColors.dfaInk,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dfaLine,
        thickness: 1,
        space: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0A0D11),
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return GoogleFonts.ibmPlexMono(
            fontSize: 8.5,
            letterSpacing: 0.1,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.dfaGreen : AppColors.dfaInk4,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.dfaGreen : AppColors.dfaInk4,
            size: 18,
          );
        }),
      ),
    );
  }
}
