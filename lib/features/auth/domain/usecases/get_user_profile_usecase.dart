// lib/features/auth/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/auth/domain/entities/user_entity.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository repository;
  GetUserProfileUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getUserProfile();
  }
}