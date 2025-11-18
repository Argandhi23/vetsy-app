// lib/features/clinic/presentation/widgets/clinic_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
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
            itemCount: state.clinics.length,
            itemBuilder: (context, index) {
              final clinic = state.clinics[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    context
                        .goNamed(ClinicDetailScreen.routeName, pathParameters: {
                      'clinicId': clinic.id,
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Image.network(
                          clinic.imageUrl,
                          height: 20.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 20.h,
                            color: Colors.grey[200],
                            child:
                                const Icon(Icons.error, color: Colors.grey),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clinic.name,
                              style: TextStyle(
                                // Ganti .sp menjadi statis
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              clinic.address,
                              style: TextStyle(
                                // Ganti .sp menjadi statis
                                fontSize: 14,
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
            },
          );
        }
        return Container();
      },
    );
  }
}