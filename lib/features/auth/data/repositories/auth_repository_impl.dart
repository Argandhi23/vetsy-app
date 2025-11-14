// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart';

// 'implements AuthRepository' berarti dia 'menandatangani kontrak'
// dari lapisan Domain.

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  // (Nanti kita akan cek koneksi internet juga)

  AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1. Buat user di Firebase Auth
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Simpan data tambahan ke Firestore
        await firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
        });

        // Sukses! Kembalikan 'User' di sisi 'Right'
        return Right(user);
      } else {
        // Seharusnya tidak pernah terjadi, tapi...
        throw ServerException(message: "Gagal membuat user");
      }
    } on FirebaseAuthException catch (e) {
      // Gagal! Kembalikan 'ServerFailure' di sisi 'Left'
      return Left(ServerFailure(message: e.message ?? "Error tidak diketahui"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Sukses! Kembalikan 'User' di sisi 'Right'
        return Right(userCredential.user!);
      } else {
         throw ServerException(message: "Gagal login");
      }
    } on FirebaseAuthException catch (e) {
      // Gagal! Kembalikan 'ServerFailure' di sisi 'Left'
      return Left(ServerFailure(message: e.message ?? "Error tidak diketahui"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      // Sukses! Kembalikan 'void' di sisi 'Right'
      return const Right(null);
    } catch (e) {
      // Gagal!
      return Left(ServerFailure(message: e.toString()));
    }
  }
}