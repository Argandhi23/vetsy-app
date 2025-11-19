import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/auth/presentation/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String route = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isObscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar transparan agar menyatu dengan desain
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
            ],
          ),
          child: IconButton(
            icon: const Icon(EvaIcons.arrowBack, color: Colors.black),
            onPressed: () => context.go(LoginScreen.route),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: ResponsiveConstraintBox(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // DEKORASI BACKGROUND (Beda posisi dari login biar variatif)
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ).animate().scale(duration: 800.ms),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          'Buat Akun Baru',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ).animate().fadeIn().slideY(begin: 0.3),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Mulai perjalanan sehat hewanmu bersama Vetsy',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                        
                        const SizedBox(height: 40),

                        // FIELD USERNAME
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          icon: EvaIcons.personOutline,
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                        
                        const SizedBox(height: 20),

                        // FIELD EMAIL
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: EvaIcons.emailOutline,
                          inputType: TextInputType.emailAddress,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                        
                        const SizedBox(height: 20),

                        // FIELD PASSWORD
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: EvaIcons.lockOutline,
                          obscureText: _isObscure,
                          isPassword: true,
                          onToggleVisibility: () => setState(() => _isObscure = !_isObscure),
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                        
                        const SizedBox(height: 32),

                        // TOMBOL REGISTER
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shadowColor: primaryColor.withOpacity(0.4),
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: (state is AuthLoading)
                                ? null
                                : () {
                                    context.read<AuthCubit>().signUpWithEmail(
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          username: _usernameController.text,
                                        );
                                  },
                            child: (state is AuthLoading)
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    'Daftar Sekarang',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                        const SizedBox(height: 24),

                        // LINK LOGIN
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: GoogleFonts.poppins(color: Colors.grey[600]),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go(LoginScreen.route);
                              },
                              child: Text(
                                'Login',
                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 700.ms),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: inputType,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[500]),
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor.withOpacity(0.6)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? EvaIcons.eyeOffOutline : EvaIcons.eyeOutline,
                    color: Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}