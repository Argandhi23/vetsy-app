// lib/features/auth/presentation/screens/wrapper_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import Animasi
import 'package:google_fonts/google_fonts.dart'; // Import Font (jika pakai GoogleFonts)
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/presentation/screens/login_screen.dart';
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

    // Timer 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      _timerFinished = true;
      if (mounted) {
        _navigate(context.read<AuthCubit>().state);
      }
    });

    // Listener Auth State
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
    if (_timerFinished && (state is Authenticated || state is Unauthenticated)) {
      if (state is Authenticated) {
        context.go(HomeScreen.route);
      } else {
        context.go(LoginScreen.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 1. BACKGROUND GRADIENT MODERN
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              // Warna kedua sedikit lebih terang/biru muda
              Color.alphaBlend(Colors.white.withOpacity(0.2), Theme.of(context).primaryColor),
            ],
          ),
        ),
        child: Stack(
          children: [
            // BAGIAN TENGAH (LOGO & TEKS)
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2. LOGO ANIMASI (Constrained agar aman di Web)
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

                    // 3. JUDUL UTAMA
                    Text(
                      'Vetsy',
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.w900, // Lebih tebal
                        color: Colors.white,
                        letterSpacing: 2.0, // Jarak antar huruf
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

                    // 4. TAGLINE (PENGGANTI LOADING)
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

            // 5. FOOTER VERSION (BIAR TERLIHAT PRO)
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