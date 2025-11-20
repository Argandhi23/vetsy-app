import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/features/pet/data/models/medical_record_model.dart';
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

  // Instance Firestore & Auth untuk fitur Medical Record
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MyPetsCubit({
    required this.getMyPetsUseCase,
    required this.addPetUseCase,
    required this.deletePetUseCase,
    required this.updatePetUseCase,
  }) : super(const MyPetsState());

  // --- FITUR UTAMA: CRUD HEWAN ---

  Future<void> fetchMyPets() async {
    emit(state.copyWith(status: MyPetsStatus.loading));
    final result = await getMyPetsUseCase();
    result.fold(
      (failure) => emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message)),
      (pets) => emit(state.copyWith(status: MyPetsStatus.loaded, pets: pets)),
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
    
    final result = await addPetUseCase(
      name: name, 
      type: type, 
      breed: breed,
      age: age,
      weight: weight,
    );
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message));
        await fetchMyPets();
      },
      (_) async => await fetchMyPets(),
    );
  }

  Future<void> updatePet({
    required String id,
    required String name,
    required String type,
    required String breed,
    required int age,
    required double weight,
  }) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    
    // Membungkus data ke Entity agar sesuai parameter UseCase
    final petToUpdate = PetEntity(
      id: id, 
      name: name, 
      type: type, 
      breed: breed,
      age: age,
      weight: weight,
    );

    final result = await updatePetUseCase(petToUpdate);
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message));
        await fetchMyPets();
      },
      (_) async => await fetchMyPets(),
    );
  }

  Future<void> deletePet(String petId) async {
    emit(state.copyWith(status: MyPetsStatus.submitting));
    
    // Optimistic Update: Hapus visual dulu biar cepat
    final currentPets = List<PetEntity>.from(state.pets);
    currentPets.removeWhere((p) => p.id == petId);
    emit(state.copyWith(pets: currentPets));

    final result = await deletePetUseCase(petId);
    await result.fold(
      (failure) async {
        await fetchMyPets(); // Revert jika gagal
        emit(state.copyWith(status: MyPetsStatus.error, errorMessage: failure.message));
      },
      (_) async => await fetchMyPets(),
    );
  }

  // --- FITUR TAMBAHAN: RIWAYAT KESEHATAN (MEDICAL RECORDS) ---

  Stream<List<MedicalRecordModel>> getMedicalRecords(String petId) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('pets')
        .doc(petId)
        .collection('records')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MedicalRecordModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addMedicalRecord({
    required String petId,
    required String title,
    required String notes,
    required DateTime date,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('pets')
          .doc(petId)
          .collection('records')
          .add({
        'title': title,
        'notes': notes,
        'date': Timestamp.fromDate(date),
      });
    }
  }

  void reset() {
    emit(const MyPetsState());
  }
}