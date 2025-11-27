import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vetsy_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';
import 'package:vetsy_app/features/home/presentation/cubit/banner_cubit.dart';
// [UPDATE] Import Halaman Notifikasi
import 'package:vetsy_app/features/notification/presentation/screens/notification_screen.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});
  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua'; 

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(String category) {
    setState(() {
      if (_selectedCategory == category) {
        _selectedCategory = 'Semua';
      } else {
        _selectedCategory = category;
      }
    });
    context.read<ClinicCubit>().filterByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. HEADER WAVE (GELOMBANG)
          SliverToBoxAdapter(
            child: Stack(
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    height: 240,
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withBlue(200)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        String username = "Vetsy User";
                        if (state is Authenticated) {
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
                                    Text("Halo, Apa kabar?", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                                    Text(username, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                
                                // [PERBAIKAN] Tombol Notifikasi Sekarang Bisa Diklik
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      // Navigasi ke Halaman Notifikasi
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2), 
                                        shape: BoxShape.circle
                                      ),
                                      child: const Icon(EvaIcons.bellOutline, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                
                // Search Bar
                Container(
                  margin: const EdgeInsets.only(top: 160, left: 24, right: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context.read<ClinicCubit>().searchClinics(value),
                    decoration: InputDecoration(
                      hintText: 'Cari klinik atau dokter...',
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

          // 2. KATEGORI MENU
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
                      _buildCategoryItem(context, "Vaksinasi", EvaIcons.shieldOutline, Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. BANNER PROMO (DINAMIS)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120, 
              child: BlocBuilder<BannerCubit, BannerState>(
                builder: (context, state) {
                  if (state is BannerLoading) {
                    return _buildShimmerBanner();
                  }
                  
                  if (state is BannerLoaded) {
                    if (state.banners.isEmpty) {
                      return _buildStaticPromoBanner(); 
                    }

                    return PageView.builder(
                      controller: PageController(viewportFraction: 0.85),
                      itemCount: state.banners.length,
                      itemBuilder: (context, index) {
                        final banner = state.banners[index];
                        return BouncyContainer(
                          onTap: () {},
                          child: Container(
                            margin: const EdgeInsets.only(right: 16), 
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(banner.imageUrl),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  
                  return _buildStaticPromoBanner();
                },
              ),
            ),
          ),

          // 4. JUDUL LIST
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
                ],
              ),
            ),
          ),

          // 5. LIST KLINIK
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
                          Text("Tidak ada klinik ditemukan", style: TextStyle(color: Colors.grey[500])),
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
                        final fakeDistance = ((index + 1) * 1.2).toStringAsFixed(1);
                        final ratingValue = clinic.rating > 0 ? clinic.rating.toStringAsFixed(1) : "Baru";

                        return BouncyContainer(
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
                                  child: Hero(
                                    tag: 'clinic_image_${clinic.id}',
                                    child: CachedNetworkImage(
                                      imageUrl: clinic.imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                                      errorWidget: (ctx, error, stackTrace) => Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                                    ),
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
                                          Icon(Icons.star, size: 14, color: Colors.orange[700]),
                                          const SizedBox(width: 4),
                                          Text(ratingValue, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[800])),
                                          const SizedBox(width: 12),
                                          Icon(EvaIcons.navigation2Outline, size: 14, color: Theme.of(context).primaryColor),
                                          const SizedBox(width: 4),
                                          Text("$fakeDistance km", style: GoogleFonts.poppins(fontSize: 11, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
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
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // [HELPER] BANNER STATIS (JIKA DB KOSONG)
  Widget _buildStaticPromoBanner() {
    return BouncyContainer(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF101820), Color(0xFF2C3E50)]),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
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
    );
  }

  Widget _buildShimmerBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(height: 120, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String label, IconData icon, Color color) {
    final isSelected = _selectedCategory == label;
    return BouncyContainer(
      onTap: () => _onCategoryTap(label),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Icon(icon, color: isSelected ? Colors.white : color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.black87 : Colors.grey[600])),
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

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    var secondControlPoint = Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class BouncyContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BouncyContainer({super.key, required this.child, required this.onTap});
  @override
  State<BouncyContainer> createState() => _BouncyContainerState();
}
class _BouncyContainerState extends State<BouncyContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}