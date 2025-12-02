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
          
          bool statusMatch = false;
          if (statusFilter == 'Completed') {
            statusMatch = ['Completed', 'Cancelled', 'Rejected'].contains(data['status']);
          } else if (statusFilter == 'InProgress') {
            statusMatch = ['Confirmed', 'InProgress'].contains(data['status']);
          } else {
            statusMatch = data['status'] == statusFilter;
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
                Icon(EvaIcons.inboxOutline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text("Tidak ada pesanan", style: GoogleFonts.poppins(color: Colors.grey)),
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
            return _buildAdminCard(context, data, bookingId, currency, index);
          },
        );
      },
    );
  }

  Widget _buildAdminCard(BuildContext context, Map data, String id, NumberFormat currency, int index) {
    final date = (data['scheduleDate'] as Timestamp).toDate();
    final dateStr = DateFormat('d MMM yyyy', 'id_ID').format(date);
    final timeStr = DateFormat('HH:mm').format(date);
    final grandTotal = (data['grandTotal'] ?? 0.0).toDouble();
    final paymentStatus = data['paymentStatus'] ?? 'Unpaid';
    final isPaid = paymentStatus == 'Paid';
    final isTransfer = (data['paymentMethod'] ?? '').toString().toLowerCase().contains('transfer');

    // Tentukan Warna Berdasarkan Status Tab
    Color statusColor = Colors.grey;
    if (statusFilter == 'Pending') statusColor = Colors.orange;
    if (statusFilter == 'InProgress') statusColor = Colors.blue;
    if (statusFilter == 'Completed') statusColor = data['status'] == 'Completed' ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight( // Agar tinggi garis mengikuti konten
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. GARIS WARNA INDIKATOR (KIRI)
              Container(
                width: 6,
                color: statusColor,
              ),

              // 2. KONTEN KARTU
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER: Waktu & ID
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(EvaIcons.clockOutline, size: 16, color: statusColor),
                              const SizedBox(width: 6),
                              Text(
                                "$dateStr • $timeStr", 
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])
                              ),
                            ],
                          ),
                          // Badge Pembayaran Kecil
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPaid ? "LUNAS" : "UNPAID",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // BODY: Pasien & Layanan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Foto/Icon Pasien
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.pets, color: Theme.of(context).primaryColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          
                          // Detail Teks
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['petName'] ?? 'Tanpa Nama',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                Text(
                                  data['service']['name'],
                                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currency.format(grandTotal),
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // FOOTER: Tombol Aksi (Hanya jika belum selesai)
                      if (statusFilter != 'Completed') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            // PENDING ACTIONS
                            if (statusFilter == 'Pending') ...[
                              Expanded(
                                child: _buildActionButton(
                                  context, 
                                  "Tolak", 
                                  Colors.red, 
                                  EvaIcons.close, 
                                  () => _updateStatus(context, id, 'Rejected')
                                )
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  context, 
                                  "Kerjakan", 
                                  Colors.blue, 
                                  EvaIcons.arrowRight, 
                                  () => _updateStatus(context, id, 'InProgress'),
                                  isFilled: true
                                )
                              ),
                            ],

                            // PROGRESS ACTIONS
                            if (statusFilter == 'InProgress') ...[
                              if (!isPaid && isTransfer) ...[
                                Expanded(
                                  child: _buildActionButton(
                                    context, 
                                    "Cek Bayar", 
                                    Colors.orange, 
                                    EvaIcons.creditCard, 
                                    () => _updatePayment(context, id)
                                  )
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: _buildActionButton(
                                  context, 
                                  "Selesai", 
                                  Colors.green, 
                                  EvaIcons.checkmark, 
                                  () => _updateStatus(context, id, 'Completed', autoPay: !isTransfer),
                                  isFilled: true
                                )
                              ),
                            ]
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }

  // Helper Widget untuk Tombol Konsisten
  Widget _buildActionButton(BuildContext context, String label, Color color, IconData icon, VoidCallback onTap, {bool isFilled = false}) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFilled ? color : Colors.white,
        foregroundColor: isFilled ? Colors.white : color,
        side: isFilled ? null : BorderSide(color: color),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // LOGIC UPDATE (Sama seperti sebelumnya)
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus, {bool autoPay = false}) async {
    try {
      Map<String, dynamic> data = {'status': newStatus};
      if (autoPay) data['paymentStatus'] = 'Paid';
      
      await FirebaseFirestore.instance.collection('bookings').doc(docId).update(data);

      final bookingSnapshot = await FirebaseFirestore.instance.collection('bookings').doc(docId).get();
      if (bookingSnapshot.exists) {
        final bookingData = bookingSnapshot.data() as Map<String, dynamic>;
        final userId = bookingData['userId'];
        final petName = bookingData['petName'] ?? 'Hewan';
        final serviceName = bookingData['service']['name'] ?? 'Layanan';

        String title = "Status Booking Diperbarui";
        String body = "Status booking $serviceName untuk $petName berubah menjadi $newStatus.";

        if (newStatus == 'Confirmed' || newStatus == 'InProgress') {
          title = "Booking Diterima! 🏥";
          body = "Dokter sedang bersiap menangani $petName untuk layanan $serviceName.";
        } else if (newStatus == 'Completed') {
          title = "Layanan Selesai ✅";
          body = "Perawatan $petName sudah selesai. Terima kasih!";
        } else if (newStatus == 'Cancelled' || newStatus == 'Rejected') {
          title = "Booking Dibatalkan ❌";
          body = "Mohon maaf, booking untuk $petName dibatalkan.";
        }

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
          SnackBar(content: Text("Status diubah jadi $newStatus"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _updatePayment(BuildContext context, String id) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({'paymentStatus': 'Paid'});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pembayaran diverifikasi!"), backgroundColor: Colors.green));
  }
}