// lib/features/pet/presentation/screens/my_pets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/core/config/locator.dart';
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

  void _showDeleteConfirmation(
      BuildContext context, String petId, String petName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(EvaIcons.alertTriangleOutline, color: Colors.red),
              SizedBox(width: 10),
              Text('Hapus Hewan'),
            ],
          ),
          content: Text('Apakah Anda yakin ingin menghapus $petName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
      // PERBAIKAN 1: Samakan Background dengan MyBookingsScreen
      backgroundColor: Colors.grey[50], // Jangan Colors.white biasa
      
      floatingActionButton: Builder(
        builder: (ctx) => FloatingActionButton.extended(
          onPressed: () => _showPetFormModal(ctx),
          backgroundColor: Theme.of(context).primaryColor,
          icon: const Icon(EvaIcons.plus),
          label: const Text("Tambah Hewan"),
          elevation: 4,
        ),
      ),
      body: BlocListener<MyPetsCubit, MyPetsState>(
        listener: (context, state) {
          if (state.status == MyPetsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: BlocBuilder<MyPetsCubit, MyPetsState>(
          builder: (context, state) {
            // 1. LOADING
            if (state.status == MyPetsStatus.loading ||
                state.status == MyPetsStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. EMPTY STATE (Disesuaikan)
            if (state.status == MyPetsStatus.loaded && state.pets.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PERBAIKAN 2: Ukuran Lottie disamakan (maxWidth 200)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Lottie.asset(
                          'assets/lottie/logo_splash.json', 
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Belum Ada Hewan',
                        style: TextStyle(
                          fontSize: 18, // Ukuran font disamakan
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan hewan peliharaan kesayanganmu agar bisa mulai konsultasi.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn();
            }

            // 3. LIST DATA
            if (state.status == MyPetsStatus.loaded ||
                state.status == MyPetsStatus.submitting) {
              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: state.pets.length,
                    itemBuilder: (context, index) {
                      final pet = state.pets[index];
                      
                      return Card( // Gunakan Card agar shadow sama dengan Booking
                        elevation: 2,
                        shadowColor: Colors.black.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _showPetFormModal(context, petToEdit: pet),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // AVATAR HEWAN
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.pets, 
                                    color: Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // INFO TEXT
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${pet.type} • ${pet.breed}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // DELETE BUTTON
                                IconButton(
                                  icon: const Icon(
                                    EvaIcons.trash2Outline, 
                                    color: Colors.redAccent
                                  ),
                                  onPressed: () {
                                    _showDeleteConfirmation(
                                        context, pet.id, pet.name);
                                  },
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideX(begin: 0.1, delay: (100 * index).ms);
                    },
                  ),
                  
                  if (state.status == MyPetsStatus.submitting)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              );
            }
            return const Center(child: Text('Memuat data hewan...'));
          },
        ),
      ),
    );
  }
}