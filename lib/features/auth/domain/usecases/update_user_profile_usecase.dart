import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository repository;
  UpdateUserProfileUseCase({required this.repository});

  Future<Either<Failure, void>> call({required String username}) async {
    return await repository.updateProfile(username: username);
  }
}