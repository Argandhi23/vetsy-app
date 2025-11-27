import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String userId; // [BARU] Penanda Pemilik
  final String name;
  final String type;
  final String breed;
  final int age; 
  final double weight; 

  const PetEntity({
    required this.id,
    required this.userId, // [BARU]
    required this.name,
    required this.type,
    required this.breed,
    this.age = 0,
    this.weight = 0.0,
  });

  @override
  List<Object?> get props => [id, userId, name, type, breed, age, weight];
}