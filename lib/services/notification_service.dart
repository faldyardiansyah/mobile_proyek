import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

enum NotifType {
  pembayaranBerhasil,
  pembayaranGagal,
  segeraBayar,
  refund,
  info,
}

class NotificationItem {
  final String title;
  final String body;
  final NotifType type;
  final DateTime time;
  final String? route;
  bool isRead;

  NotificationItem({
    required String title,
    required String body,
    required this.type,
    required this.time,
    this.route,
    this.isRead = false,
  })  : title = title,
        body = body;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // 1. UBAH ID CHANNEL-NYA (Wajib biar Android me-reset pengaturan cache lama)
  static const _channelId = 'appkonkos_channel_premium_v1';
  static const _channelName = 'AppKonkos Notifikasi Penting';

  static final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  static int get unreadCount => notifications.where((n) => !n.isRead).length;

  static void markAsRead(int index) {
    if (index < notifications.length) {
      notifications[index].isRead = true;
      notifications.refresh();
    }
  }

  static void markAllAsRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
  }

  static void addNotification({
    required String title,
    required String body,
    required NotifType type,
    String? route,
  }) {
    notifications.insert(
      0,
      NotificationItem(
        title: title,
        body: body,
        type: type,
        time: DateTime.now(),
        route: route,
      ),
    );
  }

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadRoute = response.payload;
        if (payloadRoute != null && payloadRoute.isNotEmpty) {
          Get.toNamed(payloadRoute); 
        }
      },
    );

    // 2. PERBAIKAN: Minta izin pop-up runtime untuk Android 13 ke atas
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    NotifType type = NotifType.info,
    String? route,
  }) async {
    addNotification(title: title, body: body, type: type, route: route);

    // 3. PERBAIKAN: Definisikan cfg di sini agar warna & tema terbaca
    final cfg = _getConfig(type);

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max, // Biar melayang dari atas layar
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: cfg['color'] as Color, // Aksen warna brand (biru/merah/orange)/ Logo besar di kanan
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: 'APPKONKOS',
          ),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    NotifType type = NotifType.segeraBayar,
    String? route,
  }) async {
    addNotification(title: title, body: body, type: type, route: route);

    final cfg = _getConfig(type);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: cfg['color'] as Color,
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: 'APPKONKOS',
          ),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: route,
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    notifications.clear();
  }

  // 4. PERBAIKAN: Kembalikan fungsi pembaca warna yang sempat hilang
  Map<String, dynamic> _getConfig(NotifType type) {
    switch (type) {
      case NotifType.pembayaranBerhasil:
        return {
          'color': const Color(0xFF1565C0),
          'bg': const Color(0xFFE3F2FD),
          'icon': Icons.check_circle_rounded,
        };
      case NotifType.pembayaranGagal:
        return {
          'color': Colors.red,
          'bg': const Color(0xFFFFEBEE),
          'icon': Icons.cancel_rounded,
        };
      case NotifType.segeraBayar:
        return {
          'color': const Color(0xFFE65100),
          'bg': const Color(0xFFFFF3E0),
          'icon': Icons.access_time_rounded,
        };
      case NotifType.refund:
        return {
          'color': const Color(0xFF6A1B9A),
          'bg': const Color(0xFFF3E5F5),
          'icon': Icons.assignment_return_rounded,
        };
      case NotifType.info:
        return {
          'color': Colors.grey,
          'bg': Colors.grey.shade50,
          'icon': Icons.info_outline_rounded,
        };
    }
  }
}