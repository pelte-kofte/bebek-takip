import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background - Light
  static const Color bgLight = Color(0xFFFCF7F2);
  static const Color bgLightCard = Color(0xFFFFFCF8);
  static const Color bgLightSurface = Color(0xFFF8F3EE);

  // Background - Dark
  static const Color bgDark = Color(0xFF1E1E2A);
  static const Color bgDarkCard = Color(0xFF2A2A3A);
  static const Color bgDarkSurface = Color(0xFF252535);

  // Primary
  static const Color primary = Color(0xFFE3A3A0);
  static const Color primaryLight = Color(0xFFF6DEDC);
  static const Color primaryDark = Color(0xFFD48F8C);

  // Accents
  static const Color accentBlue = Color(0xFFA8D4E6);
  static const Color accentGreen = Color(0xFFB8E0C8);
  static const Color accentPeach = Color(0xFFF4DDCF);
  static const Color accentLavender = Color(0xFFDCCFEA);
  static const Color accentYellow = Color(0xFFFFF0B8);
  static const Color peach = accentPeach;
  static const Color lavender = accentLavender;
  static const Color mint = accentGreen;

  // Text - Light
  static const Color textPrimaryLight = Color(0xFF4B474F);
  static const Color textSecondaryLight = Color(0xFF807A84);
  static const Color textMutedLight = Color(0xFFA39CA6);

  // Text - Dark
  static const Color textPrimaryDark = Color(0xFFF0EAF4);
  static const Color textSecondaryDark = Color(0xFFB8B0C0);
  static const Color textMutedDark = Color(0xFF807888);

  // Pastel system
  static const Color backgroundCream = bgLight;
  static const Color surfaceWhite = bgLightCard;
  static const Color lavenderAccent = accentLavender;
  static const Color lavenderSoft = Color(0xFFF3EEF7);
  static const Color lavenderPaper = Color(0xFFF7F3F9);
  static const Color lavenderMist = Color(0xFFEEE7F3);
  static const Color lavenderInk = Color(0xFF786E89);
  static const Color splashCream = Color(0xFFFFFAF5);
  static const Color coralPrimary = primary;
  static const Color butterSoft = Color(0xFFFFF7DD);
  static const Color textPrimary = Color(0xFF4D423D);
  static const Color textSecondary = Color(0xFF857B79);
  static const Color borderSoft = Color(0xFFE7E0DA);
  static const Color paper = Color(0xFFFFFBF7);
  static const Color paperMuted = Color(0xFFF7F1EB);
  static const Color controlFill = Color(0xFFF2ECE6);
  static const Color controlActive = Color(0xFFFFFCFA);
  static const Color dividerSoft = Color(0xFFEBE3DC);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> card(bool isDark) {
    if (isDark) {
      return <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }
    return <BoxShadow>[
      const BoxShadow(
        color: Color(0x0D2F221C),
        blurRadius: 14,
        offset: Offset(0, 5),
      ),
    ];
  }

  static List<BoxShadow> button(bool isDark) {
    if (isDark) {
      return <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ];
    }
    return <BoxShadow>[
      const BoxShadow(
        color: Color(0x122F221C),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ];
  }
}

class AppTypography {
  // Headings - Quicksand Bold
  static TextStyle h1(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      letterSpacing: -0.6,
      height: 1.2,
    );
  }

  static TextStyle h2(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      letterSpacing: -0.35,
      height: 1.3,
    );
  }

  static TextStyle h3(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 18,
      fontWeight: FontWeight.w700,
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
      color: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
      height: 1.4,
    );
  }

  // Labels
  static TextStyle label(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: isDark
          ? AppColors.textSecondaryDark
          : AppColors.textSecondaryLight,
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
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
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
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryLight,
        backgroundColor: Colors.white.withValues(alpha: 0.65),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: const BorderSide(color: AppColors.dividerSoft, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgLightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
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
        fontWeight: FontWeight.w600,
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
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.quicksand(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark,
        backgroundColor: Colors.white.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.quicksand(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: EdgeInsets.zero,
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
