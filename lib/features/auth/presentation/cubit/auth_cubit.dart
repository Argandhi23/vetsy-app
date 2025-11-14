// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Nanti ini akan dipindah ke Repository

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _userSubscription;

  AuthCubit() : super(AuthInitial()) {
    // Ini adalah "listener" canggih.
    // Cubit ini akan "mendengarkan" status login dari Firebase secara real-time.
    _userSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // Jika user null, kita kirim state Unauthenticated
        emit(const Unauthenticated());
      } else {
        // Jika user ada, kita kirim state Authenticated
        emit(Authenticated(user: user));
      }
    });
  }

  // Fungsi untuk logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fungsi-fungsi lain (login, register) akan ada di Cubit terpisah
  // Ini HANYA untuk memantau status global

  @override
  Future<void> close() {
    _userSubscription.cancel(); // Matikan listener saat Cubit ditutup
    return super.close();
  }
}