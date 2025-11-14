// lib/core/config/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/screens/home_screen.dart';
import 'package:vetsy_app/features/auth/screens/login_screen.dart';
import 'package:vetsy_app/features/auth/screens/register_screen.dart';
import 'package:vetsy_app/features/auth/screens/wrapper_screen.dart';

// ===== IMPORT DENGAN PATH YANG BENAR =====

import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';
// ==========================================

class AppRouter {
  final AuthCubit authCubit;
  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    initialLocation: WrapperScreen.route,
    routes: [
      GoRoute(
        path: WrapperScreen.route, // Rute: '/'
        builder: (context, state) => const WrapperScreen(),
      ),
      GoRoute(
        path: LoginScreen.route, // Rute: '/login'
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.route, // Rute: '/register'
        builder: (context, state) => const RegisterScreen(),
      ),
      // MODIFIKASI RUTE HOME
      GoRoute(
        path: HomeScreen.route, // Rute: '/home'
        builder: (context, state) => const HomeScreen(),
        // TAMBAHKAN SUB-RUTE (CHILD ROUTE)
        routes: [
          GoRoute(
            name: ClinicDetailScreen.routeName, // <-- Beri nama
            path: ':clinicId', // <-- :clinicId adalah parameter
            builder: (context, state) {
              // Ambil parameter clinicId dari URL
              final clinicId = state.pathParameters['clinicId']!;
              return ClinicDetailScreen(clinicId: clinicId);
            },
          ),
        ],
      ),
    ],

    // LOGIKA REDIRECT OTOMATIS (Sudah benar)
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;

      final isAtWrapper = state.matchedLocation == WrapperScreen.route;
      final isLoggingIn = state.matchedLocation == LoginScreen.route ||
          state.matchedLocation == RegisterScreen.route;

      // KASUS 1: USER SUDAH LOGIN
      if (authState is Authenticated) {
        if (isAtWrapper || isLoggingIn) return HomeScreen.route;
      }

      // KASUS 2: USER BELUM LOGIN
      if (authState is Unauthenticated) {
        if (isAtWrapper) return LoginScreen.route;
        
        // Cek path utama, bukan sub-rute
        final isGoingToAuth = state.matchedLocation.startsWith(LoginScreen.route) ||
                              state.matchedLocation.startsWith(RegisterScreen.route);

        // Jika user belum login DAN mencoba akses halaman selain auth
        if (!isGoingToAuth) return LoginScreen.route;
      }

      return null;
    },
  );
}

// ... (GoRouterRefreshStream tetap sama) ...
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}