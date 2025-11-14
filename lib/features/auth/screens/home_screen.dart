// lib/features/home/presentation/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';

// 1. IMPORT SEMUA "PIPA" DATA KLINIK
import 'package:vetsy_app/features/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:vetsy_app/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinics_usecase.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/widgets/clinic_list_widget.dart';

class HomeScreen extends StatelessWidget {
  static const String route = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data user dari AuthCubit global
    final user = (context.watch<AuthCubit>().state as Authenticated).user;

    // 2. SEDIAKAN CLINIC CUBIT
    // Kita bungkus Scaffold dengan BlocProvider
    return BlocProvider(
      create: (context) {
        // 3. LAKUKAN DEPENDENCY INJECTION (MANUAL)
        // Ini adalah cara kita menyambungkan semua pipa
        final ClinicRemoteDataSource remoteDataSource =
            ClinicRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
        final ClinicRepositoryImpl repository =
            ClinicRepositoryImpl(remoteDataSource: remoteDataSource);
        final GetClinicsUseCase useCase =
            GetClinicsUseCase(repository: repository);
        
        // 4. BUAT CUBIT DAN LANGSUNG PANGGIL FUNGSINYA
        return ClinicCubit(getClinicsUseCase: useCase)..fetchClinics();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vetsy Home'),
          actions: [
            // Tombol Logout
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
            )
          ],
        ),
        // 5. GANTI BODY-NYA DENGAN WIDGET DAFTAR KLINIK
        body: const ClinicListWidget(),
      ),
    );
  }
}