import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetsy_app/features/booking/domain/entities/booking_entity.dart';
import 'package:vetsy_app/features/clinic/presentation/widgets/add_review_dialog.dart';

class BookingDetailScreen extends StatelessWidget {
  static const String routeName = 'booking-detail';
  final BookingEntity booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final String fullDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(booking.scheduleDate);
    final String time = DateFormat('HH:mm').format(booking.scheduleDate);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(EvaIcons.arrowBack, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detail Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- KARTU TIKET ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  // HEADER TIKET
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1, style: BorderStyle.solid)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("ID Booking", style: TextStyle(color: Colors.grey)),
                        Text(
                          "#${booking.id.substring(0, 8).toUpperCase()}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  
                  // ISI TIKET
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildStatusIcon(context, booking.status),
                        const SizedBox(height: 16),
                        Text(
                          booking.service.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.clinicName ?? '-',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        
                        const Divider(thickness: 1, height: 30, color: Colors.grey),
                        
                        _buildDetailRow("Pasien", booking.petName ?? '-'),
                        _buildDetailRow("Tanggal", fullDate),
                        _buildDetailRow("Jam", time),
                        _buildDetailRow("Harga", currencyFormatter.format(booking.service.price)),
                        
                        const SizedBox(height: 24),
                        // Barcode Palsu
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              "||| || |||| ||| || ||||",
                              style: TextStyle(fontSize: 30, color: Colors.black26, fontWeight: FontWeight.w100, letterSpacing: 4),
                            ),
                          ),
                        ),
                         const SizedBox(height: 8),
                        const Text("Tunjukkan ini di resepsionis", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, duration: 500.ms).fadeIn(),

            // --- TOMBOL ULASAN (Update: Pakai BottomSheet) ---
            if (booking.status.toLowerCase() == 'completed') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // MENGGUNAKAN SHOW MODAL BOTTOM SHEET (MODERN)
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Agar bisa full height saat keyboard muncul
                        backgroundColor: Colors.transparent, // Agar rounded corner terlihat
                        builder: (context) => AddReviewDialog(
                          clinicId: booking.clinicId,
                          userId: user.uid,
                          username: user.displayName ?? 'Pengguna Vetsy',
                        ),
                      );
                    }
                  },
                  icon: const Icon(EvaIcons.star, color: Colors.white),
                  label: const Text("Beri Ulasan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: Colors.amber.withOpacity(0.4),
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            ],
            // ------------------------------------------------
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, String status) {
    IconData icon;
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'completed':
        icon = EvaIcons.checkmarkCircle2;
        color = Colors.green;
        text = "Selesai";
        break;
      case 'cancelled':
        icon = EvaIcons.closeCircle;
        color = Colors.red;
        text = "Dibatalkan";
        break;
      default:
        icon = EvaIcons.clock;
        color = Colors.orange;
        text = "Menunggu Konfirmasi";
    }

    return Column(
      children: [
        Icon(icon, size: 60, color: color),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}