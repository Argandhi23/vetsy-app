// lib/features/booking/presentation/cubit/my_bookings/my_bookings_state.dart
part of 'my_bookings_cubit.dart';

enum MyBookingsStatus { initial, loading, loaded, error }

class MyBookingsState extends Equatable {
  final MyBookingsStatus status;
  final List<BookingEntity> bookings;
  final String? errorMessage;

  const MyBookingsState({
    this.status = MyBookingsStatus.initial,
    this.bookings = const [],
    this.errorMessage,
  });

  MyBookingsState copyWith({
    MyBookingsStatus? status,
    List<BookingEntity>? bookings,
    String? errorMessage,
  }) {
    return MyBookingsState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}