// lib/features/clinic/presentation/screens/clinic_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Animasi
import 'package:eva_icons_flutter/eva_icons_flutter.dart'; // Icon Keren
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
      backgroundColor: Colors.grey[50], // Background sedikit abu
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
                  // --- 1. HEADER GAMBAR MODERN ---
                  SliverAppBar(
                    expandedHeight: 300, // Tinggi fixed (aman di web)
                    pinned: true,
                    stretch: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Icon(EvaIcons.arrowBack, color: Colors.white),
                      ),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Gambar Klinik
                          Image.network(
                            clinic.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey),
                          ),
                          // Gradient Overlay (Agar teks putih terbaca)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Judul di kiri bawah
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                      title: Text(
                        clinic.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // --- 2. KONTEN BODY ---
                  SliverToBoxAdapter(
                    child: Container(
                      // Efek melengkung menutupi bagian bawah gambar
                      transform: Matrix4.translationValues(0, -10, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.all(24), // Padding fixed
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Indikator garis kecil di tengah atas (opsional, gaya bottom sheet)
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Bagian Alamat
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(EvaIcons.pin, color: Theme.of(context).primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Lokasi Klinik",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      clinic.address,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Judul Layanan
                          const Text(
                            'Layanan Tersedia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Daftar Layanan
                          ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true, // Agar bisa di dalam ScrollView
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: clinic.services.length,
                            separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final service = clinic.services[index];
                              return _buildServiceCard(context, service, index);
                            },
                          ),
                          
                          const SizedBox(height: 40), // Spacer bawah
                        ],
                      ),
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

  // --- WIDGET KARTU LAYANAN YANG CANTIK ---
  Widget _buildServiceCard(BuildContext context, ServiceEntity service, int index) {
    final clinic =
        (context.read<ClinicDetailCubit>().state as ClinicDetailLoaded).clinic;
    
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon Layanan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(EvaIcons.activityOutline, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),

          // Info Layanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(service.price),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Booking
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
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
            child: const Text(
              'Book',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    )
    .animate() // Animasi slide in per item
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.2, curve: Curves.easeOutQuad, delay: (100 * index).ms);
  }
}