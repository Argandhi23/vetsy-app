// lib/features/clinic/presentation/widgets/clinic_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // <-- 1. IMPORT GO_ROUTER
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
// 2. IMPORT HALAMAN DETAIL
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';

class ClinicListWidget extends StatelessWidget {
  const ClinicListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) {
        // ... (KASUS LOADING & ERROR tetap sama) ...
        if (state is ClinicLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ClinicError) {
          return Center(
            child: Text(
              'Gagal memuat data: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // KASUS 3: SUKSES
        if (state is ClinicLoaded) {
          if (state.clinics.isEmpty) {
            return const Center(child: Text('Belum ada klinik terdaftar.'));
          }

          // Gunakan SingleChildScrollView + Column (Sudah benar)
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: state.clinics.map((clinic) {
                
                // 3. BUNGKUS CARD DENGAN GestureDetector
                return GestureDetector(
                  onTap: () {
                    // 4. PANGGIL NAVIGASI DENGAN NAMA RUTE
                    context.goNamed(
                      ClinicDetailScreen.routeName,
                      pathParameters: {'clinicId': clinic.id},
                    );
                    // Ini akan menavigasi ke /home/[clinic.id]
                  },
                  child: Card(
                    key: ValueKey(clinic.id), // Key (Sudah benar)
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Container gambar (Sudah benar)
                        Container(
                          height: 20.h,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            child: Image.network(
                              clinic.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                      child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.grey, size: 50),
                                );
                              },
                            ),
                          ),
                        ),
                        // Detail Teks (Sudah benar)
                        Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic.name,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                clinic.address,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }

        // KASUS 4: INITIAL
        return const Center(child: Text('Memuat klinik...'));
      },
    );
  }
}