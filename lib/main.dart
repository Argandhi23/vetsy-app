import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vetsy_app/core/config/app_router.dart';
import 'package:vetsy_app/core/config/app_theme.dart';
import 'package:vetsy_app/core/config/locator.dart';
// Import Cubit
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupLocator();
  await initializeDateFormatting('id_ID', null);

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
    // LOGIC FIX: Reset data saat logout, Fetch data saat login
    _authSubscription = sl<AuthCubit>().stream.listen((authState) {
      if (authState is Authenticated) {
        sl<MyPetsCubit>().fetchMyPets();
        sl<MyBookingsCubit>().fetchMyBookings();
        sl<ProfileCubit>().fetchUserProfile();
        sl<ClinicCubit>().fetchClinics();
      } else if (authState is Unauthenticated) {
        sl<MyPetsCubit>().reset();
        sl<MyBookingsCubit>().reset();
        sl<ProfileCubit>().reset();
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
        // LOGIC FIX: MultiBlocProvider di root
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => sl<AuthCubit>()),
            BlocProvider(create: (context) => sl<MyPetsCubit>()),
            BlocProvider(create: (context) => sl<MyBookingsCubit>()),
            BlocProvider(create: (context) => sl<ProfileCubit>()),
            BlocProvider(create: (context) => sl<ClinicCubit>()),
          ],
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