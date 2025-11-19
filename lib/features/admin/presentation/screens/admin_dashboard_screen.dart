import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';

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
    // PERBAIKAN: Gunakan BlocBuilder untuk mendengarkan perubahan state secara real-time
    // Ini mencegah error saat refresh karena kita bisa menampilkan Loading dulu
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        
        // 1. JIKA SEDANG LOADING DATA USER (SAAT REFRESH)
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Memuat data admin..."),
                ],
              ),
            ),
          );
        }

        // 2. CEK APAKAH SUDAH AUTHENTICATED & DATA LENGKAP
        String? clinicId;
        if (state is Authenticated) {
          clinicId = state.clinicId;
        }

        // 3. JIKA DATA KLINIK TIDAK DITEMUKAN (ERROR)
        if (clinicId == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(EvaIcons.alertTriangleOutline, size: 50, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text("Error: Akun Admin tidak valid / Clinic ID Missing"),
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

        // 4. JIKA SUKSES, TAMPILKAN DASHBOARD
        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: Column(
            children: [
              // HEADER STATISTIK
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bookings')
                    .where('clinicId', isEqualTo: clinicId)
                    .snapshots(),
                builder: (context, snapshot) {
                   int pending = 0;
                   int process = 0;
                   int done = 0;

                   if (snapshot.hasData) {
                     final docs = snapshot.data!.docs;
                     pending = docs.where((d) => d['status'] == 'Pending').length;
                     process = docs.where((d) => d['status'] == 'Confirmed').length;
                     done = docs.where((d) => ['Completed', 'Cancelled'].contains(d['status'])).length;
                   }

                   return _buildHeader(context, pending, process, done);
                },
              ),

              // SEARCH BAR
              _buildSearchBar(),

              // ISI KONTEN
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('clinicId', isEqualTo: clinicId)
                      .orderBy('scheduleDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final allDocs = snapshot.data?.docs ?? [];

                    final filteredDocs = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final petName = (data['petName'] ?? '').toString().toLowerCase();
                      final serviceName = (data['service']['name'] ?? '').toString().toLowerCase();
                      return petName.contains(_searchQuery.toLowerCase()) || 
                             serviceName.contains(_searchQuery.toLowerCase());
                    }).toList();

                    final pendingList = filteredDocs.where((d) => d['status'] == 'Pending').toList();
                    final confirmedList = filteredDocs.where((d) => d['status'] == 'Confirmed').toList();
                    final historyList = filteredDocs.where((d) => ['Completed', 'Cancelled'].contains(d['status'])).toList();

                    return DefaultTabController(
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
                              tabs: [
                                Tab(text: 'Baru (${pendingList.length})'),
                                Tab(text: 'Proses (${confirmedList.length})'),
                                const Tab(text: 'Riwayat'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                _buildBookingList(context, pendingList, isActionable: true),
                                _buildBookingList(context, confirmedList, isCompletable: true),
                                _buildBookingList(context, historyList),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS (TIDAK ADA PERUBAHAN DI BAWAH SINI) ---

  Widget _buildHeader(BuildContext context, int pending, int process, int done) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 50, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Admin Panel", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                  Text("Dashboard Klinik", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(EvaIcons.logOutOutline, color: Colors.white),
                tooltip: 'Logout',
              )
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("Menunggu", pending.toString(), Colors.orange, EvaIcons.loaderOutline)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("Diproses", process.toString(), Colors.lightBlue, EvaIcons.activityOutline)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard("Selesai", done.toString(), Colors.green, EvaIcons.checkmarkCircle2Outline)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari nama pasien atau layanan...',
          prefixIcon: const Icon(EvaIcons.searchOutline, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(EvaIcons.close, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBookingList(BuildContext context, List<QueryDocumentSnapshot> docs,
      {bool isActionable = false, bool isCompletable = false}) {
    
    if (docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(EvaIcons.folderRemoveOutline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? "Tidak ada data" : "Pencarian tidak ditemukan",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final String bookingId = docs[index].id;
        
        final DateTime date = (data['scheduleDate'] as Timestamp).toDate();
        final String dateStr = DateFormat('d MMM yyyy', 'id_ID').format(date);
        final String timeStr = DateFormat('HH:mm').format(date);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(EvaIcons.calendarOutline, size: 16, color: Colors.blueGrey),
                        const SizedBox(width: 6),
                        Text(
                          "$dateStr • $timeStr",
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    if (!isActionable && !isCompletable)
                      _buildStatusBadge(data['status'])
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.pets, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['petName'] ?? 'Tanpa Nama',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['service']['name'],
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (isActionable || isCompletable)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      if (isActionable) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _updateStatus(bookingId, 'Cancelled'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Tolak"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateStatus(bookingId, 'Confirmed'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text("Terima"),
                          ),
                        ),
                      ],
                      if (isCompletable)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateStatus(bookingId, 'Completed'),
                            icon: const Icon(EvaIcons.checkmarkCircle2Outline, size: 18),
                            label: const Text("Selesaikan Pesanan"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'Completed': color = Colors.green; label = 'Selesai'; break;
      case 'Cancelled': color = Colors.red; label = 'Dibatalkan'; break;
      default: color = Colors.grey; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari halaman admin?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
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

  Future<void> _updateStatus(String id, String status) async {
    await FirebaseFirestore.instance.collection('bookings').doc(id).update({'status': status});
  }
}