import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vetsy_app/features/pet/data/models/medical_record_model.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';
import 'package:vetsy_app/features/pet/presentation/widgets/add_pet_form.dart';

class PetDetailScreen extends StatelessWidget {
  final PetEntity pet;
  const PetDetailScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(pet.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(EvaIcons.editOutline, color: Colors.black),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: BlocProvider.value(
                    value: BlocProvider.of<MyPetsCubit>(context),
                    child: AddPetForm(petToEdit: pet),
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          // 1. HEADER INFO (Tanpa ImageURL, pakai Icon Default)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                // Avatar Default Besar & Cantik
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.1), width: 4),
                    boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
                  ),
                  child: Icon(
                    pet.type == 'Kucing' ? EvaIcons.github : EvaIcons.heart, 
                    size: 50, 
                    color: Colors.blue
                  ),
                ),
                const SizedBox(height: 16),
                Text(pet.name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text("${pet.breed} • ${pet.age} Bulan", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(EvaIcons.activityOutline, "${pet.weight} Kg", Colors.orange),
                    const SizedBox(width: 12),
                    _buildBadge(EvaIcons.pricetagsOutline, pet.type, Colors.blue),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // 2. TOMBOL CATAT & JUDUL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Buku Kesehatan", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                
                // Tombol Catat Modern
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAddRecordDialog(context, pet.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(EvaIcons.plusCircleOutline, size: 18, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 6),
                          Text("Catat Baru", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),

          // 3. LIST RIWAYAT
          Expanded(
            child: StreamBuilder<List<MedicalRecordModel>>(
              stream: context.read<MyPetsCubit>().getMedicalRecords(pet.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // EMPTY STATE
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 10)]),
                          child: Icon(EvaIcons.folderRemoveOutline, size: 40, color: Colors.grey[300]),
                        ),
                        const SizedBox(height: 12),
                        Text("Belum ada catatan medis", style: GoogleFonts.poppins(color: Colors.grey[500], fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                final records = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(20),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(EvaIcons.fileTextOutline, color: Colors.blue),
                        ),
                        title: Text(record.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(record.notes, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600], height: 1.4)),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(dateFormat.format(record.date), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text("Tanggal", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  // === DIALOG INPUT MODERN ===
  void _showAddRecordDialog(BuildContext context, String petId) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Catatan",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(
            opacity: anim1,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 10,
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                        child: const Icon(EvaIcons.edit2Outline, color: Colors.blue, size: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Center(
                      child: Text(
                        "Tambah Catatan",
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input Judul
                    Text("Judul", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleCtrl,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        hintText: "Cth: Vaksin Rabies",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // Input Keterangan
                    Text("Keterangan", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        hintText: "Tulis kondisi kesehatan atau catatan penting...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              foregroundColor: Colors.grey[600],
                            ),
                            child: Text("Batal", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (titleCtrl.text.isNotEmpty) {
                                context.read<MyPetsCubit>().addMedicalRecord(
                                  petId: petId,
                                  title: titleCtrl.text,
                                  notes: notesCtrl.text,
                                  date: DateTime.now(),
                                );
                                Navigator.pop(ctx);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Simpan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}