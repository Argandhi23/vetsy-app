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

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
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
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(EvaIcons.alertTriangleOutline, size: 50, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text("Error: Bukan Admin / ID Klinik Hilang"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AuthCubit>().signOut(),
                    child: const Text("Logout"),
                  )
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // HEADER & STATISTIK
              _buildHeaderSection(context, clinicId),

              // SEARCH BAR
              _buildSearchBar(),

              // TAB VIEW (LIST BOOKING)
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          tabs: const [
                            Tab(text: 'Baru'),
                            Tab(text: 'Proses'),
                            Tab(text: 'Riwayat'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Tab 1: Menunggu (Pending)
                            AdminBookingList(
                              clinicId: clinicId, 
                              statusFilter: 'Pending', 
                              searchQuery: _searchQuery
                            ),
                            
                            // Tab 2: Dikerjakan (InProgress) - [PERBAIKAN UTAMA]
                            AdminBookingList(
                              clinicId: clinicId, 
                              statusFilter: 'InProgress', 
                              searchQuery: _searchQuery
                            ),
                            
                            // Tab 3: Selesai (Completed/Cancelled)
                            AdminBookingList(
                              clinicId: clinicId, 
                              statusFilter: 'Completed', 
                              searchQuery: _searchQuery
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
          // Hitung status 'Pending'
          pending = docs.where((d) => d['status'] == 'Pending').length;
          
          // [PERBAIKAN] Hitung 'InProgress' atau 'Confirmed' sebagai Proses
          process = docs.where((d) => 
            ['InProgress', 'Confirmed'].contains(d['status'])
          ).length;
          
          // Hitung Selesai/Batal
          done = docs.where((d) => 
            ['Completed', 'Cancelled', 'Rejected'].contains(d['status'])
          ).length;
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.blue[800]!],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Admin Panel", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                    Text("Dashboard Klinik", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  ]),
                  IconButton(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(EvaIcons.logOutOutline, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageServicesScreen(clinicId: clinicId))),
                  icon: const Icon(EvaIcons.settings2Outline, color: Colors.white),
                  label: const Text("Kelola Daftar Layanan & Harga"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.2), foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: AdminStatCard(label: "Menunggu", value: "$pending", color: Colors.orange, icon: EvaIcons.loaderOutline)),
                const SizedBox(width: 12),
                Expanded(child: AdminStatCard(label: "Dikerjakan", value: "$process", color: Colors.lightBlue, icon: EvaIcons.activityOutline)),
                const SizedBox(width: 12),
                Expanded(child: AdminStatCard(label: "Selesai", value: "$done", color: Colors.green, icon: EvaIcons.checkmarkCircle2Outline)),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari nama pasien atau layanan...',
          prefixIcon: const Icon(EvaIcons.searchOutline, color: Colors.grey),
          filled: true, fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(EvaIcons.close, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
              : null,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Logout"),
        content: const Text("Keluar dari admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}