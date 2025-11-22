import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:vetsy_app/core/config/locator.dart';
import 'package:vetsy_app/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:vetsy_app/features/clinic/domain/entities/service_entity.dart';
import 'package:vetsy_app/features/pet/domain/entities/pet_entity.dart';

class BookingConfirmationScreen extends StatefulWidget {
  static const String routeName = 'booking-confirmation';

  final String clinicId;
  final String clinicName;
  final ServiceEntity service;
  final PetEntity pet;
  final DateTime date;
  final TimeOfDay time;

  const BookingConfirmationScreen({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.service,
    required this.pet,
    required this.date,
    required this.time,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final TextEditingController _promoController = TextEditingController();
  
  late double _servicePrice;
  double _adminFee = 2000;
  double _discount = 0;
  String _paymentMethod = "Tunai di Klinik"; 

  @override
  void initState() {
    super.initState();
    _servicePrice = widget.service.price;
  }

  void _applyPromo() {
    if (_promoController.text.trim().toUpperCase() == "VETSYNEW20") {
      setState(() {
        _discount = _servicePrice * 0.20;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode promo berhasil digunakan!"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode promo tidak valid"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final double grandTotal = (_servicePrice + _adminFee) - _discount;

    return BlocProvider(
      create: (context) => sl<BookingCubit>(),
      child: BlocConsumer<BookingCubit, BookingState>(
        listener: (context, state) {
          // [FIX 1] Handle Success (Tetap Sama)
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
                    Text("Silakan cek status di menu Jadwal.", style: GoogleFonts.poppins(color: Colors.grey), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/home'), 
                        child: const Text("Selesai"),
                      ),
                    )
                  ],
                ),
              ),
            );
          } 
          // [FIX 2] Handle Error (Disempurnakan untuk Race Condition)
          else if (state.status == BookingPageStatus.error) {
            // Cek apakah errornya karena slot penuh (pesan dari backend tadi)
            final bool isSlotTaken = state.errorMessage?.contains("diambil pengguna lain") ?? false;

            showDialog(
              context: context,
              barrierDismissible: false, // User harus klik tombol OK
              builder: (ctx) => AlertDialog(
                title: Text("Booking Gagal", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red)),
                content: Text(
                  state.errorMessage ?? "Terjadi kesalahan sistem.",
                  style: GoogleFonts.poppins(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Tutup dialog
                      // Jika slot sudah diambil orang, kembalikan user ke layar sebelumnya untuk pilih jam lain
                      if (isSlotTaken) {
                        context.pop(); 
                      }
                    },
                    child: const Text("OK, Pilih Jam Lain"),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          // Tampilkan Loading Full Screen saat submit
          if (state.status == BookingPageStatus.submitting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text("Konfirmasi & Bayar", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Rincian Layanan"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildRow("Klinik", widget.clinicName),
                        _buildRow("Layanan", widget.service.name),
                        _buildRow("Pasien", widget.pet.name),
                        _buildRow("Jadwal", "${DateFormat('dd MMM yyyy').format(widget.date)} • ${widget.time.format(context)}"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Metode Pembayaran"),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        RadioListTile(
                          value: "Tunai di Klinik",
                          groupValue: _paymentMethod,
                          onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                          title: Text("Tunai di Klinik", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          subtitle: Text("Bayar saat tindakan selesai", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          secondary: const Icon(Icons.money, color: Colors.green),
                        ),
                        const Divider(height: 1),
                        RadioListTile(
                          value: "Transfer Bank",
                          groupValue: _paymentMethod,
                          onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                          title: Text("Transfer Bank", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                          subtitle: Text("Verifikasi manual oleh admin", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          secondary: const Icon(Icons.account_balance, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Kode Promo"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: InputDecoration(
                            hintText: "Masukkan kode VETSYNEW20",
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _applyPromo,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text("Pakai"),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Rincian Pembayaran"),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _buildPriceRow("Harga Layanan", currency.format(_servicePrice)),
                        _buildPriceRow("Biaya Aplikasi", currency.format(_adminFee)),
                        if (_discount > 0)
                          _buildPriceRow("Diskon Promo", "- ${currency.format(_discount)}", isDiscount: true),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Bayar", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(currency.format(grandTotal), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<BookingCubit>().submitBooking(
                          clinicId: widget.clinicId,
                          clinicName: widget.clinicName,
                          service: widget.service,
                          totalPrice: _servicePrice,
                          adminFee: _adminFee,
                          discountAmount: _discount,
                          grandTotal: grandTotal,
                          paymentMethod: _paymentMethod,
                          selectedPet: widget.pet,
                          selectedDate: widget.date,
                          selectedTime: widget.time,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text("Bayar & Konfirmasi", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[700])),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.grey)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.black87)),
          Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isDiscount ? Colors.red : Colors.black87)),
        ],
      ),
    );
  }
}