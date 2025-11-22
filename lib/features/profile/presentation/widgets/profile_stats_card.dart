import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';

import 'package:vetsy_app/features/pet/presentation/cubit/my_pets_cubit.dart';


class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. TOTAL HEWAN (Ambil dari MyPetsCubit)
          BlocBuilder<MyPetsCubit, MyPetsState>(
            builder: (context, state) {
              final totalPets = state.pets.length;
              return _buildStatItem(
                context, 
                icon: EvaIcons.github, 
                label: "Hewan", 
                value: totalPets.toString(),
                color: Colors.orange,
              );
            },
          ),

          // Garis Pembatas Vertikal
          Container(height: 40, width: 1, color: Colors.grey[350]),

          // 2. BOOKING AKTIF & SELESAI (Ambil dari MyBookingsCubit)
          BlocBuilder<MyBookingsCubit, MyBookingsState>(
            builder: (context, state) {
              // Filter manual untuk menghitung jumlah
              final activeBookings = state.bookings.where((b) => 
                ['pending', 'confirmed'].contains(b.status.toLowerCase())
              ).length;
              
              final completedBookings = state.bookings.where((b) => 
                b.status.toLowerCase() == 'completed'
              ).length;

              return Row(
                children: [
                  _buildStatItem(
                    context,
                    icon: EvaIcons.clockOutline,
                    label: "Aktif",
                    value: activeBookings.toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 45), // Jarak antar item
                  
                  _buildStatItem(
                    context,
                    icon: EvaIcons.checkmarkCircle2Outline,
                    label: "Selesai",
                    value: completedBookings.toString(),
                    color: Colors.green,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required IconData icon, 
    required String label, 
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}