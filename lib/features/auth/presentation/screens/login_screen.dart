// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ResponsiveConstraintBox(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Selamat Datang Kembali!',
                    style: TextStyle(
                      // Ganti .sp menjadi statis
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Silakan login untuk melanjutkan',
                    style: TextStyle(
                      // Ganti .sp menjadi statis
                      fontSize: 16,
                      color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5.h),
                  TextField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _passwordController,
                    decoration:
                        const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                  ),
                  SizedBox(height: 4.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    onPressed: (state is AuthLoading)
                        ? null
                        : () {
                            context.read<AuthCubit>().signInWithEmail(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                );
                          },
                    child: (state is AuthLoading)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Login', style: TextStyle(
                          // Ganti .sp menjadi statis
                          fontSize: 16)
                        ),
                  ),
                  SizedBox(height: 2.h),
                  TextButton(
                    onPressed: () {
                      context.go(RegisterScreen.route);
                    },
                    child: const Text('Belum punya akun? Register di sini'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}