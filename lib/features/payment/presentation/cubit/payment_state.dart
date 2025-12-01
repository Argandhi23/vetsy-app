import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;
  const PaymentSuccess(this.message);
}

class PaymentFailure extends PaymentState {
  final String error;
  const PaymentFailure(this.error);
}