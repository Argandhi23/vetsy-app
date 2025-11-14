// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/core/errors/failures.dart';

// Ini adalah 'kontrak'
// Dia mendefinisikan 'apa' yang bisa dilakukan,
// bukan 'bagaimana' caranya.

abstract class AuthRepository {
  // Saat sukses, kembalikan 'User' (dari Firebase Auth)
  // Saat gagal, kembalikan 'Failure' (dari file error kita)
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String username,
  });

  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  // Kita tidak perlu state stream di sini,
  // karena AuthCubit global sudah menanganinya
}