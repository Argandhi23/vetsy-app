import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_detail_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan BlocProvider agar Cubit tersedia di tree widget ini
    return BlocProvider(
      create: (context) => sl<MyBookingsCubit>()..fetchMyBookings(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Jadwal Saya",
              style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            bottom: TabBar(
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Aktif"),
                Tab(text: "Riwayat"),
              ],
            ),
          ),
          // Gunakan BlocConsumer untuk mendengarkan perubahan state & error
          body: BlocConsumer<MyBookingsCubit, MyBookingsState>(
            listener: (context, state) {
              // Jika ada error (misal: gagal cancel karena < 2 jam), munculkan SnackBar Merah
              if (state.status == MyBookingsStatus.error && state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.status == MyBookingsStatus.loading && state.bookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = state.bookings;
              
              // Filter data untuk Tab
              final activeList = bookings.where((b) => ['Pending', 'Confirmed', 'Paid', 'Unpaid'].contains(b.status)).toList();
              final historyList = bookings.where((b) => ['Completed', 'Cancelled', 'Rejected'].contains(b.status)).toList();

              return TabBarView(
                children: [
                  _buildBookingList(context, activeList, isActive: true),
                  _buildBookingList(context, historyList, isActive: false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<BookingEntity> bookings, {required bool isActive}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? EvaIcons.calendarOutline : EvaIcons.clockOutline,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isActive ? "Tidak ada jadwal aktif" : "Belum ada riwayat",
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MyBookingsCubit>().fetchMyBookings(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          
          final String day = DateFormat('d').format(booking.scheduleDate);
          final String month = DateFormat('MMM', 'id_ID').format(booking.scheduleDate).toUpperCase();
          final String time = DateFormat('HH:mm').format(booking.scheduleDate);
          final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.pushNamed(BookingDetailScreen.routeName, extra: booking),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- [KOTAK TANGGAL] ---
                        Column(
                          children: [
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[100],
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Column(
                                children: [
                                  Text(day, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: isActive ? Theme.of(context).primaryColor : Colors.grey)),
                                  Text(month, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: isActive ? Theme.of(context).primaryColor : Colors.grey)),
                                ],
                              ),
                            ),
                            Container(
                              width: 60,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              ),
                              child: Text(
                                time, 
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(width: 16),

                        // --- [INFO DETAIL] ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.service.name,
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${booking.clinicName ?? '-'} • ${booking.petName}",
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    currency.format(booking.grandTotal),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13, 
                                      fontWeight: FontWeight.bold, 
                                      color: Theme.of(context).primaryColor
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (booking.paymentStatus == 'Unpaid' && booking.status != 'Cancelled')
                                    _buildSmallTag("Belum Bayar", Colors.orange)
                                  else if (booking.paymentStatus == 'Paid')
                                    _buildSmallTag("Lunas", Colors.green)
                                ],
                              )
                            ],
                          ),
                        ),

                        // --- [STATUS BOOKING] ---
                        _buildStatusBadge(booking.status),
                      ],
                    ),

                    // --- [TOMBOL BATALKAN] ---
                    // Hanya muncul jika status Pending/Confirmed
                    if (booking.status == 'Pending' || booking.status == 'Confirmed') ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => _showCancelDialog(context, booking),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(EvaIcons.closeCircleOutline, size: 14, color: Colors.red),
                                const SizedBox(width: 4),
                                Text(
                                  "Batalkan Jadwal",
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context, BookingEntity booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Batalkan Janji Temu?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          "Apakah Anda yakin ingin membatalkan jadwal ini?\n\nSyarat: Pembatalan hanya dapat dilakukan maksimal 2 jam sebelum jadwal dimulai.",
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text("Kembali", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              // Panggil fungsi cancel di Cubit
              context.read<MyBookingsCubit>().cancelBooking(booking);
            },
            child: Text("Ya, Batalkan", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5)
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'Confirmed': color = Colors.blue; label = 'Diterima'; break;
      case 'Completed': color = Colors.green; label = 'Selesai'; break;
      case 'Cancelled': color = Colors.red; label = 'Batal'; break;
      case 'Rejected': color = Colors.red; label = 'Ditolak'; break;
      default: color = Colors.orange; label = 'Menunggu';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          status == 'Completed' ? EvaIcons.checkmarkCircle2 : 
          (status == 'Cancelled' || status == 'Rejected') ? EvaIcons.closeCircle : EvaIcons.loaderOutline,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}