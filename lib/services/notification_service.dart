import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

enum NotifType { pembayaranBerhasil, pembayaranGagal, segeraBayar, refund, info }

class NotificationItem {
  final String title;
  final String body;
  final NotifType type;
  final DateTime time;
  final String? route;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.route,
    this.isRead = false,
  });



  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'type': type.index,
      'time': time.toIso8601String(),
      'route': route,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotifType.values[map['type'] ?? 4],
      time: DateTime.parse(map['time'] ?? DateTime.now().toIso8601String()),
      route: map['route'],
      isRead: map['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'appkonkos_channel_premium_v1';
  static const _channelName = 'AppKonkos Notifikasi Penting';

  static final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  static final _box = GetStorage();
  
  static String activeUserId = 'global'; 
  static void switchUser(String userId) {
    activeUserId = userId;
    notifications.clear();
    
    String? storedNotifs = _box.read('notif_$activeUserId');
    if (storedNotifs != null) {
      try {
        List<dynamic> decoded = jsonDecode(storedNotifs);
        notifications.assignAll(decoded.map((x) => NotificationItem.fromMap(Map<String, dynamic>.from(x))).toList());
      } catch (e) {
        debugPrint("Error load notif: $e");
      }
    }
    debugPrint("🔔 NOTIFIKASI AKTIF UNTUK USER ID: $activeUserId");
  }

  static void _saveToStorage() {
    List<Map<String, dynamic>> rawList = notifications.map((n) => n.toMap()).toList();
    _box.write('notif_$activeUserId', jsonEncode(rawList)); 
  }

  static int getUnreadCount([String? jembatan]) => notifications.where((n) => !n.isRead).length;
  static void markAsRead(int index) {
    if (index < notifications.length) {
      notifications[index].isRead = true;
      notifications.refresh();
      _saveToStorage();
    }
  }

  static void markAllAsRead([String? jembatan]) {
    for (final n in notifications) { n.isRead = true; }
    notifications.refresh();
    _saveToStorage();
  }

  static List<NotificationItem> getNotificationsByUser([String? jembatan]) => notifications.toList();

  static void addNotification({
    String? userId, 
    required String title,
    required String body,
    required NotifType type,
    String? route,
  }) {
    notifications.insert(0, NotificationItem(title: title, body: body, type: type, time: DateTime.now(), route: route));
    _saveToStorage();
  }

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    final savedUser = _box.read('user'); 
    if (savedUser != null && savedUser['id'] != null) {
      switchUser(savedUser['id'].toString()); 
    } else {
      switchUser('global');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payloadRoute = response.payload;
        if (payloadRoute != null && payloadRoute.isNotEmpty) { Get.toNamed(payloadRoute); }
      },
    );

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  Future<void> show({String? userId, required int id, required String title, required String body, NotifType type = NotifType.info, String? route}) async {
    final cfg = _getConfig(type);
    addNotification(title: title, body: body, type: type, route: route);

    await _plugin.show(
      id, title, body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName, importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher', color: cfg['color'] as Color, 
          styleInformation: BigTextStyleInformation(body, htmlFormatBigText: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: 'APPKONKOS'),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }

  Future<void> schedule({String? userId, required int id, required String title, required String body, required DateTime scheduledTime, NotifType type = NotifType.segeraBayar, String? route}) async {
    final cfg = _getConfig(type);
    // addNotification(title: title, body: body, type: type, route: route);

    await _plugin.zonedSchedule(
      id, title, body, tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName, importance: Importance.max, priority: Priority.high, icon: '@mipmap/ic_launcher', color: cfg['color'] as Color,
          styleInformation: BigTextStyleInformation(body, htmlFormatBigText: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: 'APPKONKOS'),
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: route,
    );
  }

  Future<void> cancel(int id) async => await _plugin.cancel(id);
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    notifications.clear();
    _box.remove('notif_$activeUserId');
  }

  Map<String, dynamic> _getConfig(NotifType type) {
    switch (type) {
      case NotifType.pembayaranBerhasil: return {'color': const Color(0xFF1565C0), 'bg': const Color(0xFFE3F2FD), 'icon': Icons.check_circle_rounded};
      case NotifType.pembayaranGagal: return {'color': Colors.red, 'bg': const Color(0xFFFFEBEE), 'icon': Icons.cancel_rounded};
      case NotifType.segeraBayar: return {'color': const Color(0xFFE65100), 'bg': const Color(0xFFFFF3E0), 'icon': Icons.access_time_rounded};
      case NotifType.refund: return {'color': const Color(0xFF6A1B9A), 'bg': const Color(0xFFF3E5F5), 'icon': Icons.assignment_return_rounded};
      case NotifType.info: return {'color': Colors.grey, 'bg': Colors.grey.shade50, 'icon': Icons.info_outline_rounded};
    }
  }
}