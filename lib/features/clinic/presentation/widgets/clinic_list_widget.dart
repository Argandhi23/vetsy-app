import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:shimmer/shimmer.dart'; 
import 'package:vetsy_app/features/clinic/presentation/cubit/clinic_cubit.dart';
import 'package:vetsy_app/features/clinic/presentation/screens/clinic_detail_screen.dart';

class ClinicListWidget extends StatefulWidget {
  const ClinicListWidget({super.key});

  @override
  State<ClinicListWidget> createState() => _ClinicListWidgetState();
}

class _ClinicListWidgetState extends State<ClinicListWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. SEARCH BAR MODERN (Tetap Sama) ---
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<ClinicCubit>().searchClinics(value);
            },
            decoration: InputDecoration(
              hintText: 'Cari klinik atau dokter...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(EvaIcons.searchOutline, color: Theme.of(context).primaryColor),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(EvaIcons.close, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<ClinicCubit>().searchClinics('');
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),

        // --- 2. LIST DATA ---
        Expanded(
          child: BlocBuilder<ClinicCubit, ClinicState>(
            builder: (context, state) {
              // LOADING STATE (SHIMMER)
              if (state is ClinicLoading || state is ClinicInitial) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: 5, 
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 120, 
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                );
              }
              
              if (state is ClinicError) {
                return Center(child: Text(state.message));
              }
              
              if (state is ClinicLoaded) {
                if (state.clinics.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(EvaIcons.searchOutline, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Klinik tidak ditemukan', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: state.clinics.length,
                  itemBuilder: (context, index) {
                    final clinic = state.clinics[index];
                    
                    // --- [MODIFIKASI DATA] ---
                    // Jarak masih dummy karena tidak pakai Maps API
                    final fakeDistance = ((clinic.address.length % 5) + 1.2).toStringAsFixed(1);
                    
                    // Rating & Review SUDAH ASLI dari Database
                    final String ratingText = clinic.rating > 0 
                        ? clinic.rating.toStringAsFixed(1) 
                        : "Baru";
                    final String reviewCountText = clinic.totalReviews > 0 
                        ? "(${clinic.totalReviews})" 
                        : "";

                    return Card(
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          context.goNamed(ClinicDetailScreen.routeName, pathParameters: {'clinicId': clinic.id});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  clinic.imageUrl,
                                  width: 90, height: 90, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 90, height: 90, color: Colors.grey[200],
                                    child: const Icon(Icons.error, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      clinic.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      clinic.address,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        // Menampilkan Rating Asli + Jumlah Ulasan
                                        _buildTag(EvaIcons.star, "$ratingText $reviewCountText", Colors.orange[700]!),
                                        const SizedBox(width: 16),
                                        // Jarak (Masih dummy)
                                        _buildTag(EvaIcons.pinOutline, '$fakeDistance km', Colors.blue[800]!),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTag(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800])),
      ],
    );
  }
}