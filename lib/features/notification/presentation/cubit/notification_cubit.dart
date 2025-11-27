import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Fungsi ini dipanggil saat User Login (di main.dart)
  void initNotificationListener() {
    final user = auth.currentUser;
    if (user == null) return;

    // Batalkan listener lama jika ada
    _notifSubscription?.cancel();

    // Dengarkan collection 'notifications' milik user ini
    _notifSubscription = firestore
        .collection('notifications')
        .where('userId', isEqualTo: user.uid)
        // Hanya ambil notifikasi yang dibuat SETELAH user login (biar notif lama ga bunyi semua)
        .where('createdAt', isGreaterThan: Timestamp.now()) 
        .snapshots()
        .listen((snapshot) {
      
      for (var change in snapshot.docChanges) {
        // Jika ada data BARU ditambahkan
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          
          // Puculkan Notifikasi di HP
          notificationService.showNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000, 
            title: data['title'] ?? 'Info Baru', 
            body: data['body'] ?? 'Ada pembaruan status booking.',
          );
        }
      }
    });
  }

  @override
  Future<void> close() {
    _notifSubscription?.cancel();
    return super.close();
  }
}