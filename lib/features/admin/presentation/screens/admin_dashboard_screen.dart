import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/admin/presentation/screens/manage_services_screen.dart';
import 'package:vetsy_app/features/admin/presentation/widgets/admin_booking_list.dart';
import 'package:vetsy_app/features/admin/presentation/widgets/admin_stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const String route = '/admin';
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        String? clinicId;
        if (state is Authenticated) clinicId = state.clinicId;

        if (clinicId == null) {
          return _buildErrorState(context);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // Background abu kebiruan modern
          body: Column(
            children: [
              // HEADER & STATISTIK
              _buildHeaderSection(context, clinicId),

              // TAB BAR & CONTENT
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildModernTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          AdminBookingList(clinicId: clinicId, statusFilter: 'Pending', searchQuery: _searchQuery),
                          AdminBookingList(clinicId: clinicId, statusFilter: 'InProgress', searchQuery: _searchQuery),
                          AdminBookingList(clinicId: clinicId, statusFilter: 'Completed', searchQuery: _searchQuery),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS ---

  Widget _buildHeaderSection(BuildContext context, String clinicId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('clinicId', isEqualTo: clinicId)
          .snapshots(),
      builder: (context, snapshot) {
        int pending = 0, process = 0, done = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          pending = docs.where((d) => d['status'] == 'Pending').length;
          process = docs.where((d) => ['InProgress', 'Confirmed'].contains(d['status'])).length;
          done = docs.where((d) => ['Completed', 'Cancelled', 'Rejected'].contains(d['status'])).length;
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            children: [
              // Top Bar: Welcome & Logout
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Dashboard Admin", style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500)),
                    Text("Ringkasan Klinik", style: GoogleFonts.poppins(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold)),
                  ]),
                  Container(
                    decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
                    child: IconButton(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(EvaIcons.logOutOutline, color: Colors.red),
                      tooltip: 'Logout',
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.poppins(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Cari booking, pasien, layanan...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                    prefixIcon: const Icon(EvaIcons.searchOutline, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(icon: const Icon(EvaIcons.close, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Stat Cards
              Row(children: [
                Expanded(child: AdminStatCard(label: "Menunggu", value: "$pending", color: Colors.orange, icon: EvaIcons.loaderOutline)),
                const SizedBox(width: 12),
                Expanded(child: AdminStatCard(label: "Dikerjakan", value: "$process", color: Colors.blue, icon: EvaIcons.activityOutline)),
                const SizedBox(width: 12),
                Expanded(child: AdminStatCard(label: "Selesai", value: "$done", color: Colors.green, icon: EvaIcons.checkmarkCircle2Outline)),
              ]),

              const SizedBox(height: 16),

              // Tombol Kelola Layanan (WARNA DIPERBAIKI)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageServicesScreen(clinicId: clinicId))),
                  icon: const Icon(EvaIcons.settings2Outline, size: 18),
                  label: const Text("Atur Layanan & Harga"),
                  style: ElevatedButton.styleFrom(
                    // [PERBAIKAN] Menggunakan Primary Color (Biru)
                    backgroundColor: Theme.of(context).primaryColor, 
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4, // Tambah sedikit elevasi biar menonjol
                    shadowColor: Theme.of(context).primaryColor.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColor,
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent, // Hapus garis bawah default
        tabs: const [
          Tab(text: 'Baru'),
          Tab(text: 'Proses'),
          Tab(text: 'Riwayat'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(EvaIcons.alertTriangleOutline, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text("Akses Ditolak", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Akun ini bukan admin klinik.", style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari panel admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Keluar"),
          ),
        ],
      ),
    );
  }
}