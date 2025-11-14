// lib/core/config/app_theme.dart
import 'package:flutter/material.dart';

// 1. Definisikan warna "Vetsy Blue" kamu
const Color vetsyBlue = Colors.blueAccent; // Ganti ini jika punya Hex

class AppTheme {
  // 2. Buat tema terang (light theme)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // 3. Tentukan ColorScheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: vetsyBlue,
      brightness: Brightness.light,
    ),
    
    // 4. Atur tema komponen lain
    scaffoldBackgroundColor: Colors.grey[50], // Latar belakang
    
    appBarTheme: AppBarTheme(
      backgroundColor: vetsyBlue, // AppBar jadi biru
      foregroundColor: Colors.white, // Teks & Ikon di AppBar jadi putih
      elevation: 2,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: vetsyBlue, // Tombol jadi biru
        foregroundColor: Colors.white, // Teks tombol jadi putih
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: vetsyBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: vetsyBlue),
    ),
  );

  // (Opsional) Buat juga tema gelap jika perlu
  // static final ThemeData darkTheme = ...
}