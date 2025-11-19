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
    _init();
  }

  // --- INISIALISASI ---
  void _init() {
    // Mendengarkan perubahan status login (Login/Logout)
    _authSubscription = _firebaseAuth.authStateChanges().listen((User? user) async {
      if (user == null) {
        emit(Unauthenticated());
      } else {
        // Jika user ada, ambil data tambahan dari Firestore
        await _fetchUserData(user);
      }
    });
  }

  // --- HELPER: AMBIL DATA USER ---
  Future<void> _fetchUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        final data = doc.data();
        final role = data?['role'] ?? 'user';
        final clinicId = data?['clinicId'];
        final username = data?['username'];

        emit(Authenticated(
          user: user,
          role: role,
          clinicId: clinicId,
          username: username,
        ));
      } else {
        // Jika dokumen tidak ada, anggap user biasa
        emit(Authenticated(user: user, role: 'user'));
      }
    } catch (e) {
      // Jika error koneksi db, tetap izinkan login basic
      emit(Authenticated(user: user, role: 'user'));
    }
  }

  // --- FITUR: RELOAD DATA (Dipanggil setelah Edit Profil) ---
  Future<void> reloadUserData() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      await _fetchUserData(currentUser);
    }
  }

  // --- FITUR: REGISTER ---
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    emit(AuthLoading());
    try {
      // 1. Buat Akun di Auth
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      
      // 2. Simpan Detail di Firestore
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'role': 'user', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Gagal daftar'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- FITUR: LOGIN ---
  Future<void> signInWithEmail({
    required String email, 
    required String password
  }) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Gagal login'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // --- FITUR: LOGOUT ---
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  // --- FITUR: RESET PASSWORD (LUPA PASSWORD) ---
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? "Gagal kirim email reset";
    }
  }

  // --- FITUR: GANTI PASSWORD (DENGAN VERIFIKASI) ---
  Future<void> changePassword({
    required String currentPassword, 
    required String newPassword
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && user.email != null) {
        // 1. Buat kredensial dari password lama
        final cred = EmailAuthProvider.credential(
          email: user.email!, 
          password: currentPassword
        );

        // 2. Re-authenticate (Cek apakah password lama benar)
        await user.reauthenticateWithCredential(cred);
        
        // 3. Jika benar, update ke password baru
        await user.updatePassword(newPassword);
      } else {
        throw "User tidak ditemukan";
      }
    } on FirebaseAuthException catch (e) {
       if (e.code == 'wrong-password') {
        throw "Password lama yang Anda masukkan salah.";
      } else if (e.code == 'weak-password') {
        throw "Password baru terlalu lemah (min 6 karakter).";
      } else if (e.code == 'requires-recent-login') {
        throw "Demi keamanan, silakan Logout dan Login ulang untuk mengganti password.";
      }
      throw e.message ?? "Gagal ganti password";
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}