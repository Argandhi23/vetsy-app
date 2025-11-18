// lib/features/pet/presentation/screens/my_pets_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<MyPetsCubit>(context),
        child: AddPetForm(petToEdit: petToEdit),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String petId, String petName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Hewan'),
          content: Text('Apakah Anda yakin ingin menghapus $petName?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                context.read<MyPetsCubit>().deletePet(petId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyPetsCubit>(),
      child: Scaffold(
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            onPressed: () => _showPetFormModal(ctx),
            child: const Icon(Icons.add),
            tooltip: 'Tambah Hewan',
          ),
        ),
        body: BlocListener<MyPetsCubit, MyPetsState>(
          listener: (context, state) {
            if (state.status == MyPetsStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<MyPetsCubit, MyPetsState>(
            builder: (context, state) {
              if (state.status == MyPetsStatus.loading ||
                  state.status == MyPetsStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == MyPetsStatus.loaded && state.pets.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60.w,
                          height: 60.w,
                          child: Lottie.asset(
                            'assets/lottie/logo_splash.json',
                            width: 60.w,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Anda belum punya hewan',
                          style: TextStyle(
                              // Ganti .sp menjadi statis
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Klik tombol + di bawah untuk menambah hewan peliharaan pertamamu.',
                          style: TextStyle(
                            // Ganti .sp menjadi statis
                            fontSize: 14,
                            color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.status == MyPetsStatus.loaded ||
                  state.status == MyPetsStatus.submitting) {
                return Stack(
                  children: [
                    ListView.builder(
                      padding: EdgeInsets.all(3.w),
                      itemCount: state.pets.length,
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.pets,
                                color: Colors.blueAccent),
                            title: Text(pet.name,
                                style: TextStyle(
                                    // Ganti .sp menjadi statis
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${pet.type} - ${pet.breed}',
                              // Ganti .sp menjadi statis
                              style: TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              _showPetFormModal(context, petToEdit: pet);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(
                                    context, pet.id, pet.name);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    if (state.status == MyPetsStatus.submitting)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child:
                            const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              }
              return const Center(child: Text('Memuat data hewan...'));
            },
          ),
        ),
      ),
    );
  }
}