import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
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

  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<Either<Failure, void>> updateProfile({required String username});

  // --- FUNGSI BARU ---
  Future<Either<Failure, void>> resetPassword(String email);
  // Ubah baris updatePassword menjadi:
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
