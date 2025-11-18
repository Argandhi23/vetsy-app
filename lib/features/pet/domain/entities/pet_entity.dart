// lib/features/pet/domain/entities/pet_entity.dart
import 'package:equatable/equatable.dart';

class PetEntity extends Equatable {
  final String id;
  final String name;
  final String type; // e.g., "Kucing", "Anjing"
  final String breed; // e.g., "Persia"

  const PetEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
  });

  @override
  List<Object?> get props => [id, name, type, breed];
}