// lib/core/config/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- 1. IMPORT FONT BARU

class AppTheme {
  static final Color _primaryColor = Colors.blue[800]!;

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: _primaryColor,
      
      // 2. GANTI FONT GLOBAL (textTheme)
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ),

      // 3. (OPSIONAL) Rombak styling tombol agar lebih modern
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Lebih bulat
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // 4. (OPSIONAL) Rombak styling AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        // Terapkan font Poppins ke judul AppBar juga
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),

      // 5. (OPSIONAL) Rombak styling BottomNavBar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        // Terapkan font Poppins ke label nav bar
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(),
      ),

    );
  }
}