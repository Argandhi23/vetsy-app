import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';
import 'package:vetsy_app/features/pet/presentation/widgets/add_pet_form.dart';

class MyPetsScreen extends StatelessWidget {
  const MyPetsScreen({super.key});

  void _showPetFormModal(BuildContext context, {PetEntity? petToEdit}) {
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
          child: AddPetForm(petToEdit: petToEdit),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String petId, String petName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(EvaIcons.alertTriangleOutline, color: Colors.red),
              const SizedBox(width: 10),
              Text('Hapus $petName?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text('Data hewan yang dihapus tidak dapat dikembalikan.', style: GoogleFonts.poppins()),
          actions: <Widget>[
            TextButton(
              child: Text('Batal', style: GoogleFonts.poppins(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                context.read<MyPetsCubit>().deletePet(petId);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPetFormModal(context),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(EvaIcons.plus),
        label: Text("Tambah", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        elevation: 4,
      ),
      body: Column(
        children: [
          // 1. HEADER HALAMAN
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hewan Peliharaan",
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Text(
                      "Kelola data sahabat bulumu di sini",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pets, color: Colors.orange, size: 24),
                )
              ],
            ),
          ),

          // 2. LIST CONTENT
          Expanded(
            child: BlocConsumer<MyPetsCubit, MyPetsState>(
              listener: (context, state) {
                if (state.status == MyPetsStatus.error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage ?? 'Error'), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == MyPetsStatus.loading || state.status == MyPetsStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.pets.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 200),
                            child: Lottie.asset('assets/lottie/logo_splash.json', fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 24),
                          Text('Belum Ada Hewan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan hewan peliharaanmu sekarang.',
                            style: GoogleFonts.poppins(color: Colors.grey, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 80),
                  itemCount: state.pets.length,
                  itemBuilder: (context, index) {
                    final pet = state.pets[index];
                    return _buildPetCard(context, pet, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetEntity pet, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPetFormModal(context, petToEdit: pet),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Besar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.pets, size: 40, color: Colors.blue[700]),
              ),
              const SizedBox(width: 16),
              
              // Info Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          pet.name,
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(EvaIcons.trash2Outline, size: 20, color: Colors.redAccent),
                          onPressed: () => _showDeleteConfirmation(context, pet.id, pet.name),
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    Text("${pet.type} • ${pet.breed}", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13)),
                    
                    const SizedBox(height: 12),
                    
                    // Badges Umur & Berat
                    Row(
                      children: [
                        _buildInfoBadge(Icons.cake_outlined, "${pet.age} Bln", Colors.orange),
                        const SizedBox(width: 8),
                        _buildInfoBadge(Icons.monitor_weight_outlined, "${pet.weight} Kg", Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, delay: (100 * index).ms);
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}