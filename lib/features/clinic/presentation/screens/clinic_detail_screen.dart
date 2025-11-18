// lib/features/clinic/presentation/screens/clinic_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_detail/clinic_detail_cubit.dart';

class ClinicDetailScreen extends StatelessWidget {
  static const String routeName = 'clinic-detail';

  final String clinicId;

  const ClinicDetailScreen({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<ClinicDetailCubit>()..fetchClinicDetail(clinicId),
      child: const ClinicDetailView(),
    );
  }
}

class ClinicDetailView extends StatelessWidget {
  const ClinicDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveConstraintBox(
        child: BlocBuilder<ClinicDetailCubit, ClinicDetailState>(
          builder: (context, state) {
            if (state is ClinicDetailLoading || state is ClinicDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ClinicDetailError) {
              return Center(child: Text(state.message));
            }
            if (state is ClinicDetailLoaded) {
              final clinic = state.clinic;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 30.h,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        clinic.name,
                        style: TextStyle(
                          // Ganti .sp menjadi statis
                          fontSize: 18,
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
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Alamat',
                                style: TextStyle(
                                    // Ganti .sp menjadi statis
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                clinic.address,
                                // Ganti .sp menjadi statis
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 2),
                        Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            'Layanan Tersedia',
                            style: TextStyle(
                                // Ganti .sp menjadi statis
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...clinic.services.map((service) {
                          return _buildServiceTile(context, service);
                        }).toList(),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text('Terjadi kesalahan'));
          },
        ),
      ),
    );
  }

  Widget _buildServiceTile(BuildContext context, ServiceEntity service) {
    final clinic =
        (context.read<ClinicDetailCubit>().state as ClinicDetailLoaded).clinic;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return ListTile(
      title: Text(service.name, style: TextStyle(
        // Ganti .sp menjadi statis
        fontSize: 15)
      ),
      subtitle: Text(
        currencyFormatter.format(service.price),
        style: TextStyle(
          // Ganti .sp menjadi statis
          fontSize: 14,
          color: Colors.green[700]),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          context.goNamed(
            BookingScreen.routeName,
            pathParameters: {'clinicId': clinic.id},
            extra: {
              'clinicId': clinic.id,
              'clinicName': clinic.name,
              'service': service,
            },
          );
        },
        child: const Text('Booking'),
      ),
    );
  }
}