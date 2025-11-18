// lib/features/booking/presentation/screens/booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
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
      appBar: AppBar(
        title: const Text('Konfirmasi Booking'),
      ),
      body: ResponsiveConstraintBox(
        child: BlocListener<BookingCubit, BookingState>(
          listener: (context, state) {
            if (state.status == BookingPageStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Booking berhasil dibuat!'),
                    backgroundColor: Colors.green),
              );
              context.pop();
            } else if (state.status == BookingPageStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.errorMessage ?? 'Terjadi kesalahan'),
                    backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<BookingCubit, BookingState>(
            builder: (context, state) {
              if (state.status == BookingPageStatus.loadingPets ||
                  state.status == BookingPageStatus.initial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == BookingPageStatus.error &&
                  state.pets.isEmpty) {
                return Center(child: Text(state.errorMessage ?? 'Error'));
              }
              return SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Layanan Dipesan:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 1.h),
                            Text(service.name,
                                style: TextStyle(fontSize: 18)),
                            Text(
                              currencyFormatter.format(service.price),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.green[700]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Pilih Hewan Peliharaan:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    if (state.pets.isEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Anda belum memiliki hewan.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.red),
                          ),
                          SizedBox(height: 1.h),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Hewan Dulu'),
                            onPressed: () {
                              homeScreenKey.currentState?.navigateToTab(1);
                              context.go(HomeScreen.route);
                            },
                          )
                        ],
                      )
                    else
                      DropdownButtonFormField<PetEntity>(
                        value: state.selectedPet,
                        hint: const Text('Pilih hewan...'),
                        decoration: const InputDecoration(
                            border: OutlineInputBorder()),
                        items: state.pets.map((pet) {
                          return DropdownMenuItem(
                            value: pet,
                            child: Text('${pet.name} (${pet.type})'),
                          );
                        }).toList(),
                        onChanged: (pet) {
                          if (pet != null) {
                            context.read<BookingCubit>().onPetSelected(pet);
                          }
                        },
                      ),
                    SizedBox(height: 3.h),
                    Text(
                      'Pilih Jadwal Booking:',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              state.selectedDate == null
                                  ? 'Pilih Tanggal'
                                  : DateFormat('d MMM yyyy')
                                      .format(state.selectedDate!),
                            ),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              state.selectedTime == null
                                  ? 'Pilih Jam'
                                  : state.selectedTime!.format(context),
                            ),
                            onPressed: () => _selectTime(context),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      
                      // ===== INI ADALAH PERBAIKANNYA =====
                      onPressed: (state.status == BookingPageStatus.submitting)
                          ? null // Jika submitting, tombol mati
                          : () { // Jika tidak, jalankan fungsi
                              context.read<BookingCubit>().submitBooking(
                                    clinicId: clinicId,
                                    clinicName: clinicName,
                                    service: service,
                                  );
                            },
                      // ===================================
                            
                      child: (state.status == BookingPageStatus.submitting)
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : Text('Konfirmasi Booking',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}