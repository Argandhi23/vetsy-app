import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
// Pastikan import OnboardingScreen sudah ada
import 'package:vetsy_app/features/auth/presentation/screens/onboarding_screen.dart'; 
import 'package:vetsy_app/features/home/presentation/screens/home_screen.dart';

class WrapperScreen extends StatefulWidget {
  static const String route = '/';
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  late StreamSubscription _authSubscription;
  bool _timerFinished = false;

  @override
  void initState() {
    super.initState();

    // Timer 3 detik untuk efek Splash Screen
    Future.delayed(const Duration(seconds: 3), () {
      _timerFinished = true;
      if (mounted) {
        _navigate(context.read<AuthCubit>().state);
      }
    });

    // Mendengarkan perubahan status Auth
    _authSubscription = context.read<AuthCubit>().stream.skip(1).listen((state) {
      if (mounted) {
        _navigate(state);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  void _navigate(AuthState state) {
    // Hanya navigasi jika timer 3 detik sudah selesai
    if (_timerFinished) {
      if (state is Authenticated) {
        context.go(HomeScreen.route);
      } else if (state is Unauthenticated) {
        // LOGIC BARU: Arahkan ke Onboarding dulu, bukan langsung Login
        context.go(OnboardingScreen.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. Background Gradient Premium
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Color.alphaBlend(Colors.white.withOpacity(0.2), Theme.of(context).primaryColor),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 2. Konten Tengah (Logo & Judul)
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Lottie (Dibatasi ukurannya agar aman di Web)
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 280,
                        maxHeight: 280,
                      ),
                      child: Lottie.asset(
                        'assets/lottie/logo_splash.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    // Judul Aplikasi dengan Font Keren
                    Text(
                      'Vetsy',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2.0,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),

                    const SizedBox(height: 8),

                    // Tagline (Pengganti Loading Spinner)
                    Text(
                      'Your Pet\'s Best Friend',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
                  ],
                ),
              ),
            ),

            // 3. Footer Version Number
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ).animate().fadeIn(delay: 1000.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}