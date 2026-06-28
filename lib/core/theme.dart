import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.dark.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4FC3F7),
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.dark.surface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.bg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      dividerColor: AppColors.dark.divider,
      extensions: const [AppColors.dark],
    );
  }
}
