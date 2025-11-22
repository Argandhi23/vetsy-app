import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vetsy_app/features/clinic/data/models/service_model.dart';

class ManageServicesScreen extends StatelessWidget {
  final String clinicId;
  const ManageServicesScreen({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Kelola Layanan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // GANTI: Pakai Modal Bottom Sheet Modern
        onPressed: () => _showServiceSheet(context), 
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(EvaIcons.plus),
        label: Text("Tambah Layanan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clinics')
            .doc(clinicId)
            .collection('services')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final docs = snapshot.data?.docs ?? [];
          
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(EvaIcons.cubeOutline, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Belum ada layanan klinik", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final service = ServiceModel.fromFirestore(data);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
                    child: const Icon(EvaIcons.activityOutline, color: Colors.blue),
                  ),
                  title: Text(service.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(currency.format(service.price), style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.w600)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(EvaIcons.editOutline, color: Colors.orange),
                        onPressed: () => _showServiceSheet(context, service: service, docId: data.id),
                      ),
                      IconButton(
                        icon: const Icon(EvaIcons.trash2Outline, color: Colors.red),
                        onPressed: () => _deleteService(context, data.id),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
            },
          );
        },
      ),
    );
  }

  // --- [MODERN BOTTOM SHEET UI] ---
  void _showServiceSheet(BuildContext context, {ServiceModel? service, String? docId}) {
    final nameCtrl = TextEditingController(text: service?.name);
    final priceCtrl = TextEditingController(text: service?.price.toInt().toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            
            Text(
              service == null ? "Tambah Layanan Baru" : "Edit Layanan",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // INPUT NAMA
            Text("Nama Layanan", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: "Cth: Vaksin Rabies, Steril Kucing",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // INPUT HARGA
            Text("Harga (Rp)", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            const SizedBox(height: 8),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Cth: 150000",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixText: "Rp ",
              ),
            ),
            const SizedBox(height: 32),

            // TOMBOL SIMPAN
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text;
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  
                  if (name.isNotEmpty && price > 0) {
                    final collection = FirebaseFirestore.instance
                        .collection('clinics')
                        .doc(clinicId)
                        .collection('services');

                    if (service == null) {
                      await collection.add({'name': name, 'price': price});
                    } else {
                      await collection.doc(docId).update({'name': name, 'price': price});
                    }
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: Text("Simpan", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Layanan?"),
        content: const Text("Layanan ini tidak akan bisa dipilih user lagi."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('clinics')
                  .doc(clinicId)
                  .collection('services')
                  .doc(docId)
                  .delete();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}