// lib/features/home/presentation/screens/clinic_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vetsy_app/core/config/locator.dart'; // <-- 1. IMPORT 'sl'
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/widgets/clinic_list_widget.dart';

// HAPUS SEMUA IMPORT data, repositories, usecases

class ClinicListScreen extends StatelessWidget {
  const ClinicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ClinicCubit>()..fetchClinics(), // <-- 2. BERSIHKAN
      child: const ClinicListWidget(),
    );
  }
}