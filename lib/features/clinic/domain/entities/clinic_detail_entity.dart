import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';

class ClinicDetailEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  final String phone; // <-- TAMBAH INI
  final List<ServiceEntity> services;

  const ClinicDetailEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.phone, // <-- TAMBAH INI
    required this.services,
  });

  @override
  List<Object?> get props => [id, name, address, imageUrl, phone, services];
}