import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Violet scale inspired by the requested palette variants.
  static const Color violet950 = Color(0xFF4C1D95);
  static const Color violet900 = Color(0xFF581C87);
  static const Color violet800 = Color(0xFF5B21B6);
  static const Color violet700 = Color(0xFF6B21A8);
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet500 = Color(0xFF9333EA);

  static const Color lavender = violet600;
  static const Color lavender2 = violet500;
  static const Color bg = Color(0xFFF6F6FA);
  static const Color text = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF5B5B66);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: lavender,
        secondary: lavender2,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: text,
        displayColor: text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static BoxDecoration lavenderGradient({double radius = 12}) => BoxDecoration(
        gradient: const LinearGradient(
          colors: [violet800, violet700, violet500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      );
}
