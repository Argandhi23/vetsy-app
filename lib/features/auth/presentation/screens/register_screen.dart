// lib/features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
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
                    'Buat Akun Baru',
                    style: TextStyle(
                      // Ganti .sp menjadi statis
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Daftar untuk mulai merawat hewanmu',
                    style: TextStyle(
                      // Ganti .sp menjadi statis
                      fontSize: 16,
                      color: Colors.grey[600]),
                  ),
                  SizedBox(height: 5.h),
                  TextField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  ),
                  SizedBox(height: 2.h),
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
                            context.read<AuthCubit>().signUpWithEmail(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  username: _usernameController.text,
                                );
                          },
                    child: (state is AuthLoading)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Register', style: TextStyle(
                          // Ganti .sp menjadi statis
                          fontSize: 16)
                        ),
                  ),
                  SizedBox(height: 2.h),
                  TextButton(
                    onPressed: () {
                      context.go(LoginScreen.route);
                    },
                    child: const Text('Sudah punya akun? Login di sini'),
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