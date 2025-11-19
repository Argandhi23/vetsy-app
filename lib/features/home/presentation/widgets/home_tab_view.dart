import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final TextEditingController _searchController = TextEditingController();
  
  // State untuk melacak kategori yang sedang aktif
  String _selectedCategory = 'Semua'; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi saat kategori diklik
  void _onCategoryTap(String category) {
    setState(() {
      // Kalau diklik lagi, batalkan filter (toggle kembali ke 'Semua')
      if (_selectedCategory == category) {
        _selectedCategory = 'Semua';
      } else {
        _selectedCategory = category;
      }
    });
    // Panggil fungsi filter di Cubit
    context.read<ClinicCubit>().filterByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. HEADER GREETING & SEARCH
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withBlue(200)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      String username = "Vetsy User";
                      if (state is Authenticated) {
                        // PRIORITASKAN DATA USERNAME DARI FIRESTORE
                        username = state.username ?? state.user.displayName ?? state.user.email?.split('@')[0] ?? "User";
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Selamat Datang, 👋", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                                  Text(username, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: IconButton(icon: const Icon(EvaIcons.bellOutline, color: Colors.white), onPressed: () {}),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 170, left: 24, right: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context.read<ClinicCubit>().searchClinics(value),
                    decoration: InputDecoration(
                      hintText: 'Cari klinik, dokter, atau layanan...',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(EvaIcons.searchOutline, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(icon: const Icon(EvaIcons.close, color: Colors.grey, size: 20), onPressed: () { _searchController.clear(); context.read<ClinicCubit>().searchClinics(''); setState(() {}); })
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. KATEGORI MENU (YANG BISA DIKLIK)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Layanan Kami", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCategoryItem(context, "Dokter", EvaIcons.activityOutline, Colors.blue),
                      _buildCategoryItem(context, "Grooming", EvaIcons.scissorsOutline, Colors.orange),
                      _buildCategoryItem(context, "Pet Hotel", EvaIcons.homeOutline, Colors.purple),
                      // GANTI MAKANAN JADI VAKSINASI
                      _buildCategoryItem(context, "Vaksinasi", EvaIcons.shieldOutline, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. BANNER PROMO
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(colors: [Color(0xFF101820), Color(0xFF2C3E50)]),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Stack(
                children: [
                  Positioned(right: -20, bottom: -20, child: Icon(Icons.pets, size: 150, color: Colors.white.withOpacity(0.05))),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(8)),
                          child: Text("PROMO", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text("Diskon Vaksin 20%", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("Khusus pengguna baru", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. JUDUL LIST KLINIK
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'Semua' ? "Rekomendasi Klinik" : "Klinik $_selectedCategory", 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                  if (_selectedCategory != 'Semua')
                    GestureDetector(
                      onTap: () => _onCategoryTap('Semua'),
                      child: Text("Reset Filter", style: GoogleFonts.poppins(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600))
                    )
                  else
                    Text("Lihat Semua", style: GoogleFonts.poppins(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // 5. LIST KLINIK (Logic Filtered)
          BlocBuilder<ClinicCubit, ClinicState>(
            builder: (context, state) {
              if (state is ClinicLoading || state is ClinicInitial) {
                return SliverList(delegate: SliverChildBuilderDelegate((context, index) => _buildShimmerCard(), childCount: 3));
              }
              if (state is ClinicError) {
                return SliverToBoxAdapter(child: Center(child: Text(state.message)));
              }
              if (state is ClinicLoaded) {
                if (state.clinics.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(EvaIcons.searchOutline, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text("Tidak ada klinik untuk kategori ini", style: TextStyle(color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final clinic = state.clinics[index];
                        final fakeRating = (4.5 + (index % 5) / 10).toStringAsFixed(1);
                        final fakeDistance = ((index + 1) * 1.2).toStringAsFixed(1);

                        return GestureDetector(
                          onTap: () => context.goNamed(ClinicDetailScreen.routeName, pathParameters: {'clinicId': clinic.id}),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    clinic.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                                    errorBuilder: (ctx, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(clinic.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(EvaIcons.pinOutline, size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(clinic.address, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, size: 12, color: Colors.orange),
                                                const SizedBox(width: 2),
                                                Text(fakeRating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text("$fakeDistance km", style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.clinics.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // WIDGET ITEM KATEGORI (INTERAKTIF)
  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == label;
    
    return GestureDetector(
      onTap: () => _onCategoryTap(label),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // Warna berubah solid jika dipilih
              color: isSelected ? color : color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isSelected 
                  ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(
              icon, 
              color: isSelected ? Colors.white : color, 
              size: 24
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label, 
            style: GoogleFonts.poppins(
              fontSize: 12, 
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            )
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 100, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
      ),
    );
  }
}