import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Dark theme shadows (deep, bluish glow)
List<BoxShadow> darkShadows = [
  BoxShadow(
    color: const Color(0xFF7C4DFF).withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];
// Grey theme shadows (soft neutral)
List<BoxShadow> greyShadows = [
  const BoxShadow(
    color: Colors.black38,
    blurRadius: 16,
    offset: Offset(0, 4),
  ),
];

// Sky theme shadows (cool blue shadow)
List<BoxShadow> skyShadows = [
  BoxShadow(
    color: const Color(0xFF64B5F6).withOpacity(0.3),
    blurRadius: 16,
    offset: const Offset(0, 4),
  ),
];

// Vulkan theme shadows (red glow)
List<BoxShadow> vulkanShadows = [
  BoxShadow(
    color: const Color(0xFFFF3333).withOpacity(0.3),
    blurRadius: 20,
    offset: const Offset(0, 6),
  ),
];

class AppTheme {
  // static const double _blurRadius = 10.0;
  static const double _opacity = 0.7;

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF0A0A0A),
      scaffoldBackgroundColor: const Color(0xFF050505),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7C4DFF),
        secondary: Color(0xFF00E5FF),
        tertiary: Color(0xFFF052C0),
        inversePrimary: Color(0xFFFCCCED),
        surface: Color(0xFF121212),
        error: Color(0xFFFF5252),
        background: Color(0xFF050505),
        onBackground: Color(0xFFE1E1E1),
        onSurface: Color(0xFFE1E1E1),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF121212).withOpacity(_opacity),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0A),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF121212).withOpacity(_opacity),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1D1D1D).withOpacity(_opacity),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1D1D1D).withOpacity(_opacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7C4DFF).withOpacity(_opacity),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFE1E1E1)),
        displayMedium: TextStyle(color: Color(0xFFE1E1E1)),
        displaySmall: TextStyle(color: Color(0xFFE1E1E1)),
        headlineMedium: TextStyle(color: Color(0xFFE1E1E1)),
        headlineSmall: TextStyle(color: Color(0xFFE1E1E1)),
        titleLarge: TextStyle(color: Color(0xFFE1E1E1)),
        bodyLarge: TextStyle(color: Color(0xFFE1E1E1)),
        bodyMedium: TextStyle(color: Color(0xFFE1E1E1)),
      ),
    );
  }

  // Glass effect widget
  static Widget glassContainer({
    required Widget child,
    double borderRadius = 16.0,
    Color color = Colors.white,
    double opacity = 0.2,
    double blur = 10.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  // Grey Theme
  static ThemeData greyTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF29363B),
      scaffoldBackgroundColor: const Color(0xFFD6D6D6),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF29363B),
        secondary: Color(0xFF6BFC9B),
        tertiary: Color(0xF8FFF12D),
        inversePrimary: Color(0xFF0B8ECF),
        surface: Color(0xFFE0E0E0),
        error: Color(0xFFB71C1C),
        background: Color(0xFFF5F5F5),
        onBackground: Color(0xFF082A3B),
        onSurface: Color(0xFF171B1D),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFE0E0E0).withOpacity(_opacity),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF455A64),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFE0E0E0).withOpacity(_opacity),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF90A4AE).withOpacity(_opacity),
        contentTextStyle: const TextStyle(color: Color(0xFF263238)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0E0E0).withOpacity(_opacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF455A64), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF455A64).withOpacity(_opacity),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF263238)),
        displayMedium: TextStyle(color: Color(0xFF263238)),
        displaySmall: TextStyle(color: Color(0xFF263238)),
        headlineMedium: TextStyle(color: Color(0xFF263238)),
        headlineSmall: TextStyle(color: Color(0xFF263238)),
        titleLarge: TextStyle(color: Color(0xFF263238)),
        bodyLarge: TextStyle(color: Color(0xFF263238)),
        bodyMedium: TextStyle(color: Color(0xFF263238)),
      ),
    );
  }

  // Sky Theme (Blue/White)
  static ThemeData skyTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF1E88E5),
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E88E5),
        secondary: Color.fromARGB(255, 250, 145, 76),
        surface: Color(0xFFBBDEFB),
        error: Color(0xFFD32F2F),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFFBBDEFB).withOpacity(_opacity),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFBBDEFB).withOpacity(_opacity),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF90CAF9).withOpacity(_opacity),
        contentTextStyle: const TextStyle(color: Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFBBDEFB).withOpacity(_opacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5).withOpacity(_opacity),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87),
        displayMedium: TextStyle(color: Colors.black87),
        displaySmall: TextStyle(color: Colors.black87),
        headlineMedium: TextStyle(color: Colors.black87),
        headlineSmall: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
      ),
    );
  }

  // Vulkan Theme (Red/Black)
  static ThemeData vulkanTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF8B0000),
      scaffoldBackgroundColor: const Color(0xFF1A0000),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF3333),
        secondary: Color(0xFFFF8080),
        surface: Color(0xFF2A0000),
        error: Color(0xFFFF5252),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2A0000).withOpacity(_opacity),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF8B0000),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF2A0000).withOpacity(_opacity),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF3A0000).withOpacity(_opacity),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A0000).withOpacity(_opacity),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF3333), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3333).withOpacity(_opacity),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white),
        displayMedium: TextStyle(color: Colors.white),
        displaySmall: TextStyle(color: Colors.white),
        headlineMedium: TextStyle(color: Colors.white),
        headlineSmall: TextStyle(color: Colors.white),
        titleLarge: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}

// Extension to easily apply glass effect to widgets
extension GlassEffect on Widget {
  Widget applyGlass({
    double borderRadius = 16.0,
    Color color = Colors.white,
    double opacity = 0.2,
    double blur = 10.0,
  }) {
    return AppTheme.glassContainer(
      child: this,
      borderRadius: borderRadius,
      color: color,
      opacity: opacity,
      blur: blur,
    );
  }
}
