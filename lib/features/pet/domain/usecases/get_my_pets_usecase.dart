import 'package:dartz/dartz.dart';
import 'package:vetsy_app/core/errors/failures.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';

class GetMyPetsUseCase {
  final PetRepository repository;

  GetMyPetsUseCase({required this.repository});

  // Usecase ini dipanggil oleh BookingCubit (butuh Future/Sekali ambil)
  Future<Either<Failure, List<PetEntity>>> call() async {
    try {
      // [PERBAIKAN] 
      // Kita ambil data dari Stream, tapi cuma elemen pertamanya saja (.first)
      // Ini mengubah Stream menjadi Future (Snapshot sekali ambil)
      final pets = await repository.getMyPetsStream().first;
      
      return Right(pets);
    } catch (e) {
      // Tangkap error jika ada masalah koneksi/stream
      return Left(ServerFailure(message: e.toString()));
    }
  }
}