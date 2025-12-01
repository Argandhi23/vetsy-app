import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vetsy_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:vetsy_app/features/payment/presentation/cubit/payment_state.dart';

class AdminBookingList extends StatelessWidget {
  final String clinicId;
  final String statusFilter;
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

    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
        } else if (state is PaymentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${state.error}"), backgroundColor: Colors.red),
          );
        }
      },
      child: StreamBuilder<QuerySnapshot>(
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

          // FILTER DATA
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
            return Center(child: Text("Tidak ada data", style: GoogleFonts.poppins(color: Colors.grey)));
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
              final isPaid = data['paymentStatus'] == 'Paid';
              final isTransfer = (data['paymentMethod'] ?? '').toString().toLowerCase().contains('transfer');

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("$dateStr • $timeStr", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)
                            ),
                            child: Text(isPaid ? "LUNAS" : "BELUM BAYAR", 
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.orange)),
                          ),
                        ],
                      ),
                    ),
                    // Body
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(data['petName'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(data['service']['name'] ?? '-', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text(currency.format(grandTotal), style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                      ]),
                    ),
                    // Actions
                    if (statusFilter != 'Completed')
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            if (statusFilter == 'Pending') ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => context.read<PaymentCubit>().confirmPaymentAndBooking(bookingId, 'Rejected'), 
                                  child: const Text("Tolak"),
                                )
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => context.read<PaymentCubit>().confirmPaymentAndBooking(bookingId, 'InProgress'), 
                                  child: const Text("Kerjakan"),
                                )
                              ),
                            ],
                            if (statusFilter == 'InProgress') ...[
                              if (!isPaid && isTransfer) ...[
                                Expanded(flex: 2, child: ElevatedButton.icon(
                                  onPressed: () => context.read<PaymentCubit>().confirmPaymentAndBooking(bookingId, 'InProgress', autoPay: true), // Cek bayar manual
                                  icon: const Icon(Icons.check_circle_outline, size: 16), 
                                  label: const Text("Verif Bayar"), 
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white)
                                )),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  // [TOMBOL SELESAI] -> MEMANGGIL CUBIT
                                  onPressed: () {
                                    context.read<PaymentCubit>().confirmPaymentAndBooking(bookingId, 'Completed', autoPay: true);
                                  }, 
                                  icon: const Icon(EvaIcons.checkmarkCircle2Outline), 
                                  label: const Text("Selesai & Lunas"),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                )
                              ),
                            ]
                          ],
                        ),
                      )
                  ],
                ),
              ).animate().fadeIn();
            },
          );
        },
      ),
    );
  }
}