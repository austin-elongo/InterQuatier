import 'package:flutter/material.dart';

class AppTheme {
  static const orange = Color(0xFFFF9800);
  static const deepOrange = Color(0xFFFF5722);

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: orange,
      secondary: deepOrange,
      surface: Colors.grey[900]!,
      surfaceContainerHighest: Colors.grey[850]!,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.grey[850],
      elevation: 2,
    ),
    iconTheme: const IconThemeData(
      color: orange,
    ),
  );
} 