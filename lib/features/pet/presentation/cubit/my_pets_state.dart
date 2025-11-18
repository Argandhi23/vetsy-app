// lib/features/pet/presentation/cubit/my_pets_state.dart
part of 'my_pets_cubit.dart';

enum MyPetsStatus { initial, loading, loaded, error, submitting }

class MyPetsState extends Equatable {
  final MyPetsStatus status;
  final List<PetEntity> pets;
  final String? errorMessage;

  const MyPetsState({
    this.status = MyPetsStatus.initial,
    this.pets = const [],
    this.errorMessage,
  });

  MyPetsState copyWith({
    MyPetsStatus? status,
    List<PetEntity>? pets,
    String? errorMessage,
  }) {
    return MyPetsState(
      status: status ?? this.status,
      pets: pets ?? this.pets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, pets, errorMessage];
}