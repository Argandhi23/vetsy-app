import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data konten onboarding
  final List<Map<String, dynamic>> _contents = [
    {
      'icon': EvaIcons.searchOutline,
      'title': 'Temukan Klinik Terdekat',
      'desc': 'Cari dokter hewan terbaik di sekitarmu dengan mudah dan cepat.',
      'color': Colors.blue,
    },
    {
      'icon': EvaIcons.calendarOutline,
      'title': 'Booking Jadwal',
      'desc': 'Atur jadwal konsultasi atau grooming tanpa perlu antre lama.',
      'color': Colors.orange,
    },
    {
      'icon': EvaIcons.heartOutline,
      'title': 'Sayangi Hewanmu',
      'desc': 'Berikan perawatan terbaik untuk sahabat bulu kesayanganmu.',
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND DECORATION (Elemen Pemanis)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _contents[_currentIndex]['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ).animate(target: _currentIndex.toDouble()).scale(duration: 500.ms),
          ),
          Positioned(
            top: size.height * 0.2,
            left: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // 2. TOMBOL LEWATI (SKIP)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () => context.go(LoginScreen.route),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: Text(
                'Lewati',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // 3. KONTEN UTAMA (PAGEVIEW)
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              final item = _contents[index];
              // KITA GUNAKAN KEY UNTUK MEMICU RESTART ANIMASI SAAT SLIDE BERUBAH
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // --- GAMBAR / IKON ---
                    Container(
                      padding: const EdgeInsets.all(50),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item['color'].withOpacity(0.2),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Icon(
                        item['icon'], 
                        size: 100, 
                        color: item['color']
                      )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.95, end: 1.05, duration: 2.seconds) // Efek Bernapas
                      .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5)), // Efek Kilau
                    )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.easeOutBack), // Efek Muncul Pop

                    const SizedBox(height: 60),

                    // --- TEXT TITLE ---
                    // Key unik per index agar animasi restart tiap slide
                    Text(
                      item['title'],
                      key: ValueKey('title_$index'), 
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),

                    const SizedBox(height: 16),

                    // --- TEXT DESCRIPTION ---
                    Text(
                      item['desc'],
                      key: ValueKey('desc_$index'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutQuad),

                    const Spacer(),
                  ],
                ),
              );
            },
          ),

          // 4. BAGIAN BAWAH (Indikator & Tombol)
          Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots Indicator yang lebih halus
                Row(
                  children: List.generate(
                    _contents.length,
                    (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        // Kalau aktif, lebar 24 (lonjong). Kalau tidak, lebar 8 (bulat)
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? _contents[index]['color'] 
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                ),

                // Tombol Next / Mulai dengan Animasi Warna
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _contents[_currentIndex]['color'], // Warna berubah sesuai slide
                    boxShadow: [
                      BoxShadow(
                        color: _contents[_currentIndex]['color'].withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      if (_currentIndex == _contents.length - 1) {
                        context.go(LoginScreen.route);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic, // Kurva animasi slide lebih smooth
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          _currentIndex == _contents.length - 1 ? 'Mulai' : 'Lanjut',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Icon(EvaIcons.arrowForwardOutline, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}