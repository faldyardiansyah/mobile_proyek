import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:appkonkos_mobile/services/notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifService = NotificationService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              notifService.cancelAll();
              Get.snackbar(
                'Notifikasi',
                'Semua notifikasi telah dihapus',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.grey.shade100,
                colorText: Colors.grey.shade800,
              );
            },
            child: const Text(
              'Hapus Semua',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Obx(() {
        final list = NotificationService.notifications;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notifikasi booking akan muncul di sini',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final notif = list[index];
            return _buildNotifCard(notif, index);
          },
        );
      }),
    );
  }

  Widget _buildNotifCard(NotificationItem notif, int index) {
    final cfg = _getConfig(notif.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notif.isRead ? Colors.white : (cfg['bg'] as Color),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notif.isRead
              ? const Color(0xFFE2E8F0)
              : (cfg['color'] as Color).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            NotificationService.markAsRead(index);
            if (notif.route != null) {
              Get.toNamed(notif.route!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (cfg['color'] as Color).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cfg['icon'] as IconData,
                    color: cfg['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: cfg['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.body,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7B8794),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatWaktu(notif.time),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  String _formatWaktu(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}