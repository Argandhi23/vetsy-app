// lib/features/booking/presentation/screens/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/my_bookings/my_bookings_cubit.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MyBookingsCubit>(),
      child: BlocBuilder<MyBookingsCubit, MyBookingsState>(
        builder: (context, state) {
          if (state.status == MyBookingsStatus.loading || 
              state.status == MyBookingsStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MyBookingsStatus.loaded &&
              state.bookings.isEmpty) {
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
                      'Belum Ada Jadwal',
                      style: TextStyle(
                          // Ganti .sp menjadi statis
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Kamu belum pernah membuat booking. Mulai booking di tab Klinik!',
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

          if (state.status == MyBookingsStatus.loaded) {
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<MyBookingsCubit>().fetchMyBookings(),
              child: ListView.builder(
                padding: EdgeInsets.all(3.w),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      title: Text(
                        booking.service.name,
                        style: TextStyle(
                            // Ganti .sp menjadi statis
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${booking.clinicName} • ${booking.petName}\n${DateFormat('d MMMM yyyy, HH:mm').format(booking.scheduleDate)}',
                        // Ganti .sp menjadi statis
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        booking.status,
                        style: TextStyle(
                            // Ganti .sp menjadi statis
                            fontSize: 14,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            );
          }
          return const Center(child: Text('Memuat data booking...'));
        },
      ),
    );
  }
}