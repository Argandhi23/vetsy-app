// lib/features/auth/presentation/screens/wrapper_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart'; // Kita masih pakai .w
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
    
    Future.delayed(const Duration(seconds: 3), () {
      _timerFinished = true;
      _navigate(context.read<AuthCubit>().state);
    });

    _authSubscription = context.read<AuthCubit>().stream.skip(1).listen((state) {
      _navigate(state);
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
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/logo_splash.json',
              width: 80.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'Vetsy',
              style: TextStyle(
                // Ganti .sp menjadi statis
                fontSize: 48, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}