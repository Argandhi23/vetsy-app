// lib/features/auth/presentation/screens/register_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Import Cubit & Repository
import 'package:vetsy_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/register/register_cubit.dart';
import 'package:vetsy_app/features/auth/screens/login_screen.dart';


class RegisterScreen extends StatelessWidget {
  static const String route = '/register';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita 'sediakan' Cubit baru untuk halaman ini
    // Kita juga 'suntikkan' repository (AuthRepositoryImpl) ke dalamnya
    return BlocProvider(
      create: (context) => RegisterCubit(
        // Ini adalah Dependency Injection manual:
        authRepository: AuthRepositoryImpl(
          firebaseAuth: FirebaseAuth.instance,
          firestore: FirebaseFirestore.instance,
        ),
      ),
      child: const RegisterView(),
    );
  }
}

// Ini adalah View-nya (UI Murni)
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Untuk validasi

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    // Cek validasi form
    if (_formKey.currentState!.validate()) {
      // Panggil fungsi cubit
      context.read<RegisterCubit>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(LoginScreen.route), // Kembali ke Login
        ),
      ),
      // BlocListener untuk 'mendengar' state dan melakukan aksi
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            // Sukses!
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Registrasi berhasil! Silakan login.'),
                  backgroundColor: Colors.green),
            );
            // Pindah ke halaman login
            context.go(LoginScreen.route);
          } else if (state is RegisterFailure) {
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
                    'Buat Akun Vetsy',
                    style: TextStyle(
                      fontSize: 20.sp, // <-- Sizer
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 5.h), // <-- Sizer
                  TextFormField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                    validator: (value) =>
                        value!.isEmpty ? 'Username tidak boleh kosong' : null,
                  ),
                  SizedBox(height: 2.h),
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
                    validator: (value) => value!.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  SizedBox(height: 3.h),
                  // BlocBuilder untuk ganti UI berdasarkan state
                  BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      // Jika state-nya loading, tampilkan spinner
                      if (state is RegisterLoading) {
                        return const CircularProgressIndicator();
                      }
                      // Jika tidak, tampilkan tombol
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit, // Panggil fungsi submit
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2.h)),
                          child: Text('Daftar', style: TextStyle(fontSize: 14.sp)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}