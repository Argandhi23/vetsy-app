import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final double price; // [BARU] Tambahkan field ini

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.price, // [BARU]
  });

  @override
  List<Object?> get props => [id, name, price];
}