import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:vetsy_app/features/booking/data/models/booking_model.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_detail_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text("Silakan login kembali"));
    }

    return DefaultTabController(
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .orderBy('scheduleDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            
            final activeList = docs.where((d) => ['Pending', 'Confirmed'].contains(d['status'])).toList();
            final historyList = docs.where((d) => ['Completed', 'Cancelled'].contains(d['status'])).toList();

            return TabBarView(
              children: [
                _buildBookingList(context, activeList, isActive: true),
                _buildBookingList(context, historyList, isActive: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<QueryDocumentSnapshot> docs, {required bool isActive}) {
    if (docs.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final booking = BookingModel.fromFirestore(docs[index]);
        
        final String day = DateFormat('d').format(booking.scheduleDate);
        final String month = DateFormat('MMM', 'id_ID').format(booking.scheduleDate).toUpperCase();
        final String time = DateFormat('HH:mm').format(booking.scheduleDate);

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
            onTap: () => context.goNamed(BookingDetailScreen.routeName, extra: booking),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // KOTAK TANGGAL & JAM (Disatukan agar menonjol)
                  Column(
                    children: [
                      Container(
                        width: 65,
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
                      // JAM (Ditaruh di bawah tanggal dengan blok warna beda)
                      Container(
                        width: 65,
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

                  // INFO TENGAH
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
                          "${booking.clinicName} • ${booking.petName}",
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // STATUS KANAN
                  _buildStatusBadge(booking.status),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'Confirmed': color = Colors.blue; label = 'Diterima'; break;
      case 'Completed': color = Colors.green; label = 'Selesai'; break;
      case 'Cancelled': color = Colors.red; label = 'Batal'; break;
      default: color = Colors.orange; label = 'Menunggu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}