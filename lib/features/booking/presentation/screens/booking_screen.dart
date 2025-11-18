// lib/features/booking/presentation/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Animasi
import 'package:eva_icons_flutter/eva_icons_flutter.dart'; // Icon Keren
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/core/widgets/responsive_constraint_box.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';
import 'package:vetsy_app/features/home/presentation/screens/home_screen.dart';

class BookingScreen extends StatelessWidget {
  static const String routeName = 'booking';
  static const String routePath = 'book';

  final String clinicId;
  final String clinicName;
  final ServiceEntity service;

  const BookingScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<BookingCubit>()..fetchInitialData(),
      child: BookingView(
        clinicId: clinicId,
        clinicName: clinicName,
        service: service,
      ),
    );
  }
}

class BookingView extends StatelessWidget {
  final String clinicId;
  final String clinicName;
  final ServiceEntity service;

  const BookingView({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.service,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        // Kustomisasi warna DatePicker agar sesuai tema
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        context.read<BookingCubit>().state.selectedDate != picked) {
      context.read<BookingCubit>().onDateSelected(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null &&
        context.read<BookingCubit>().state.selectedTime != picked) {
      context.read<BookingCubit>().onTimeSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50], // Background bersih
      appBar: AppBar(
        title: const Text(
          'Konfirmasi Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ResponsiveConstraintBox(
        child: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state.status == BookingPageStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(EvaIcons.checkmarkCircle2, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Booking berhasil dibuat!'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              context.pop();
            } else if (state.status == BookingPageStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state.status == BookingPageStatus.loadingPets ||
                  state.status == BookingPageStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20.0), // Padding fixed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- 1. INFO LAYANAN CARD ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Layanan yang dipilih',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            service.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            clinicName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              currencyFormatter.format(service.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),

                    const SizedBox(height: 24),

                    // --- 2. PILIH HEWAN ---
                    const Text(
                      'Detail Pasien',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (state.pets.isEmpty)
                      _buildEmptyPetState(context)
                    else
                      DropdownButtonFormField<PetEntity>(
                        value: state.selectedPet,
                        hint: const Text('Pilih hewan peliharaan...'),
                        icon: const Icon(EvaIcons.arrowIosDownward),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(EvaIcons.githubOutline, // Icon hewan
                              color: Theme.of(context).primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        items: state.pets.map((pet) {
                          return DropdownMenuItem(
                            value: pet,
                            child: Text(
                              '${pet.name} (${pet.type})',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          );
                        }).toList(),
                        onChanged: (pet) {
                          if (pet != null) {
                            context.read<BookingCubit>().onPetSelected(pet);
                          }
                        },
                      ),

                    const SizedBox(height: 24),

                    // --- 3. PILIH WAKTU ---
                    const Text(
                      'Waktu Kunjungan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        // Input Tanggal
                        Expanded(
                          child: _buildSelectionCard(
                            context,
                            icon: EvaIcons.calendarOutline,
                            label: 'Tanggal',
                            value: state.selectedDate == null
                                ? 'Pilih Tanggal'
                                : DateFormat('d MMM yyyy', 'id_ID')
                                    .format(state.selectedDate!),
                            isSelected: state.selectedDate != null,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Input Jam
                        Expanded(
                          child: _buildSelectionCard(
                            context,
                            icon: EvaIcons.clockOutline,
                            label: 'Jam',
                            value: state.selectedTime == null
                                ? 'Pilih Jam'
                                : state.selectedTime!.format(context),
                            isSelected: state.selectedTime != null,
                            onTap: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // --- 4. TOMBOL KONFIRMASI ---
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                        ),
                        onPressed: (state.status == BookingPageStatus.submitting)
                            ? null
                            : () {
                                context.read<BookingCubit>().submitBooking(
                                      clinicId: clinicId,
                                      clinicName: clinicName,
                                      service: service,
                                    );
                              },
                        child: (state.status == BookingPageStatus.submitting)
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Konfirmasi Booking',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(EvaIcons.arrowForwardOutline),
                                ],
                              ),
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget Helper: Kartu Pemilihan Tanggal/Jam
  Widget _buildSelectionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black87 : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper: Jika belum ada hewan
  Widget _buildEmptyPetState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Row(
        children: [
          const Icon(EvaIcons.alertCircleOutline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Belum ada hewan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    // Navigasi manual ke Tab Hewan (Index 1)
                    homeScreenKey.currentState?.navigateToTab(1);
                    context.go(HomeScreen.route);
                  },
                  child: const Text(
                    'Tambah hewan sekarang →',
                    style: TextStyle(
                      color: Colors.red,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}