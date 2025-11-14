// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/core/config/app_router.dart';
import 'package:vetsy_app/core/config/app_theme.dart'; // <-- 1. IMPORT TEMA
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'firebase_options.dart';

// ... (main() tetap sama) ...
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

// ... (StatefulWidget & initState() tetap sama) ...
class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthCubit _authCubit;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit();
    _appRouter = AppRouter(authCubit: _authCubit);
  }
  // ... (dispose() tetap sama) ...
  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return BlocProvider.value(
          value: _authCubit,
          child: MaterialApp.router(
            title: 'Vetsy App',
            
            // 2. GUNAKAN TEMA BARU KITA
            theme: AppTheme.lightTheme, 
            
            routerConfig: _appRouter.router,
          ),
        );
      },
    );
  }
}