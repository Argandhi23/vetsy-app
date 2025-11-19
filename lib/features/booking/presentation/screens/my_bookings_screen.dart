import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN: Hapus BlocProvider lokal, langsung gunakan BlocBuilder.
    // Ini mencegah Cubit tertutup (closed) saat ganti tab/logout.
    return BlocBuilder<MyBookingsCubit, MyBookingsState>(
      builder: (context, state) {
        
        // 1. LOADING (SHIMMER)
        if (state.status == MyBookingsStatus.loading ||
            state.status == MyBookingsStatus.initial) {
          return _buildShimmerList();
        }

        // 2. KOSONG
        if (state.status == MyBookingsStatus.loaded &&
            state.bookings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox( // Fix ukuran agar tidak raksasa di Web
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Lottie.asset(
                      'assets/lottie/logo_splash.json', 
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum Ada Jadwal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jadwal konsultasi atau grooming hewanmu akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn();
        }

        // 3. ADA DATA
        if (state.status == MyBookingsStatus.loaded) {
          return RefreshIndicator(
            onRefresh: () =>
                context.read<MyBookingsCubit>().fetchMyBookings(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                
                // Format Tanggal Indonesia
                final String day = DateFormat('d').format(booking.scheduleDate);
                final String month = DateFormat('MMM', 'id_ID').format(booking.scheduleDate).toUpperCase();
                final String fullDate = DateFormat('EEEE, HH:mm', 'id_ID').format(booking.scheduleDate);

                return Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // KOTAK TANGGAL (Fixed Size agar aman di Web)
                        Container(
                          width: 65, 
                          height: 70,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              Text(
                                month,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // DETAIL TEXT
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      booking.service.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusChip(booking.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${booking.clinicName} • ${booking.petName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(EvaIcons.clockOutline, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    fullDate,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: 0.2, curve: Curves.easeOutQuad, delay: (100 * index).ms);
              },
            ),
          );
        }

        return const Center(child: Text('Memuat data...'));
      },
    );
  }

  Widget _buildShimmerList() => ListView.builder(padding: const EdgeInsets.all(16), itemCount: 5, itemBuilder: (context, index) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(margin: const EdgeInsets.only(bottom: 16), height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))));
  
  Widget _buildStatusChip(String status) {
    Color color; Color bg; String text = status;
    switch (status.toLowerCase()) {
      case 'completed': color = Colors.green[700]!; bg = Colors.green[50]!; break;
      case 'cancelled': color = Colors.red[700]!; bg = Colors.red[50]!; text = 'Dibatalkan'; break;
      default: color = Colors.orange[800]!; bg = Colors.orange[50]!; text = 'Menunggu';
    }
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)));
  }
}