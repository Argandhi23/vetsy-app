// lib/features/auth/data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/exception.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/auth/data/models/user_model.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

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
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user != null) {
        await firestore.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
        });
        return Right(user);
      } else {
        throw ServerException(message: "Gagal membuat user");
      }
    } on FirebaseAuthException catch (e) {
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
        return Right(userCredential.user!);
      } else {
         throw ServerException(message: "Gagal login");
      }
    } on FirebaseAuthException catch (e) {
      return Left(ServerFailure(message: e.message ?? "Error tidak diketahui"));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return Left(ServerFailure(message: "Data user tidak ditemukan"));
      }
      final userModel = UserModel.fromFirestore(doc);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // IMPLEMENTASI BARU
  @override
  Future<Either<Failure, void>> updateProfile({required String username}) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Left(ServerFailure(message: "User tidak terautentikasi"));
      }
      // Update data di Firestore
      await firestore.collection('users').doc(user.uid).update({
        'username': username,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}