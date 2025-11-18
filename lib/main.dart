// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/core/config/app_router.dart';
import 'package:vetsy_app/core/config/app_theme.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart'; // <-- IMPORT BARU
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator(); 
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final StreamSubscription _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = sl<AuthCubit>().stream.listen((authState) {
      if (authState is Authenticated) {
        // Jika user BARU login, panggil fetch
        sl<MyPetsCubit>().fetchMyPets();
        sl<MyBookingsCubit>().fetchMyBookings();
        sl<ProfileCubit>().fetchUserProfile(); // <-- TAMBAHKAN INI
      } else if (authState is Unauthenticated) {
        // Jika user Logout, RESET data
        sl<MyPetsCubit>().reset();
        sl<MyBookingsCubit>().reset();
        sl<ProfileCubit>().reset(); // <-- TAMBAHKAN INI
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocProvider(
          create: (context) => sl<AuthCubit>(),
          child: MaterialApp.router(
            title: 'Vetsy App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme, 
            routerConfig: AppRouter(authCubit: sl<AuthCubit>()).router,
          ),
        );
      },
    );
  }
}