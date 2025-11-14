// lib/core/errors/exceptions.dart

// Dipakai saat server (Firebase) mengembalikan error
class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}

// Dipakai saat tidak ada koneksi, dll
class NetworkException implements Exception {}