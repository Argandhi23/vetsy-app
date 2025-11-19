import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_screen.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_detail/clinic_detail_cubit.dart';

class ClinicDetailScreen extends StatelessWidget {
  static const String routeName = 'clinic-detail';
  final String clinicId;
  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => sl<ClinicDetailCubit>()..fetchClinicDetail(clinicId),
        child: const ClinicDetailView());
  }
}

class ClinicDetailView extends StatelessWidget {
  const ClinicDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: ResponsiveConstraintBox(
        child: BlocBuilder<ClinicDetailCubit, ClinicDetailState>(
          builder: (context, state) {
            if (state is ClinicDetailLoading || state is ClinicDetailInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ClinicDetailError) return Center(child: Text(state.message));
            if (state is ClinicDetailLoaded) {
              final clinic = state.clinic;

              return CustomScrollView(
                slivers: [
                  // 1. APP BAR GAMBAR BESAR
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    stretch: true,
                    backgroundColor: Theme.of(context).primaryColor,
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(EvaIcons.arrowBack, color: Colors.black),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            clinic.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                                stops: const [0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. INFO KLINIK (Card Melengkung ke Atas)
                  SliverToBoxAdapter(
                    child: Container(
                      transform: Matrix4.translationValues(0, -20, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle Bar
                          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
                          const SizedBox(height: 24),

                          // Judul & Kategori
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(clinic.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                                child: const Text("Buka", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Alamat
                          Row(
                            children: [
                              const Icon(EvaIcons.pinOutline, color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(clinic.address, style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13))),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Info Box (Rating, Jarak, Jam)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfoBox(EvaIcons.star, "4.8", "Rating", Colors.orange),
                              _buildInfoBox(EvaIcons.navigation2Outline, "2.4 km", "Jarak", Colors.blue),
                              _buildInfoBox(EvaIcons.clockOutline, "08-21", "Jam Buka", Colors.purple),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          Text("Layanan Tersedia", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // 3. LIST LAYANAN
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildServiceCard(context, clinic.services[index], index),
                        childCount: clinic.services.length,
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

  Widget _buildInfoBox(IconData icon, String val, String label, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(val, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceEntity service, int index) {
    final clinic = (context.read<ClinicDetailCubit>().state as ClinicDetailLoaded).clinic;
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(EvaIcons.activityOutline, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                Text(currencyFormatter.format(service.price), style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => context.goNamed(
              BookingScreen.routeName,
              pathParameters: {'clinicId': clinic.id},
              extra: {'clinicId': clinic.id, 'clinicName': clinic.name, 'service': service}
            ),
            child: const Text('Book'),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, delay: (100 * index).ms);
  }
}