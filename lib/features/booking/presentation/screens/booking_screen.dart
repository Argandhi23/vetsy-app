import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

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
      body: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state.status == BookingPageStatus.success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(EvaIcons.checkmarkCircle2, color: Colors.green, size: 80),
                    const SizedBox(height: 16),
                    Text("Booking Berhasil!", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Jadwalmu sudah tercatat.", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.pop();
                        },
                        child: const Text("Kembali"),
                      ),
                    )
                  ],
                ),
              ),
            );
          } else if (state.status == BookingPageStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Error")));
          }
        },
        builder: (context, state) {
          if (state.status == BookingPageStatus.loadingPets || state.status == BookingPageStatus.submitting) {
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
                      context.read<BookingCubit>().onDateSelected(picked);
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

                // 4. PILIH JAM (FLEKSIBEL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("3. Pilih Jam", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                    if(state.selectedDate == null)
                      Text("*Pilih tanggal dulu", style: GoogleFonts.poppins(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic)),
                  ],
                ),
                const SizedBox(height: 12),

                // TOMBOL JAM FLEKSIBEL
                Opacity(
                  opacity: state.selectedDate == null ? 0.5 : 1.0,
                  child: InkWell(
                    onTap: state.selectedDate == null 
                        ? null 
                        : () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Theme.of(context).primaryColor,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            
                            if (pickedTime != null && context.mounted) {
                              context.read<BookingCubit>().onTimeSelected(pickedTime);
                            }
                          },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.selectedTime != null ? Theme.of(context).primaryColor : Colors.grey.shade200,
                          width: state.selectedTime != null ? 1.5 : 1.0
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(EvaIcons.clockOutline, color: state.selectedTime != null ? Theme.of(context).primaryColor : Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            state.selectedTime == null
                                ? "Tentukan Jam Kunjungan"
                                : "${state.selectedTime!.hour.toString().padLeft(2, '0')}:${state.selectedTime!.minute.toString().padLeft(2, '0')}",
                            style: GoogleFonts.poppins(
                              color: state.selectedTime == null ? Colors.grey : Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Ubah", 
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // TOMBOL KONFIRMASI
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
                      context.read<BookingCubit>().submitBooking(
                        clinicId: clinicId,
                        clinicName: clinicName,
                        service: service,
                      );
                    },
                    child: const Text("Konfirmasi Booking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}