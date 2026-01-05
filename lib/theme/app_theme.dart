import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background - Light
  static const Color bgLight = Color(0xFFFDF6F0);
  static const Color bgLightCard = Color(0xFFFFFFFA);
  static const Color bgLightSurface = Color(0xFFFFF8F2);
  
  // Background - Dark
  static const Color bgDark = Color(0xFF1E1E2A);
  static const Color bgDarkCard = Color(0xFF2A2A3A);
  static const Color bgDarkSurface = Color(0xFF252535);
  
  // Primary
  static const Color primary = Color(0xFFE8A0A0);
  static const Color primaryLight = Color(0xFFFFD4D4);
  static const Color primaryDark = Color(0xFFD48A8A);
  
  // Accents
  static const Color accentBlue = Color(0xFFA8D4E6);
  static const Color accentGreen = Color(0xFFB8E0C8);
  static const Color accentPeach = Color(0xFFFFD8C0);
  static const Color accentLavender = Color(0xFFD4C4E8);
  static const Color accentYellow = Color(0xFFFFF0B8);
  
  // Text - Light
  static const Color textPrimaryLight = Color(0xFF4A4458);
  static const Color textSecondaryLight = Color(0xFF8A8494);
  static const Color textMutedLight = Color(0xFFB0A8B8);
  
  // Text - Dark
  static const Color textPrimaryDark = Color(0xFFF0EAF4);
  static const Color textSecondaryDark = Color(0xFFB8B0C0);
  static const Color textMutedDark = Color(0xFF807888);
}

class AppTypography {
  // Headings - Quicksand Bold
  static TextStyle h1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle h2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      letterSpacing: -0.3,
      height: 1.3,
    );
  }

  static TextStyle h3(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      height: 1.3,
    );
  }

  // Body
  static TextStyle body(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      height: 1.4,
    );
  }

  // Labels
  static TextStyle label(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      letterSpacing: 0.3,
      height: 1.3,
    );
  }

  static TextStyle caption(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
      height: 1.2,
    );
  }

  // Button
  static TextStyle button() {
    return GoogleFonts.quicksand(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  // Stat Numbers
  static TextStyle statNumber(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      letterSpacing: -1,
      height: 1,
    );
  }
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accentBlue,
      surface: AppColors.bgLightSurface,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      headlineSmall: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryLight,
      ),
      bodySmall: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedLight,
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgLightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accentBlue,
      surface: AppColors.bgDarkSurface,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      headlineSmall: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryDark,
      ),
      bodySmall: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedDark,
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
  );
}