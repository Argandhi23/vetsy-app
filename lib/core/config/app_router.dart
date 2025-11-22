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
import 'package:vetsy_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:vetsy_app/features/profile/presentation/screens/about_app_screen.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_detail_screen.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/admin/presentation/screens/admin_dashboard_screen.dart';
// [PENTING] Import halaman baru
import 'package:vetsy_app/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart'; // Import PetEntity

class AppRouter {
  final AuthCubit authCubit;
  AppRouter({required this.authCubit});

  late final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    initialLocation: WrapperScreen.route,
    routes: [
      GoRoute(
        path: WrapperScreen.route,
        builder: (context, state) => const WrapperScreen(),
      ),
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
      GoRoute(
        path: AdminDashboardScreen.route,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: HomeScreen.route,
        builder: (context, state) => HomeScreen(),
        routes: [
          GoRoute(
            name: EditProfileScreen.routeName,
            path: 'edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            name: ChangePasswordScreen.routeName,
            path: 'change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            name: AboutAppScreen.routeName,
            path: 'about-app',
            builder: (context, state) => const AboutAppScreen(),
          ),
          GoRoute(
            name: BookingDetailScreen.routeName,
            path: 'booking-detail',
            builder: (context, state) {
              final booking = state.extra as BookingEntity;
              return BookingDetailScreen(booking: booking);
            },
          ),
          // --- [RUTE BARU: CHECKOUT / KONFIRMASI] ---
          GoRoute(
            name: BookingConfirmationScreen.routeName,
            path: 'booking-confirmation',
            builder: (context, state) {
              // Ambil data yang dikirim dari BookingScreen
              final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
              return BookingConfirmationScreen(
                clinicId: args['clinicId'],
                clinicName: args['clinicName'],
                service: args['service'] as ServiceEntity,
                pet: args['pet'] as PetEntity,
                date: args['date'] as DateTime,
                time: args['time'] as TimeOfDay,
              );
            },
          ),
          // ------------------------------------------
          GoRoute(
            name: ClinicDetailScreen.routeName,
            path: ':clinicId',
            builder: (context, state) {
              final clinicId = state.pathParameters['clinicId']!;
              return ClinicDetailScreen(clinicId: clinicId);
            },
            routes: [
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
    
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authCubit.state;
      
      final isAtWrapper = state.matchedLocation == WrapperScreen.route;
      final isAtOnboarding = state.matchedLocation == OnboardingScreen.route;
      
      if (isAtWrapper) return null;

      final isGoingToAuth = state.matchedLocation.startsWith(LoginScreen.route) ||
                            state.matchedLocation.startsWith(RegisterScreen.route) ||
                            isAtOnboarding;

      if (authState is Authenticated) {
        if (authState.role == 'admin') {
          return AdminDashboardScreen.route;
        } else {
          if (isGoingToAuth || state.matchedLocation.startsWith(AdminDashboardScreen.route)) {
            return HomeScreen.route;
          }
        }
      }

      if (authState is Unauthenticated) {
        if (!isGoingToAuth) return LoginScreen.route;
      }

      return null;
    },
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}