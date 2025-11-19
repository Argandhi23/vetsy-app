import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
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
    },
    {
      'icon': EvaIcons.calendarOutline,
      'title': 'Booking Jadwal',
      'desc': 'Atur jadwal konsultasi atau grooming tanpa perlu antre lama.',
    },
    {
      'icon': EvaIcons.heartOutline,
      'title': 'Sayangi Hewanmu',
      'desc': 'Berikan perawatan terbaik untuk sahabat bulu kesayanganmu.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // TOMBOL LEWATI
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.go(LoginScreen.route),
                child: Text('Lewati', style: TextStyle(color: Colors.grey[600])),
              ),
            ),
            
            // SLIDER KONTEN
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final item = _contents[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Lingkaran Icon Animasi
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'], size: 100, color: primaryColor)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2.seconds),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        
                        const SizedBox(height: 48),
                        
                        Text(
                          item['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          item['desc'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey[500], height: 1.5),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // INDIKATOR & TOMBOL NAVIGASI
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Row(
                    children: List.generate(
                      _contents.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentIndex == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index ? primaryColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Tombol Lanjut/Mulai
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      if (_currentIndex == _contents.length - 1) {
                        context.go(LoginScreen.route);
                      } else {
                        _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
                      }
                    },
                    child: Row(
                      children: [
                        Text(_currentIndex == _contents.length - 1 ? 'Mulai' : 'Lanjut'),
                        const SizedBox(width: 8),
                        const Icon(EvaIcons.arrowForwardOutline, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}