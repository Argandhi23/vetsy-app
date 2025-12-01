import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:vetsy_app/features/profile/presentation/screens/about_app_screen.dart';
import 'package:vetsy_app/features/profile/presentation/screens/change_password_screen.dart'; 
// Import data_seeder dihapus agar bersih
import 'package:vetsy_app/features/profile/presentation/widgets/profile_stats_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading || state.status == ProfileStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state.status == ProfileStatus.loaded && state.user != null) {
            final user = state.user!;
            
            return SingleChildScrollView(
              child: Column(
                children: [
                  // --- 1. HEADER ---
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Background Gradient
                      Container(
                        height: 240,
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
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                      ),
                      // Judul Header
                      Positioned(
                        top: 60,
                        child: Text(
                          "Profil Saya", 
                          style: GoogleFonts.poppins(
                            color: Colors.white, 
                            fontSize: 20, 
                            fontWeight: FontWeight.bold
                          )
                        ),
                      ),
                      // Avatar
                      Positioned(
                        bottom: -50,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white, 
                            shape: BoxShape.circle, 
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                          ),
                        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut), 
                      ),
                    ],
                  ),

                  const SizedBox(height: 60), 

                  // --- 2. INFO USER ---
                  Text(
                    user.username, 
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                  Text(
                    user.email, 
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])
                  ),

                  const SizedBox(height: 24),

                  // --- 3. STATISTIK DASHBOARD ---
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ProfileStatsCard(), 
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 24),

                  // --- 4. MENU LIST ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.editOutline, 
                          title: 'Edit Profil',
                          color: Colors.blue,
                          onTap: () => context.goNamed(EditProfileScreen.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.shieldOutline,
                          title: 'Ganti Password',
                          color: Colors.green,
                          onTap: () => context.goNamed(ChangePasswordScreen.routeName),
                        ),
                        const SizedBox(height: 16),

                         _buildMenuTile(
                          context,
                          icon: EvaIcons.infoOutline,
                          title: 'Tentang Aplikasi', 
                          color: Colors.purple,
                          onTap: () => context.goNamed(AboutAppScreen.routeName),
                        ),
                        
                        // Menu Data Seeder / Fixer SUDAH DIHAPUS agar bersih
                        
                        const SizedBox(height: 16),
                        _buildMenuTile(
                          context,
                          icon: EvaIcons.logOutOutline,
                          title: 'Keluar Aplikasi',
                          color: Colors.red,
                          isDanger: true,
                          onTap: () => context.read<AuthCubit>().signOut(),
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
      required Color color,
      required VoidCallback onTap,
      bool isDanger = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 15, 
            color: isDanger ? Colors.red : Colors.black87
          ),
        ),
        trailing: const Icon(EvaIcons.arrowIosForward, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}