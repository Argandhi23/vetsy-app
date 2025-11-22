import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vetsy_app/features/clinic/domain/entities/review_entity.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/add_review_usecase.dart';

// --- STATE ---
abstract class ReviewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}
class ReviewLoading extends ReviewState {}
class ReviewSuccess extends ReviewState {}
class ReviewError extends ReviewState {
  final String message;
  ReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- CUBIT ---
class ReviewCubit extends Cubit<ReviewState> {
  final AddReviewUseCase addReviewUseCase;

  ReviewCubit({required this.addReviewUseCase}) : super(ReviewInitial());

  Future<void> submitReview({
    required String clinicId,
    required String userId,
    required String username,
    required double rating,
    required String comment,
  }) async {
    emit(ReviewLoading());

    final review = ReviewEntity(
      id: '',
      userId: userId,
      username: username,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    final result = await addReviewUseCase(clinicId, review);

    result.fold(
      (failure) => emit(ReviewError(failure.message)),
      (_) => emit(ReviewSuccess()),
    );
  }
}