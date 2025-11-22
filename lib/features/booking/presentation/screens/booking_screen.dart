import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/booking/presentation/screens/booking_confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  static const String routeName = 'booking';
  static const String routePath = 'booking';

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

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Buat Janji Temu", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(EvaIcons.arrowBack, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BookingCubit, BookingState>(
        builder: (context, state) {
          if (state.status == BookingPageStatus.loadingPets) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. INFO LAYANAN
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Icon(EvaIcons.activityOutline, color: Colors.blue[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(clinicName, style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(currencyFormatter.format(service.price), style: GoogleFonts.poppins(color: Colors.green[700], fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. PILIH HEWAN
                Text("1. Pilih Pasien", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (state.pets.isEmpty)
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                     child: const Text("Belum ada hewan. Tambahkan di menu Hewan."),
                   )
                else
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.pets.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final pet = state.pets[index];
                        final isSelected = state.selectedPet?.id == pet.id;
                        return GestureDetector(
                          onTap: () => context.read<BookingCubit>().onPetSelected(pet),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 90,
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade200,
                                width: 2
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.pets, color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                                const SizedBox(height: 8),
                                Text(pet.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 24),

                // 3. PILIH TANGGAL
                Text("2. Pilih Tanggal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && context.mounted) {
                      // [UPDATE] Panggil fungsi onDateSelected dengan clinicId untuk cek slot
                      context.read<BookingCubit>().onDateSelected(clinicId, picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(EvaIcons.calendarOutline, color: Colors.grey),
                        const SizedBox(width: 12),
                        Text(
                          state.selectedDate == null
                              ? "Tentukan Tanggal"
                              : DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(state.selectedDate!),
                          style: GoogleFonts.poppins(
                            color: state.selectedDate == null ? Colors.grey : Colors.black,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const Spacer(),
                        const Icon(EvaIcons.arrowIosDownward, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                // 4. PILIH JAM (GRID SYSTEM)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("3. Pilih Jam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    // Tampilkan loading spinner kecil saat sedang mengecek slot
                    if (state.status == BookingPageStatus.loadingSlots)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  ],
                ),
                const SizedBox(height: 12),

                if (state.selectedDate == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: Text("Silakan pilih tanggal terlebih dahulu.", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
                  )
                else
                  // --- [GRID SLOT JAM] ---
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _buildTimeSlots(context, state),
                  ),
                // -----------------------

                const SizedBox(height: 40),

                // TOMBOL LANJUT PEMBAYARAN
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (state.selectedPet == null || state.selectedDate == null || state.selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Harap pilih Hewan, Tanggal, dan Jam terlebih dahulu.")),
                        );
                        return;
                      }

                      context.pushNamed(
                        BookingConfirmationScreen.routeName,
                        extra: {
                          'clinicId': clinicId,
                          'clinicName': clinicName,
                          'service': service,
                          'pet': state.selectedPet!,
                          'date': state.selectedDate!,
                          'time': state.selectedTime!,
                        },
                      );
                    },
                    child: const Text("Lanjut ke Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- [HELPER: BUILD GRID SLOT] ---
  List<Widget> _buildTimeSlots(BuildContext context, BookingState state) {
    // Jam Operasional Hardcoded (Bisa diganti dinamis nanti)
    final List<TimeOfDay> operationalHours = [
      const TimeOfDay(hour: 9, minute: 0),
      const TimeOfDay(hour: 10, minute: 0),
      const TimeOfDay(hour: 11, minute: 0),
      const TimeOfDay(hour: 13, minute: 0), // Istirahat jam 12
      const TimeOfDay(hour: 14, minute: 0),
      const TimeOfDay(hour: 15, minute: 0),
      const TimeOfDay(hour: 16, minute: 0),
      const TimeOfDay(hour: 17, minute: 0),
    ];

    return operationalHours.map((time) {
      // Cek apakah jam ini ada di daftar sibuk (busyTimes)
      final isBooked = state.busyTimes.any((busy) => busy.hour == time.hour && busy.minute == time.minute);
      final isSelected = state.selectedTime?.hour == time.hour && state.selectedTime?.minute == time.minute;

      return InkWell(
        onTap: isBooked 
            ? null // Kalau penuh, disable klik
            : () => context.read<BookingCubit>().onTimeSelected(time),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 80, // Ukuran kotak
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isBooked 
                ? Colors.grey[300] // Abu-abu = Penuh
                : isSelected 
                    ? Theme.of(context).primaryColor // Biru = Dipilih
                    : Colors.white, // Putih = Tersedia
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Text(
                "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isBooked ? Colors.grey[500] : (isSelected ? Colors.white : Colors.black87),
                ),
              ),
              if (isBooked)
                Text("FULL", style: GoogleFonts.poppins(fontSize: 10, color: Colors.red[300], fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }).toList();
  }
}