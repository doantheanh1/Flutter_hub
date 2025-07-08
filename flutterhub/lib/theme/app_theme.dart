import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF7C4DFF), // tím nhạt
      onPrimary: Colors.white,
      secondary: Color(0xFF42A5F5), // xanh dương nhạt
      onSecondary: Colors.white,
      background: Color(0xFFF5F6FA), // nền rất nhạt
      onBackground: Color(0xFF222222), // text đen đậm
      surface: Colors.white, // card trắng
      onSurface: Color(0xFF333333), // text xám đậm
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFFF5F6FA),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF7C4DFF),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF7C4DFF)),
      titleTextStyle: TextStyle(
        color: Color(0xFF222222),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFF7C4DFF)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF7C4DFF),
        side: const BorderSide(color: Color(0xFF7C4DFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(Color(0xFF7C4DFF)),
      trackColor: MaterialStateProperty.all(Color(0xFF7C4DFF).withOpacity(0.3)),
    ),
    cardColor: Colors.white,
    dividerColor: Color(0xFFE0E0E0),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF667eea),
      secondary: const Color(0xFF764ba2),
      background: const Color(0xFF0A0A0A),
      surface: const Color(0xFF1A1A2E),
    ),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A1A2E)),
    useMaterial3: true,
  );
}
