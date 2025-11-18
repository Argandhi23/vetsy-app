// lib/features/booking/presentation/cubit/booking_state.dart
part of 'booking_cubit.dart';

// Enum untuk status halaman
enum BookingPageStatus {
  initial,
  loadingPets, // Sedang mengambil data hewan
  petsLoaded, // Data hewan berhasil diambil, form siap diisi
  submitting, // Sedang mengirim booking
  success, // Booking berhasil
  error, // Terjadi error
}

class BookingState extends Equatable {
  // Status keseluruhan halaman
  final BookingPageStatus status;
  // Daftar hewan untuk dipilih
  final List<PetEntity> pets;
  // Pilihan user
  final PetEntity? selectedPet;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime; // <-- INI YANG BARU
  // Pesan error jika ada
  final String? errorMessage;

  const BookingState({
    this.status = BookingPageStatus.initial,
    this.pets = const [],
    this.selectedPet,
    this.selectedDate,
    this.selectedTime, // <-- INI YANG BARU
    this.errorMessage,
  });

  // Helper 'copyWith' untuk update state dengan mudah
  BookingState copyWith({
    BookingPageStatus? status,
    List<PetEntity>? pets,
    PetEntity? selectedPet,
    DateTime? selectedDate,
    TimeOfDay? selectedTime, // <-- INI YANG BARU
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      pets: pets ?? this.pets,
      selectedPet: selectedPet ?? this.selectedPet,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime, // <-- INI YANG BARU
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pets,
        selectedPet,
        selectedDate,
        selectedTime, // <-- INI YANG BARU
        errorMessage,
      ];
}