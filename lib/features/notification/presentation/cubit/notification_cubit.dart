import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:vetsy_app/core/services/notification_service.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationService notificationService;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  
  StreamSubscription? _notifSubscription;

  NotificationCubit({
    required this.notificationService,
    required this.auth,
    required this.firestore,
  }) : super(NotificationInitial());

  void initNotificationListener() {
    final user = auth.currentUser;
    if (user == null) return;

    _notifSubscription?.cancel();

    debugPrint("🔔 [NotifCubit] Mulai mendengarkan notifikasi untuk: ${user.uid}");

    // Flag untuk menandai data awal (Load pertama kali)
    bool isFirstLoad = true;

    _notifSubscription = firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .limit(10) // Batasi agar tidak berat
        .snapshots()
        .listen((snapshot) {
      
      // Saat aplikasi baru dibuka, Firestore mengirim semua data yang ada.
      // Kita tandai ini sebagai 'First Load' dan JANGAN bunyikan notifikasi (biar gak spam).
      if (isFirstLoad) {
        isFirstLoad = false;
        return; 
      }

      for (var change in snapshot.docChanges) {
        // Hanya bereaksi jika ada dokumen BARU yang ditambahkan (Realtime)
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          debugPrint("🔔 [NotifCubit] Notifikasi Baru Diterima: ${data['title']}");
          
          notificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
            title: data['title'] ?? 'Info Baru', 
            body: data['body'] ?? 'Ada pembaruan status.',
          );
        }
      }
    }, onError: (e) {
      debugPrint("❌ [NotifCubit] Error: $e");
    });
  }

  @override
  Future<void> close() {
    _notifSubscription?.cancel();
    return super.close();
  }
}