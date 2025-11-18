// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String username;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.username,
  });

  @override
  List<Object?> get props => [uid, email, username];
}