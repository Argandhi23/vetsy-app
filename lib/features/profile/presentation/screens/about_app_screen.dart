import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class AboutAppScreen extends StatelessWidget {
  // Nama rute yang digunakan di go_router
  static const String routeName = 'about-app'; 

  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil warna utama tema untuk konsistensi
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Bagian Logo/Ikon Aplikasi & Nama ---
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.pets, 
                      size: 60,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Vetsy App', 
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Versi 1.0.0', 
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- Bagian Deskripsi Singkat ---
            Text(
              'Deskripsi Aplikasi',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vetsy App adalah platform terpadu yang memfasilitasi pengguna untuk melakukan pemesanan layanan dan konsultasi kesehatan hewan peliharaan dengan mudah ke klinik terdekat.',
              style: GoogleFonts.poppins(fontSize: 14, height: 1.5, color: Colors.black54), textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 30),

            _buildInfoTile(
            title: 'Project Akhir',
            subtitle: 'UAS Basis Data oleh Kelompok 6',
            icon: Icons.group,
          ),
            _buildInfoTile(
              title: 'Hak Cipta',
              subtitle: '© 2025 Vetsy.',
              icon: EvaIcons.awardOutline,
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk menampilkan baris informasi
  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Icon(icon, color: Colors.blueGrey, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: onTap != null
          ? const Icon(EvaIcons.arrowIosForward, size: 18, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}