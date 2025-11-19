import 'package:equatable/equatable.dart';

class ClinicEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String imageUrl;
  // DATA BARU: List Kategori
  final List<String> categories; 

  const ClinicEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.categories = const [], // Default kosong
  });

  @override
  List<Object?> get props => [id, name, address, imageUrl, categories];
}