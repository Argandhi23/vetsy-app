// lib/features/auth/presentation/screens/login_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Import Cubit & Repository
import 'package:vetsy_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/login/login_cubit.dart';
import 'package:vetsy_app/features/auth/screens/register_screen.dart';


class LoginScreen extends StatelessWidget {
  static const String route = '/login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sediakan Cubit baru untuk halaman ini
    // dan suntikkan repository-nya
    return BlocProvider(
      create: (context) => LoginCubit(
        authRepository: AuthRepositoryImpl(
          firebaseAuth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Panggil fungsi cubit
      context.read<LoginCubit>().signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita pakai BlocListener untuk snackbar dan navigasi
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            // Sukses!
            // Kita tidak perlu navigasi di sini,
            // karena AuthCubit global & GoRouter akan
            // mendeteksi perubahan state dan me-redirect OTOMATIS.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Login berhasil!'),
                  backgroundColor: Colors.green),
            );
          } else if (state is LoginFailure) {
            // Gagal! Tampilkan error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 8.w), // <-- Sizer
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vetsy',
                    style: TextStyle(
                      fontSize: 30.sp, // <-- Sizer
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 5.h), // <-- Sizer
                  TextFormField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        value!.isEmpty || !value.contains('@')
                            ? 'Email tidak valid'
                            : null,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: _passwordController,
                    decoration:
                        const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Password tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 3.h),
                  // BlocBuilder untuk ganti UI
                  BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, state) {
                      // Jika loading, tampilkan spinner
                      if (state is LoginLoading) {
                        return const CircularProgressIndicator();
                      }
                      // Jika tidak, tampilkan tombol
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit, // Panggil fungsi submit
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h)),
                          child: Text('Login', style: TextStyle(fontSize: 14.sp)),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2.h),
                  TextButton(
                    onPressed: () {
                      // Pindah ke Halaman Register
                      context.go(RegisterScreen.route);
                    },
                    child: const Text('Belum punya akun? Daftar di sini'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

