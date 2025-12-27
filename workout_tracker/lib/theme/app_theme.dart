import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الرياضية
  static const Color primaryBlue = Color(0xFF1e3a8a); // أزرق داكن
  static const Color secondaryOrange = Color(0xFFf97316); // برتقالي
  static const Color accentRed = Color(0xFFdc2626); // أحمر للتحفيز
  static const Color successGreen = Color(0xFF16a34a); // أخضر للنجاح
  static const Color backgroundColor = Color(0xFFf3f4f6); // رمادي فاتح
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1f2937);
  static const Color textSecondary = Color(0xFF6b7280);

  // تدرجات Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFf97316), Color(0xFFfb923c)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFdc2626), Color(0xFFef4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get theme {
    final base = ThemeData.light();

    return base.copyWith(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBlue,
        secondary: secondaryOrange,
        error: accentRed,
        surface: cardColor,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: GoogleFonts.tajawal(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        color: cardColor,
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFd1d5db)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed),
        ),
        labelStyle: GoogleFonts.tajawal(
          color: textSecondary,
        ),
        hintStyle: GoogleFonts.tajawal(
          color: textSecondary,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: secondaryOrange,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: GoogleFonts.tajawal(
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: GoogleFonts.tajawal(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.tajawal(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.tajawal(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.tajawal(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 14,
          color: textPrimary,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 12,
          color: textSecondary,
        ),
      ),
    );
  }

  // ألوان الفئات
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'kegel':
        return secondaryOrange;
      case 'posture':
        return primaryBlue;
      case 'chest':
        return accentRed;
      case 'back':
        return const Color(0xFF8b5cf6); // بنفسجي
      case 'legs':
        return const Color(0xFF0891b2); // سماوي
      case 'biceps':
        return const Color(0xFFea580c); // برتقالي داكن
      case 'triceps':
        return const Color(0xFFec4899); // وردي
      case 'shoulders':
        return const Color(0xFF14b8a6); // تركواز
      case 'core':
        return successGreen;
      case 'forearms':
        return const Color(0xFF6366f1); // أزرق فاتح
      default:
        return textSecondary;
    }
  }

  // أيقونات الفئات
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'kegel':
        return Icons.favorite;
      case 'posture':
        return Icons.accessibility_new;
      case 'chest':
        return Icons.fitness_center;
      case 'back':
        return Icons.airline_seat_recline_normal;
      case 'legs':
        return Icons.directions_run;
      case 'biceps':
      case 'triceps':
        return Icons.sports_martial_arts;
      case 'shoulders':
        return Icons.sports_gymnastics;
      case 'core':
        return Icons.spa;
      case 'forearms':
        return Icons.pan_tool;
      default:
        return Icons.fitness_center;
    }
  }
}
