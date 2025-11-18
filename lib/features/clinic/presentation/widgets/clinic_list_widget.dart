// lib/features/clinic/presentation/widgets/clinic_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';

class ClinicListWidget extends StatelessWidget {
  const ClinicListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicCubit, ClinicState>(
      builder: (context, state) {
        if (state is ClinicLoading || state is ClinicInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ClinicError) {
          return Center(child: Text(state.message));
        }
        if (state is ClinicLoaded) {
          return ListView.builder(
            // Padding luar tetap pakai Sizer agar responsif terhadap tepi layar
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            itemCount: state.clinics.length,
            itemBuilder: (context, index) {
              final clinic = state.clinics[index];
              
              final fakeRating = (4.0 + (clinic.name.length % 10) / 10).toStringAsFixed(1);
              final fakeDistance = ((clinic.address.length % 5) + 1.2).toStringAsFixed(1);

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.only(bottom: 2.h),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context.goNamed(ClinicDetailScreen.routeName, pathParameters: {
                      'clinicId': clinic.id,
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0), // Ganti 3.w jadi fixed 12.0 agar aman di web
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- BAGIAN KIRI: GAMBAR ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            clinic.imageUrl,
                            // PERBAIKAN DISINI: 
                            // Jangan pakai .w untuk ukuran gambar list, pakai fixed pixel
                            width: 100, 
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16), // Jarak fixed 16 pixel

                        // --- BAGIAN KANAN: TEKS ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clinic.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // -- BAGIAN TAGS --
                              Row(
                                children: [
                                  _buildTag(
                                    EvaIcons.star,
                                    fakeRating,
                                    Colors.orange[700]!,
                                  ),
                                  const SizedBox(width: 16), // Jarak fixed
                                  _buildTag(
                                    EvaIcons.pinOutline,
                                    '$fakeDistance km',
                                    Colors.blue[800]!,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16), // Fixed size icon
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}