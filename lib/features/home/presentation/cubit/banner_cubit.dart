import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vetsy_app/features/home/data/models/banner_model.dart';

// State
abstract class BannerState {}
class BannerInitial extends BannerState {}
class BannerLoading extends BannerState {}
class BannerLoaded extends BannerState {
  final List<BannerModel> banners;
  BannerLoaded(this.banners);
}
class BannerError extends BannerState {
  final String message;
  BannerError(this.message);
}

// Cubit
class BannerCubit extends Cubit<BannerState> {
  final FirebaseFirestore firestore;

  BannerCubit({required this.firestore}) : super(BannerInitial());

  Future<void> fetchBanners() async {
    emit(BannerLoading());
    try {
      final snapshot = await firestore.collection('banners').where('isActive', isEqualTo: true).get();
      final banners = snapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
      emit(BannerLoaded(banners));
    } catch (e) {
      emit(BannerError(e.toString()));
    }
  }
}