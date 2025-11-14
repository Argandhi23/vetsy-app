// lib/features/clinic/domain/entities/clinic_entity.dart
import 'package:equatable/equatable.dart';

class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, address, imageUrl];
}