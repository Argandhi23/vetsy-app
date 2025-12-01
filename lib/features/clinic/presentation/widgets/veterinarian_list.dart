import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vetsy_app/features/clinic/data/models/veterinarian_model.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class VeterinarianList extends StatelessWidget {
  final String clinicId;

  const VeterinarianList({super.key, required this.clinicId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dokter Kami",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        StreamBuilder<QuerySnapshot>(
          // Query ke Root Collection 'veterinarians'
          stream: FirebaseFirestore.instance
              .collection('veterinarians')
              .where('clinicId', isEqualTo: clinicId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Text("Belum ada data dokter.", style: GoogleFonts.poppins(color: Colors.grey));
            }

            return SizedBox(
              height: 180, // List Horizontal
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final vet = VeterinarianModel.fromFirestore(docs[index]);
                  return _buildVetCard(vet);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVetCard(VeterinarianModel vet) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: vet.photoUrl.isNotEmpty ? NetworkImage(vet.photoUrl) : null,
            child: vet.photoUrl.isEmpty ? const Icon(EvaIcons.person) : null,
          ),
          const SizedBox(height: 8),
          Text(
            vet.name,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            vet.specialization,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 12, color: Colors.amber),
              Text(
                " ${vet.rating}",
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}