// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart';
// Hapus import data_seeder jika masih ada

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileCubit>(), // fetch dipanggil dari main.dart
      child: Scaffold(
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading || 
                state.status == ProfileStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ProfileStatus.error) {
              return Center(child: Text(state.errorMessage ?? 'Error'));
            }
            if (state.status == ProfileStatus.loaded && state.user != null) {
              final user = state.user!;
              return ListView(
                padding: EdgeInsets.all(4.w),
                children: [
                  CircleAvatar(
                    radius: 12.w,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person,
                        size: 15.w, color: Theme.of(context).primaryColor),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    user.username,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // Ganti .sp menjadi statis
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // Ganti .sp menjadi statis
                        fontSize: 16,
                        color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      context.read<AuthCubit>().signOut();
                    },
                  ),
                  const Divider(),
                ],
              );
            }
            return const Center(child: Text('Memuat profil...'));
          },
        ),
      ),
    );
  }
}