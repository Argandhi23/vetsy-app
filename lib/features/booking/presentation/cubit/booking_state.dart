part of 'booking_cubit.dart';

enum BookingPageStatus { initial, loadingPets, petsLoaded, loadingSlots, slotsLoaded, submitting, success, error }

class BookingState extends Equatable {
  final BookingPageStatus status;
  final List<PetEntity> pets;
  final PetEntity? selectedPet;
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final String? errorMessage;
  
  // List jam yang sudah penuh (Digunakan di BookingScreen untuk Grid)
  final List<TimeOfDay> busyTimes;

  const BookingState({
    this.status = BookingPageStatus.initial,
    this.pets = const [],
    this.selectedPet,
    this.selectedDate,
    this.selectedTime,
    this.errorMessage,
    this.busyTimes = const [],
  });

  BookingState copyWith({
    BookingPageStatus? status,
    List<PetEntity>? pets,
    PetEntity? selectedPet,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    String? errorMessage,
    List<TimeOfDay>? busyTimes,
  }) {
    return BookingState(
      status: status ?? this.status,
      pets: pets ?? this.pets,
      selectedPet: selectedPet ?? this.selectedPet,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      errorMessage: errorMessage,
      busyTimes: busyTimes ?? this.busyTimes,
    );
  }

  @override
  List<Object?> get props => [status, pets, selectedPet, selectedDate, selectedTime, errorMessage, busyTimes];
}