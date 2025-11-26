import 'dart:io'; // Import ini boleh ada, tapi jangan dipanggil fungsinya di Web
import 'package:flutter/foundation.dart'; // [PENTING] Untuk cek kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // [FIX] Jika berjalan di Web, langsung berhenti (return) agar tidak crash
    // karena notifikasi lokal ini didesain untuk Mobile (Android/iOS).
    if (kIsWeb) return; 

    // Inisialisasi Timezone
    tz_data.initializeTimeZones();

    // Setup Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // Minta Izin Notifikasi (Hanya jalan di Android, jadi aman karena sudah di-cek kIsWeb diatas)
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // [FIX] Jangan jalankan di Web
    if (kIsWeb) return;

    try {
      if (scheduledTime.isBefore(DateTime.now())) return;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'booking_channel_id',
            'Booking Reminders',
            channelDescription: 'Notifikasi jadwal klinik',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("✅ Notifikasi terjadwal: $scheduledTime");
    } catch (e) {
      print("❌ Gagal schedule: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    // [FIX] Jangan jalankan di Web
    if (kIsWeb) return;
    
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}