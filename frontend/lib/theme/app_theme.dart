import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color lavender = Color(0xFFA78BFA);
  static const Color lavender2 = Color(0xFFB794F4);
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
        gradient: const LinearGradient(colors: [lavender, lavender2]),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      );
}

