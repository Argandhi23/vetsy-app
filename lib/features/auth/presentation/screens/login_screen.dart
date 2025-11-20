import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/presentation/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIC LUPA PASSWORD (DIPERBAIKI & DIPERCANTIK) ---
  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(EvaIcons.emailOutline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text("Reset Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset passwordmu.",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "contoh@email.com",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(EvaIcons.email),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi email")));
                 return;
              }
              
              Navigator.pop(ctx); // Tutup dialog dulu
              
              try {
                // Panggil fungsi di Cubit
                await context.read<AuthCubit>().resetPassword(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Link reset terkirim! Cek email Anda."), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Kirim Link"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveConstraintBox(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
              );
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: -100, right: -100,
                child: Container(width: 300, height: 300, decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle)).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]), child: Icon(Icons.pets, size: 50, color: primaryColor)).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                      const SizedBox(height: 40),
                      Text('Selamat Datang!', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 8),
                      Text('Masuk untuk mengelola kesehatan hewanmu', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                      const SizedBox(height: 48),
                      
                      _buildTextField(controller: _emailController, label: 'Email', icon: EvaIcons.emailOutline, inputType: TextInputType.emailAddress).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _passwordController, label: 'Password', icon: EvaIcons.lockOutline, obscureText: _isObscure, isPassword: true, onToggleVisibility: () => setState(() => _isObscure = !_isObscure)).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      
                      // TOMBOL LUPA PASSWORD YANG SUDAH DIPERBAIKI
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: Text('Lupa Password?', style: GoogleFonts.poppins(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600)),
                        ),
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shadowColor: primaryColor.withOpacity(0.4), elevation: 8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              onPressed: (state is AuthLoading) ? null : () { context.read<AuthCubit>().signInWithEmail(email: _emailController.text, password: _passwordController.text); },
                              child: (state is AuthLoading) ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Masuk', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun? ', style: GoogleFonts.poppins(color: Colors.grey[600])),
                          GestureDetector(onTap: () { context.go(RegisterScreen.route); }, child: Text('Daftar Sekarang', style: GoogleFonts.poppins(color: primaryColor, fontWeight: FontWeight.bold))),
                        ],
                      ).animate().fadeIn(delay: 700.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false, bool isPassword = false, TextInputType inputType = TextInputType.text, VoidCallback? onToggleVisibility}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, 5))]),
      child: TextFormField(
        controller: controller, obscureText: obscureText, keyboardType: inputType, style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label, labelStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.6)),
          suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? EvaIcons.eyeOffOutline : EvaIcons.eyeOutline, color: Colors.grey), onPressed: onToggleVisibility) : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}