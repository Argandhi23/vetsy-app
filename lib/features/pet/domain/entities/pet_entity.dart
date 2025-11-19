import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String breed;
  final int age; // Baru: Umur (bulan)
  final double weight; // Baru: Berat (kg)

  const PetEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    this.age = 0, // Default
    this.weight = 0.0, // Default
  });

  @override
  List<Object?> get props => [id, name, type, breed, age, weight];
}