// lib/features/auth/presentation/cubit/auth_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  late StreamSubscription _authSubscription;

  AuthCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        super(AuthInitial()) {
    // Mendengarkan perubahan status auth secara real-time
    _authSubscription =
        _firebaseAuth.authStateChanges().listen((User? user) {
      if (user == null) {
        emit(Unauthenticated());
      } else {
        emit(Authenticated(user));
      }
    });
  }

  // FUNGSI YANG HILANG (ERROR MERAH 6)
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading());
    try {
      // 1. Buat user di Auth
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // 2. Simpan data user (username) di Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
        });
        // State Authenticated akan di-emit oleh listener
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Terjadi kesalahan saat daftar.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // FUNGSI YANG HILANG (ERROR MERAH 3)
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // State Authenticated akan di-emit oleh listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Terjadi kesalahan saat login.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // State Unauthenticated akan di-emit oleh listener
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}