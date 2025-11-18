// lib/core/config/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/presentation/screens/login_screen.dart';
import 'package:vetsy_app/features/auth/presentation/screens/register_screen.dart';
import 'package:vetsy_app/features/auth/presentation/screens/wrapper_screen.dart';
import 'package:vetsy_app/features/home/presentation/screens/home_screen.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

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
      GoRoute(
        path: HomeScreen.route, // Rute: '/home'
        builder: (context, state) => HomeScreen(),
        routes: [
          // SUB-RUTE DETAIL
          GoRoute(
            name: ClinicDetailScreen.routeName, // '/home/:clinicId'
            path: ':clinicId',
            builder: (context, state) {
              final clinicId = state.pathParameters['clinicId']!;
              return ClinicDetailScreen(clinicId: clinicId);
            },
            // SUB-RUTE BOOKING (DI DALAM DETAIL)
            routes: [
              GoRoute(
                name: BookingScreen.routeName, // '/home/:clinicId/book'
                path: BookingScreen.routePath, // 'book'
                builder: (context, state) {
                  final Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  final String clinicId = data['clinicId'];
                  final String clinicName = data['clinicName'];
                   final ServiceEntity service = data['service'];

                  return BookingScreen(
                    clinicId: clinicId,
                    clinicName: clinicName,
                    service: service,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],

    // ===== PERBAIKI LOGIKA REDIRECT =====
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      final isAtWrapper = state.matchedLocation == WrapperScreen.route;
      
      // JIKA KITA SUDAH DI WRAPPER, JANGAN LAKUKAN APA-APA.
      // Biarkan WrapperScreen yang mengatur navigasinya sendiri.
      if (isAtWrapper) {
        return null;
      }

      final isGoingToAuth = state.matchedLocation.startsWith(LoginScreen.route) ||
                            state.matchedLocation.startsWith(RegisterScreen.route);

      // KASUS 1: USER SUDAH LOGIN
      if (authState is Authenticated) {
        // Jika user login & mencoba ke halaman auth, lempar ke home
        if (isGoingToAuth) return HomeScreen.route;
      }

      // KASUS 2: USER BELUM LOGIN
      if (authState is Unauthenticated) {
        // Jika user belum login & mencoba ke area terproteksi (bukan auth)
        if (!isGoingToAuth) return LoginScreen.route;
      }

      // (AuthInitial akan otomatis jatuh ke null, yang berarti "tetap di tempat")
      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}