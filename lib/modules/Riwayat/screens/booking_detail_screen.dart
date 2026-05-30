import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../controllers/riwayat_controller.dart';
import '../models/model_riwayat.dart';
import 'refund_screen.dart';
import 'package:appkonkos_mobile/modules/booking/screens/midtrans_webview_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final ModelRiwayat item;
  const BookingDetailScreen({super.key, required this.item});

  static const Color blue = Color(0xFF1565C0);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RiwayatController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail Booking',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusCard(),
            const SizedBox(height: 12),
            _buildPropertyCard(),
            const SizedBox(height: 12),
            _buildPaymentCard(),
            const SizedBox(height: 20),
            _buildActions(controller),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final cfg = _statusConfig();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cfg['bg'] as Color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (cfg['color'] as Color).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (cfg['color'] as Color).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              cfg['icon'] as IconData,
              color: cfg['color'] as Color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg['label'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: cfg['color'] as Color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cfg['desc'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: (cfg['color'] as Color).withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          if (item.status == BookingStatus.menunggu && item.canceldate != null)
            Obx(() {
              final ctrl = Get.find<RiwayatController>();
              ctrl.tick;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.sisaWaktu == Duration.zero
                      ? Colors.red.shade400
                      : const Color(0xFFE65100),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.counttime,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Properti',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imageAsset.isNotEmpty
                    ? Image.network(
                        item.imageAsset,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(80),
                      )
                    : _placeholder(80),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.location.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: textGrey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: textGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.id,
                        style: const TextStyle(
                          fontSize: 10,
                          color: blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rincian Pembayaran',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 14),
          if (item.refundStatus != null) ...[
            const Divider(),
            if (item.bookingTime != null)
              _infoRow('Tanggal Booking', _formatTanggal(item.bookingTime!)),

            if (item.checkIn != null)
              _infoRow('Check In', _formatTanggal(item.checkIn!)),

            if (item.checkOut != null)
              _infoRow('Check Out', _formatTanggal(item.checkOut!)),
            _infoRow('Status Refund', item.refundStatus!),

            if (item.alasanRefund != null)
              _infoRow('Alasan Refund', item.alasanRefund!),

            if (item.nominalRefund != null)
              _infoRow('Nominal Refund', 'Rp ${item.nominalRefund}'),
          ],
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              Text(
                item.price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(RiwayatController controller) {
    switch (item.status) {
      case BookingStatus.menunggu:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.payment_rounded, color: Colors.white),
                label: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => controller.bayarSekarang(item),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                  size: 18,
                ),
                label: const Text(
                  'Batalkan Booking',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  controller.batalkanBooking(item);
                  Get.back();
                },
              ),
            ),
          ],
        );

      case BookingStatus.dibayar:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.assignment_return_rounded,
              color: Colors.white,
            ),
            label: const Text(
              'Ajukan Refund',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            onPressed: () => Get.to(() => RefundScreen(item: item)),
          ),
        );

      case BookingStatus.dibatalkan:
      case BookingStatus.refund:
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text(
              'Hapus Riwayat',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              controller.hapusRiwayat(item);
              Get.back();
            },
          ),
        );
    }
  }

  Map<String, dynamic> _statusConfig() {
    switch (item.status) {
      case BookingStatus.dibayar:
        return {
          'label': 'Pembayaran Berhasil',
          'desc': 'Booking telah dikonfirmasi',
          'bg': const Color(0xFFE3F2FD),
          'color': blue,
          'icon': Icons.check_circle_rounded,
        };
      case BookingStatus.menunggu:
        return {
          'label': 'Menunggu Pembayaran',
          'desc': 'Selesaikan sebelum batas waktu',
          'bg': const Color(0xFFFFF3E0),
          'color': const Color(0xFFE65100),
          'icon': Icons.access_time_rounded,
        };
      case BookingStatus.dibatalkan:
        return {
          'label': 'Booking Dibatalkan',
          'desc': 'Booking ini telah dibatalkan',
          'bg': const Color(0xFFFFEBEE),
          'color': Colors.red,
          'icon': Icons.cancel_rounded,
        };
      case BookingStatus.refund:
        return {
          'label': 'Refund Diproses',
          'desc': 'Permintaan refund sedang diproses admin',
          'bg': const Color(0xFFF3E5F5),
          'color': const Color(0xFF6A1B9A),
          'icon': Icons.assignment_return_rounded,
        };
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: textGrey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.home_outlined, color: Colors.grey),
    );
  }

  String _formatTanggal(DateTime dt) {
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }
}
