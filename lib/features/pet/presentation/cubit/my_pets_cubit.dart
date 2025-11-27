import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/features/pet/data/models/medical_record_model.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';
import 'package:vetsy_app/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/update_pet_usecase.dart';

part 'my_pets_state.dart';

class MyPetsCubit extends Cubit<MyPetsState> {
  final PetRepository petRepository;
  final AddPetUseCase addPetUseCase;
  final DeletePetUseCase deletePetUseCase;
  final UpdatePetUseCase updatePetUseCase;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _petsSubscription;

  MyPetsCubit({
    required this.petRepository,
    required GetMyPetsUseCase getMyPetsUseCase, // Tetap ada biar injection aman
    required this.addPetUseCase,
    required this.deletePetUseCase,
    required this.updatePetUseCase,
  }) : super(const MyPetsState());

  // --- STREAM REALTIME ---
  Future<void> fetchMyPets() async {
    emit(state.copyWith(status: MyPetsStatus.loading));
    
    await _petsSubscription?.cancel();

    _petsSubscription = petRepository.getMyPetsStream().listen(
      (pets) {
        emit(state.copyWith(status: MyPetsStatus.loaded, pets: pets));
      },
      onError: (error) {
        emit(state.copyWith(status: MyPetsStatus.error, errorMessage: error.toString()));
      },
    );
  }

  Future<void> addPet({
    required String name,
    required String type,
    required String breed,
    required int age,
    required double weight,
  }) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    final result = await addPetUseCase(name: name, type: type, breed: breed, age: age, weight: weight);
    result.fold(
      (failure) => emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message)),
      (_) {}, // Stream akan update otomatis
    );
  }

  Future<void> updatePet({required String id, required String name, required String type, required String breed, required int age, required double weight}) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final petToUpdate = PetEntity(id: id, userId: userId, name: name, type: type, breed: breed, age: age, weight: weight);
    
    final result = await updatePetUseCase(petToUpdate);
    result.fold(
      (failure) => emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message)),
      (_) {},
    );
  }

  Future<void> deletePet(String petId) async {
    final currentPets = List<PetEntity>.from(state.pets);
    currentPets.removeWhere((p) => p.id == petId);
    emit(state.copyWith(pets: currentPets));

    final result = await deletePetUseCase(petId);
    result.fold(
      (failure) => emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message)),
      (_) {},
    );
  }

  // --- Medical Record Logic (Root Collection) ---
  Stream<List<MedicalRecordModel>> getMedicalRecords(String petId) {
    return _firestore
        .collection('medical_records')
        .where('petId', isEqualTo: petId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MedicalRecordModel.fromFirestore(doc)).toList());
  }

  Future<void> addMedicalRecord({required String petId, required String title, required String notes, required DateTime date}) async {
    await _firestore.collection('medical_records').add({
      'petId': petId,
      'title': title,
      'notes': notes,
      'date': Timestamp.fromDate(date),
    });
  }

  @override
  Future<void> close() {
    _petsSubscription?.cancel();
    return super.close();
  }

  void reset() {
    _petsSubscription?.cancel();
    emit(const MyPetsState());
  }
}