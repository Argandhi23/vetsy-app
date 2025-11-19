import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/screens/edit_profile_screen.dart'; // Import Halaman Edit
import 'package:vetsy_app/data_seeder.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading ||
              state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.status == ProfileStatus.loaded && state.user != null) {
            final user = state.user!;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  // HEADER GRADIENT & AVATAR
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withBlue(200),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person, 
                              size: 50,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut), 
                    ],
                  ),

                  const SizedBox(height: 60), 

                  // USER INFO
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.5),
                  
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.5),

                  const SizedBox(height: 30),

                  // MENU OPTIONS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.editOutline, // Icon Edit
                          title: 'Edit Profil',
                          onTap: () {
                            // Navigasi ke Edit Profile
                            context.goNamed(EditProfileScreen.routeName);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.questionMarkCircleOutline,
                          title: 'Bantuan & Dukungan',
                          onTap: () {},
                        ),
                        const SizedBox(height: 16),
                        
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.cloudUploadOutline,
                          title: 'Isi Data Klinik (Dev Only)',
                          onTap: () async {
                            await seedData();
                            if(context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Data klinik berhasil ditambahkan!')),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildMenuTile(
                          context,
                          icon: EvaIcons.logOutOutline,
                          title: 'Keluar Aplikasi',
                          isDanger: true,
                          onTap: () {
                            context.read<AuthCubit>().signOut();
                          },
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('Error memuat profil'));
        },
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isDanger = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDanger ? Colors.red.withOpacity(0.1) : Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDanger ? Colors.red : Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDanger ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(EvaIcons.arrowIosForward, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}