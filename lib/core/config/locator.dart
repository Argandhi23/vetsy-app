import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import Service & Features
import 'package:vetsy_app/core/services/notification_service.dart';
import 'package:vetsy_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vetsy_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:vetsy_app/features/auth/domain/usecases/get_user_profile_usecase.dart';
import 'package:vetsy_app/features/auth/domain/usecases/update_user_profile_usecase.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:vetsy_app/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:vetsy_app/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/add_review_usecase.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinic_detail_usecase.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinics_usecase.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_detail/clinic_detail_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/review/review_cubit.dart';
import 'package:vetsy_app/features/pet/data/datasources/pet_remote_data_source.dart';
import 'package:vetsy_app/features/pet/data/repositories/pet_repository_impl.dart';
import 'package:vetsy_app/features/pet/domain/repositories/pet_repository.dart';
import 'package:vetsy_app/features/pet/domain/usecases/add_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/delete_pet_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/get_my_pets_usecase.dart';
import 'package:vetsy_app/features/pet/domain/usecases/update_pet_usecase.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';
import 'package:vetsy_app/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:vetsy_app/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:vetsy_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:vetsy_app/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:vetsy_app/features/booking/domain/usecases/create_booking_usecase.dart';
import 'package:vetsy_app/features/booking/domain/usecases/get_my_bookings_usecase.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:vetsy_app/features/home/presentation/cubit/banner_cubit.dart';
// [PENTING] Import NotificationCubit
import 'package:vetsy_app/features/notification/presentation/cubit/notification_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // EXTERNAL
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<NotificationService>(NotificationService());

  // AUTH
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(firebaseAuth: sl(), firestore: sl()));
  sl.registerFactory(() => GetUserProfileUseCase(repository: sl()));
  sl.registerFactory(() => UpdateUserProfileUseCase(repository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(firebaseAuth: sl(), firestore: sl()));

  // CLINIC
  sl.registerLazySingleton(() => ClinicCubit(getClinicsUseCase: sl()));
  sl.registerFactory(() => ClinicDetailCubit(getClinicDetailUseCase: sl()));
  sl.registerFactory(() => GetClinicsUseCase(repository: sl()));
  sl.registerFactory(() => GetClinicDetailUseCase(repository: sl()));
  sl.registerLazySingleton<ClinicRepository>(() => ClinicRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ClinicRemoteDataSource>(() => ClinicRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton(() => AddReviewUseCase(repository: sl()));
  sl.registerFactory(() => ReviewCubit(addReviewUseCase: sl()));

  // PET
  sl.registerLazySingleton(() => MyPetsCubit(
    petRepository: sl(),
    getMyPetsUseCase: sl(),
    addPetUseCase: sl(),
    deletePetUseCase: sl(),
    updatePetUseCase: sl(),
  ));
  sl.registerFactory(() => GetMyPetsUseCase(repository: sl()));
  sl.registerFactory(() => AddPetUseCase(repository: sl()));
  sl.registerFactory(() => UpdatePetUseCase(repository: sl()));
  sl.registerFactory(() => DeletePetUseCase(repository: sl()));
  sl.registerLazySingleton<PetRepository>(() => PetRepositoryImpl(remoteDataSource: sl(), firebaseAuth: sl()));
  sl.registerLazySingleton<PetRemoteDataSource>(() => PetRemoteDataSourceImpl(firestore: sl()));

  // BOOKING
  sl.registerFactory(() => BookingCubit(
    getMyPetsUseCase: sl(),
    createBookingUseCase: sl(),
    firebaseAuth: sl(),
    bookingRepository: sl(),
  ));

  sl.registerLazySingleton(() => MyBookingsCubit(
    remoteDataSource: sl(), 
    auth: sl(),
    cancelBookingUseCase: sl(),
  ));

  sl.registerFactory(() => CreateBookingUseCase(repository: sl()));
  sl.registerFactory(() => GetMyBookingsUseCase(repository: sl()));
  sl.registerFactory(() => CancelBookingUseCase(repository: sl()));
  sl.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(remoteDataSource: sl(), firebaseAuth: sl()));
  sl.registerLazySingleton<BookingRemoteDataSource>(() => BookingRemoteDataSourceImpl(firestore: sl()));

  // PROFILE
  sl.registerLazySingleton(() => ProfileCubit(getUserProfileUseCase: sl(), updateUserProfileUseCase: sl()));

  // BANNER
  sl.registerFactory(() => BannerCubit(firestore: sl()));

  // [BARU] NOTIFICATION CUBIT (Untuk Listen Realtime)
  sl.registerLazySingleton(() => NotificationCubit(
    notificationService: sl(),
    auth: sl(),
    firestore: sl(),
  ));
}