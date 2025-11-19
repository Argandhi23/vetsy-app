// lib/features/pet/presentation/cubit/my_pets_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/update_pet_usecase.dart';

part 'my_pets_state.dart';

class MyPetsCubit extends Cubit<MyPetsState> {
  final GetMyPetsUseCase getMyPetsUseCase;
  final AddPetUseCase addPetUseCase;
  final DeletePetUseCase deletePetUseCase;
  final UpdatePetUseCase updatePetUseCase;

  MyPetsCubit({
    required this.getMyPetsUseCase,
    required this.addPetUseCase,
    required this.deletePetUseCase,
    required this.updatePetUseCase,
  }) : super(const MyPetsState());

  Future<void> fetchMyPets() async {
    emit(state.copyWith(status: MyPetsStatus.loading));
    final result = await getMyPetsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
          status: MyPetsStatus.error, errorMessage: failure.message)),
      (pets) =>
          emit(state.copyWith(status: MyPetsStatus.loaded, pets: pets)),
    );
  }

  // UPDATE: Tambah parameter age & weight
  Future<void> addPet({
    required String name,
    required String type,
    required String breed,
    required int age,      // <-- Tambah
    required double weight, // <-- Tambah
  }) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    
    final result = await addPetUseCase(
      name: name, 
      type: type, 
      breed: breed,
      age: age,
      weight: weight,
    );
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(
            status: MyPetsStatus.error, errorMessage: failure.message));
        await fetchMyPets();
      },
      (_) async => await fetchMyPets(),
    );
  }

  Future<void> deletePet(String petId) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    final result = await deletePetUseCase(petId);
    await result.fold(
      (failure) async {
        emit(state.copyWith(
            status: MyPetsStatus.error, errorMessage: failure.message));
        await fetchMyPets();
      },
      (_) async => await fetchMyPets(),
    );
  }

  // UPDATE: Tambah parameter age & weight
  Future<void> updatePet({
    required String id,
    required String name,
    required String type,
    required String breed,
    required int age,      // <-- Tambah
    required double weight, // <-- Tambah
  }) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    
    final petToUpdate = PetEntity(
      id: id, 
      name: name, 
      type: type, 
      breed: breed,
      age: age,         // <-- Masukkan ke Entity
      weight: weight,   // <-- Masukkan ke Entity
    );

    final result = await updatePetUseCase(petToUpdate);
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(
          status: MyPetsStatus.error,
          errorMessage: failure.message,
        ));
        await fetchMyPets();
      },
      (_) async {
        await fetchMyPets();
      },
    );
  }

  void reset() {
    emit(const MyPetsState());
  }
}