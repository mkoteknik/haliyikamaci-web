import 'package:flutter/material.dart';

/// Customer Theme - Designed for female audience
/// Soft, elegant colors with modern feminine appeal
class CustomerTheme {
  CustomerTheme._();

  // Primary Colors - Elegant Rose/Pink Theme
  static const Color primary = Color(0xFFE91E63);        // Rose Pink
  static const Color primaryLight = Color(0xFFF8BBD9);   // Light Pink
  static const Color primaryDark = Color(0xFFC2185B);    // Dark Rose

  // Secondary Colors - Complementary Pastels
  static const Color secondary = Color(0xFF9C27B0);      // Purple
  static const Color secondaryLight = Color(0xFFE1BEE7); // Light Purple
  static const Color accent = Color(0xFFFF4081);         // Bright Pink Accent

  // Soft Pastel Palette
  static const Color softPink = Color(0xFFFFE4EC);       // Very Light Pink
  static const Color softPurple = Color(0xFFF3E5F5);     // Very Light Purple
  static const Color softPeach = Color(0xFFFFF3E0);      // Light Peach
  static const Color softMint = Color(0xFFE8F5E9);       // Light Mint Green

  // Status Colors
  static const Color success = Color(0xFF4CAF50);        // Green
  static const Color warning = Color(0xFFFFB74D);        // Soft Orange
  static const Color error = Color(0xFFE57373);          // Soft Red
  static const Color info = Color(0xFF64B5F6);           // Soft Blue

  // Neutral Colors
  static const Color textDark = Color(0xFF424242);       // Dark Gray
  static const Color textMedium = Color(0xFF757575);     // Medium Gray
  static const Color textLight = Color(0xFFBDBDBD);      // Light Gray
  static const Color divider = Color(0xFFEEEEEE);        // Divider
  static const Color background = Color(0xFFFAFAFA);     // Light Background
  static const Color surface = Color(0xFFFFFFFF);        // White

  // Gradient Colors for Cards and Headers
  static const List<Color> primaryGradient = [
    Color(0xFFE91E63),
    Color(0xFFAD1457),
  ];

  static const List<Color> softGradient = [
    Color(0xFFFFE4EC),
    Color(0xFFF3E5F5),
  ];

  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B6B),
    Color(0xFFFFE66D),
  ];

  static const List<Color> oceanGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];

  // Card Gradients for Stories/Vitrins
  static const List<List<Color>> storyGradients = [
    [Color(0xFFE91E63), Color(0xFFAD1457)],
    [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    [Color(0xFFFF4081), Color(0xFFE91E63)],
    [Color(0xFFBA68C8), Color(0xFF9C27B0)],
  ];

  /// Customer Theme Data
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: primary.withAlpha(30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: surface,
      ),
      
      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            color: textMedium,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textMedium, size: 24);
        }),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withAlpha(80),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withAlpha(150)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softPink.withAlpha(100),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: primary,
        suffixIconColor: textMedium,
        hintStyle: TextStyle(color: textMedium.withAlpha(150)),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: softPink,
        selectedColor: primaryLight,
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textMedium,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textMedium,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: textMedium,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
      ),
      
      fontFamily: 'Roboto',
    );
  }
}
