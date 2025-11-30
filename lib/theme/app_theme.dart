import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Colors.black;
  static const Color accentColor = Colors.white;
  static const Color backgroundColor = Color(
    0xFFF5F5F7,
  ); // iOS light gray background
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFFF3B30); // iOS system red

  // iOS System Gray Colors
  static const Color systemGray = Color(0xFF8E8E93); // iOS system gray
  static const Color systemGray2 = Color(0xFFAEAEB2); // iOS system gray 2
  static const Color systemGray3 = Color(0xFFC7C7CC); // iOS system gray 3
  static const Color systemGray4 = Color(0xFFD1D1D6); // iOS system gray 4
  static const Color systemGray5 = Color(0xFFE5E5EA); // iOS system gray 5
  static const Color systemGray6 = Color(
    0xFFF5F5F7,
  ); // iOS system gray 6 (light)

  // iOS System Colors
  static const Color systemGreen = Color(0xFF34C759); // iOS system green
  static const Color systemBlue = Color(0xFF007AFF); // iOS system blue
  static const Color systemYellow = Color(0xFFFFCC00); // iOS system yellow
  static const Color systemRed = Color(0xFFFF3B30); // iOS system red

  // Dark Mode Colors
  static const Color darkSurface = Color(0xFF1C1C1E); // iOS system gray 6 dark

  // Speed Indicator Colors
  static const Color speedSlow = Color(0xFF34C759); // Green for low speed
  static const Color speedMedium = Color(0xFFFFCC00); // Yellow for medium speed
  static const Color speedFast = Color(0xFFFF3B30); // Red for high speed

  // Gradient Colors for Speedometer
  static const Color gradientGreen = Color(0xFF69F0AE); // greenAccent
  static const Color gradientYellow = Color(0xFFFFFF8D); // yellowAccent
  static const Color gradientRed = Color(0xFFFF8A80); // redAccent

  // Transparent/Opacity Colors
  static Color whiteTransparent10 = Colors.white.withValues(alpha: 0.1);
  static Color whiteTransparent20 = Colors.white.withValues(alpha: 0.2);
  static Color whiteTransparent30 = Colors.white.withValues(alpha: 0.3);
  static Color whiteTransparent70 = Colors.white.withValues(alpha: 0.7);
  static Color whiteTransparent90 = Colors.white.withValues(alpha: 0.9);

  static Color blackTransparent10 = Colors.black.withValues(alpha: 0.1);
  static Color blackTransparent15 = Colors.black.withValues(alpha: 0.15);

  static Color greyTransparent10 = Colors.grey.withValues(alpha: 0.1);
  static Color greyTransparent20 = Colors.grey.withValues(alpha: 0.2);

  static Color redTransparent30 = const Color(
    0xFFFF3B30,
  ).withValues(alpha: 0.3);
  static Color redTransparent90 = const Color(
    0xFFFF3B30,
  ).withValues(alpha: 0.9);

  static Color greenTransparent10 = const Color(
    0xFF34C759,
  ).withValues(alpha: 0.1);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: accentColor,
        secondary: primaryColor,
        onSecondary: accentColor,
        surface: surfaceColor,
        onSurface: primaryColor,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: primaryColor, displayColor: primaryColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarBrightness: Brightness.light, // iOS
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: systemGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: accentColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        onPrimary: primaryColor,
        secondary: accentColor,
        onSecondary: primaryColor,
        surface: darkSurface,
        onSurface: accentColor,
        error: errorColor,
        onError: accentColor,
      ),
      scaffoldBackgroundColor: primaryColor,
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: accentColor, displayColor: accentColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: accentColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: systemGray,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}
