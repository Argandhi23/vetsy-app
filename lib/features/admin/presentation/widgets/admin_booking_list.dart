import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminBookingList extends StatelessWidget {
  final String clinicId;
  final String statusFilter; // 'Pending', 'InProgress', 'Completed'
  final String searchQuery;

  const AdminBookingList({
    super.key,
    required this.clinicId,
    required this.statusFilter,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('clinicId', isEqualTo: clinicId)
          .orderBy('scheduleDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data?.docs ?? [];

        final filteredDocs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          
          // [LOGIKA STATUS BARU]
          bool statusMatch = false;
          if (statusFilter == 'Completed') {
            statusMatch = ['Completed', 'Cancelled', 'Rejected'].contains(data['status']);
          } else if (statusFilter == 'InProgress') {
            // Support status lama 'Confirmed'
            statusMatch = ['Confirmed', 'InProgress'].contains(data['status']);
          } else {
            statusMatch = data['status'] == statusFilter; // 'Pending'
          }

          if (!statusMatch) return false;

          if (searchQuery.isEmpty) return true;
          
          final petName = (data['petName'] ?? '').toString().toLowerCase();
          final serviceName = (data['service']['name'] ?? '').toString().toLowerCase();
          return petName.contains(searchQuery.toLowerCase()) || 
                 serviceName.contains(searchQuery.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(EvaIcons.folderRemoveOutline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Tidak ada data", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;
            final bookingId = filteredDocs[index].id;
            
            final date = (data['scheduleDate'] as Timestamp).toDate();
            final dateStr = DateFormat('d MMM yyyy', 'id_ID').format(date);
            final timeStr = DateFormat('HH:mm').format(date);
            final grandTotal = (data['grandTotal'] ?? 0.0).toDouble();
            
            final paymentStatus = data['paymentStatus'] ?? 'Unpaid';
            final isPaid = paymentStatus == 'Paid';
            final isTransfer = (data['paymentMethod'] ?? '').toString().toLowerCase().contains('transfer');

            return _buildCard(context, data, bookingId, dateStr, timeStr, grandTotal, isPaid, isTransfer, currency, index);
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Map data, String id, String date, String time, double total, bool isPaid, bool isTransfer, NumberFormat currency, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // HEADER KARTU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(EvaIcons.calendarOutline, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 6),
                  Text("$date • $time", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isPaid ? "LUNAS" : "BELUM BAYAR", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
                )
              ],
            ),
          ),
          // BODY
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data['petName'] ?? 'Tanpa Nama', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(data['service']['name'], style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(currency.format(total), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green[700])),
                        Row(children: [
                          Icon(isTransfer ? Icons.account_balance : Icons.money, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(isTransfer ? "Transfer Bank" : "Tunai / COD", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                        ])
                      ]),
                    )
                  ]),
                ),
              ],
            ),
          ),
          // ACTIONS
          if (statusFilter != 'Completed')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  if (statusFilter == 'Pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(context, id, 'Rejected'), 
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), 
                        child: const Text("Tolak")
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        // [UBAH] Status jadi 'InProgress' (Dikerjakan)
                        onPressed: () => _updateStatus(context, id, 'InProgress'), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white), 
                        child: const Text("Kerjakan")
                      )
                    ),
                  ],
                  if (statusFilter == 'InProgress') ...[
                    if (!isPaid && isTransfer) ...[
                      Expanded(flex: 2, child: ElevatedButton.icon(onPressed: () => _updatePayment(context, id), icon: const Icon(Icons.check_circle_outline, size: 16), label: const Text("Cek Bayar"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white))),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      flex: 2, 
                      child: ElevatedButton.icon(
                        // [UBAH] Status jadi 'Completed'
                        onPressed: () => _updateStatus(context, id, 'Completed', autoPay: !isTransfer), 
                        icon: const Icon(EvaIcons.checkmarkCircle2Outline, size: 18), 
                        label: Text(isTransfer ? "Selesaikan" : "Selesai & Lunas"), 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white)
                      )
                    ),
                  ]
                ],
              ),
            )
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }

  // [FUNGSI UPDATE STATUS & NOTIFIKASI]
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus, {bool autoPay = false}) async {
    try {
      // 1. Update Status Booking
      Map<String, dynamic> data = {'status': newStatus};
      if (autoPay) data['paymentStatus'] = 'Paid';
      
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(data);

      // 2. [BARU] Buat Notifikasi untuk User (Root Collection)
      final bookingSnapshot = await FirebaseFirestore.instance.collection('bookings').doc(docId).get();
      if (bookingSnapshot.exists) {
        final bookingData = bookingSnapshot.data() as Map<String, dynamic>;
        final userId = bookingData['userId'];
        final petName = bookingData['petName'] ?? 'Hewan';
        final serviceName = bookingData['service']['name'] ?? 'Layanan';

        String title = "Status Booking Diperbarui";
        String body = "Status booking $serviceName untuk $petName berubah menjadi $newStatus.";

        // Custom Message
        if (newStatus == 'Confirmed' || newStatus == 'InProgress') {
          title = "Booking Diterima! 🏥";
          body = "Dokter sedang bersiap menangani $petName untuk layanan $serviceName.";
        } else if (newStatus == 'Completed') {
          title = "Layanan Selesai ✅";
          body = "Perawatan $petName sudah selesai. Terima kasih telah mempercayai kami!";
        } else if (newStatus == 'Cancelled' || newStatus == 'Rejected') {
          title = "Booking Dibatalkan ❌";
          body = "Mohon maaf, booking untuk $petName dibatalkan.";
        }

        // Simpan ke collection 'notifications'
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': userId, 
          'title': title,
          'body': body,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'type': 'booking_status',
          'bookingId': docId,
        });
      }

      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status diubah & Notifikasi dikirim!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _updatePayment(BuildContext context, String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({'paymentStatus': 'Paid'});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pembayaran diverifikasi!"), backgroundColor: Colors.green));
  }
}