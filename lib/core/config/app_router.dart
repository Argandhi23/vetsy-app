import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/presentation/screens/login_screen.dart';
import 'package:vetsy_app/features/auth/presentation/screens/register_screen.dart';
import 'package:vetsy_app/features/auth/presentation/screens/wrapper_screen.dart';
import 'package:vetsy_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:vetsy_app/features/home/presentation/screens/home_screen.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';

class AppRouter {
  final AuthCubit authCubit;
  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    initialLocation: WrapperScreen.route,
    routes: [
      // --- ROOT / WRAPPER ---
      GoRoute(
        path: WrapperScreen.route,
        builder: (context, state) => const WrapperScreen(),
      ),
      
      // --- AUTHENTICATION ---
      GoRoute(
        path: OnboardingScreen.route,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: LoginScreen.route,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RegisterScreen.route,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // --- MAIN APP ---
      GoRoute(
        path: HomeScreen.route,
        builder: (context, state) => HomeScreen(),
        routes: [
          // SUB-RUTE: EDIT PROFILE
          GoRoute(
            name: EditProfileScreen.routeName,
            path: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          
          // SUB-RUTE: BOOKING DETAIL (TIKET)
          GoRoute(
            name: BookingDetailScreen.routeName,
            path: 'booking-detail',
            builder: (context, state) {
              final booking = state.extra as BookingEntity;
              return BookingDetailScreen(booking: booking);
            },
          ),
          
          // SUB-RUTE: CLINIC DETAIL
          GoRoute(
            name: ClinicDetailScreen.routeName,
            path: ':clinicId',
            builder: (context, state) {
              final clinicId = state.pathParameters['clinicId']!;
              return ClinicDetailScreen(clinicId: clinicId);
            },
            routes: [
              // SUB-RUTE: FORM BOOKING (Di dalam Detail Klinik)
              GoRoute(
                name: BookingScreen.routeName,
                path: BookingScreen.routePath,
                builder: (context, state) {
                  final Map<String, dynamic> data =
                      state.extra as Map<String, dynamic>;
                  return BookingScreen(
                    clinicId: data['clinicId'],
                    clinicName: data['clinicName'],
                    service: data['service'] as ServiceEntity,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    
    // --- LOGIKA REDIRECT (PROTEKSI HALAMAN) ---
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      
      // Cek lokasi saat ini
      final isAtWrapper = state.matchedLocation == WrapperScreen.route;
      final isAtOnboarding = state.matchedLocation == OnboardingScreen.route;
      
      // Jika sedang di Wrapper, biarkan logic Wrapper bekerja sendiri
      if (isAtWrapper) return null;

      // Cek apakah user sedang menuju halaman Auth (Login/Register/Onboarding)
      final isGoingToAuth = state.matchedLocation.startsWith(LoginScreen.route) ||
                            state.matchedLocation.startsWith(RegisterScreen.route) ||
                            isAtOnboarding;

      // SKENARIO 1: User SUDAH Login
      if (authState is Authenticated) {
        // Jika user mencoba akses halaman Auth, lempar ke Home
        if (isGoingToAuth) return HomeScreen.route;
      }

      // SKENARIO 2: User BELUM Login
      if (authState is Unauthenticated) {
        // Jika user mencoba akses halaman selain Auth (misal Home), lempar ke Login
        if (!isGoingToAuth) return LoginScreen.route;
      }

      // Default: tidak ada redirect
      return null;
    },
  );
}

// Helper agar GoRouter bisa mendengarkan Stream dari Bloc
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}