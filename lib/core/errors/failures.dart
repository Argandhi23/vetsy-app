// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// Kegagalan dari server/Firebase
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

// Kegagalan dari koneksi
class NetworkFailure extends Failure {
  const NetworkFailure() : super(message: "Tidak ada koneksi internet");
}