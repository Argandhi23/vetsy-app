// lib/features/clinic/presentation/screens/clinic_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/features/clinic/data/datasources/clinic_remote_data_source.dart';
import 'package:vetsy_app/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/clinic/domain/usecases/get_clinic_detail_usecase.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_detail/clinic_detail_cubit.dart';

class ClinicDetailScreen extends StatelessWidget {
  static const String routeName = 'clinic-detail';
  static const String routePath = '/clinic/:clinicId';

  final String clinicId;

  const ClinicDetailScreen({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Sediakan Cubit baru untuk halaman ini
    return BlocProvider(
      create: (context) {
        // 2. Lakukan Dependency Injection (Manual)
        final ClinicRemoteDataSource remoteDataSource =
            ClinicRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
        final ClinicRepositoryImpl repository =
            ClinicRepositoryImpl(remoteDataSource: remoteDataSource);
        final GetClinicDetailUseCase useCase =
            GetClinicDetailUseCase(repository: repository);

        // 3. Buat Cubit dan panggil fungsi fetch
        return ClinicDetailCubit(getClinicDetailUseCase: useCase)
          ..fetchClinicDetail(clinicId);
      },
      child: const ClinicDetailView(), // Panggil View-nya
    );
  }
}

// Ini adalah View murni (UI)
class ClinicDetailView extends StatelessWidget {
  const ClinicDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Kita 'dengarkan' Cubit
    return Scaffold(
      body: BlocBuilder<ClinicDetailCubit, ClinicDetailState>(
        builder: (context, state) {
          // KASUS 1: LOADING
          if (state is ClinicDetailLoading || state is ClinicDetailInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          // KASUS 2: GAGAL
          if (state is ClinicDetailError) {
            return Center(
              child: Text(
                'Gagal memuat data: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // KASUS 3: SUKSES
          if (state is ClinicDetailLoaded) {
            final clinic = state.clinic;
            // Kita gunakan CustomScrollView untuk efek AppBar keren
            return CustomScrollView(
              slivers: [
                // AppBar yang bisa membesar/mengecil
                SliverAppBar(
                  expandedHeight: 30.h, // Tinggi AppBar saat besar
                  pinned: true, // Tetap terlihat saat di-scroll
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      clinic.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 10.0, color: Colors.black)
                        ],
                      ),
                    ),
                    background: Image.network(
                      clinic.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: Colors.grey),
                    ),
                  ),
                ),

                // Isi Halaman (Daftar)
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Bagian Alamat
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              clinic.address,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),

                      // Pemisah
                      const Divider(thickness: 2),

                      // Bagian Layanan
                      Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Text(
                          'Layanan Tersedia',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Daftar Layanan
                      ...clinic.services.map((service) {
                        return _buildServiceTile(context, service);
                      }).toList(),
                      
                      SizedBox(height: 10.h), // Spasi di bawah
                    ],
                  ),
                ),
              ],
            );
          }

          // Fallback (seharusnya tidak terjadi)
          return const Center(child: Text('Terjadi kesalahan'));
        },
      ),
    );
  }

  // Widget helper untuk menampilkan 1 layanan
  Widget _buildServiceTile(BuildContext context, ServiceEntity service) {
    return ListTile(
      title: Text(service.name, style: TextStyle(fontSize: 13.sp)),
      subtitle: Text(
        'Rp ${service.price}', // Nanti kita format
        style: TextStyle(fontSize: 12.sp, color: Colors.green[700]),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // TODO: Navigasi ke Halaman Booking
        },
        child: const Text('Booking'), 
      ),
    );
  }
}