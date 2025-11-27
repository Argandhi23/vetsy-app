import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationScreen extends StatelessWidget {
  static const String routeName = '/notifications';
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text("Notifikasi", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null 
          ? const Center(child: Text("Silakan login"))
          : StreamBuilder<QuerySnapshot>(
              // [QUERY] Ambil dari Root Collection 'notifications'
              stream: FirebaseFirestore.instance
                  .collection('notifications')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(EvaIcons.bellOffOutline, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Belum ada notifikasi", style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isRead = data['isRead'] ?? false;
                    final timestamp = (data['createdAt'] as Timestamp).toDate();
                    final time = DateFormat('d MMM, HH:mm').format(timestamp);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10)],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(EvaIcons.bellOutline, color: Colors.blue),
                        ),
                        title: Text(data['title'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(data['body'] ?? '', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                            const SizedBox(height: 8),
                            Text(time, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        onTap: () {
                          // Tandai sudah dibaca
                          docs[index].reference.update({'isRead': true});
                        },
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX();
                  },
                );
              },
            ),
    );
  }
}