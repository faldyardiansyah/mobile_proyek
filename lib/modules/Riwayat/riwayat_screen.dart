import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'controllers/riwayat_controller.dart';
import 'models/model_riwayat.dart';
import '../Riwayat/screens/booking_detail_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  late RiwayatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RiwayatController>()
        ? Get.find<RiwayatController>()
        : Get.put(RiwayatController());
    controller.fetchRiwayat();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ColoredBox(
        color: AppColor.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabBar(controller),
            Expanded(
              child: Obx(() {
                final isLoading = controller.isLoading.value;
                final list = controller.filteredList;
        
                if (isLoading) {
                  return _buildSkeletonList();
                }
        
                return RefreshIndicator(
                  color: const Color(0xFF1565C0),
                  onRefresh: () => controller.fetchRiwayat(),
                  child: list.isEmpty
                      ? ListView(
                          // ← pakai ListView bukan SingleChildScrollView
                          // supaya RefreshIndicator bisa ditarik walau kosong
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 110),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Lottie.asset(
                                      'assets/lottie/nothing.json',
                                      width: 250,
                                      height: 250,
                                      repeat: true,
                                    ),
                                    const Text(
                                      'Tidak ada riwayat booking',
                                      style: TextStyle(color: AppColor.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 110,
                            top: 8,
                          ),
                          itemCount: list.length,
                          itemBuilder: (context, index) => _BookingCard(
                            item: list[index],
                            controller: controller,
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(duration: Duration(milliseconds: 1000)),
      child: ListView.builder(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 110,
          top: 8,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder gambar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder badge status
                      Container(
                        width: 70,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Placeholder judul
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      // Placeholder lokasi
                      Container(
                        width: 150,
                        height: 11,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
                // Placeholder ID/countdown
                Container(width: 60, height: 14, color: Colors.grey[300]),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColor.grey300),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 40, height: 11, color: Colors.grey[300]),
                    const SizedBox(height: 4),
                    Container(width: 100, height: 16, color: Colors.grey[300]),
                  ],
                ),
                // Placeholder tombol
                Container(
                  width: 100,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Riwayat Booking",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.black,
            size: 21,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabBar(RiwayatController controller) {
  return Obx(
    () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(controller.tabs.length, (i) {
          final isSelected = controller.selectedTab.value == i;
          return GestureDetector(
            onTap: () => controller.selectTab(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF1565C0).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: isSelected ? 8 : 4,
                    offset: Offset(0, isSelected ? 4 : 1),
                  ),
                ],
              ),
              child: Text(
                controller.tabs[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColor.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    ),
  );
}

class _BookingCard extends StatelessWidget {
  final ModelRiwayat item;
  final RiwayatController controller;

  const _BookingCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => BookingDetailScreen(item: item, controller: controller)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: item.imageAsset.isNotEmpty
                          ? Image.network(
                              item.imageAsset,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholderImage(),
                            )
                          : _placeholderImage(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _StatusBadge(status: item.status),
                              const Spacer(),
                              if (item.status == BookingStatus.menunggu &&
                                  item.canceldate != null)
                                Obx(() {
                                  controller.tick;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.sisaWaktu == Duration.zero
                                          ? Colors.red.shade400
                                          : const Color(0xFFE65100),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.counttime,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                })
                              else
                                Flexible(
                                  child: Text(
                                    item.id,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColor.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColor.grey,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  item.location.isNotEmpty
                                      ? item.location
                                      : '-',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColor.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColor.grey300),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.status == BookingStatus.refund
                                ? (item.canceldate ?? ' ')
                                : 'TOTAL',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColor.grey,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (item.status != BookingStatus.refund)
                            Text(
                              item.price,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 72,
      height: 72,
      color: AppColor.grey200,
      child: const Icon(Icons.home_outlined, color: AppColor.grey300, size: 32),
    );
  }

  Widget _buildActionButton() {
    switch (item.status) {
      case BookingStatus.dibayar:
        return OutlinedButton(
          onPressed: () => controller.ajukanRefund(item),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            'Ajukan Refund',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
        );

      case BookingStatus.menunggu:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton(
              onPressed: () => controller.batalkanBooking(item),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => controller.bayarSekarang(item),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                elevation: 0,
              ),
              child: const Text(
                'Bayar',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );

      case BookingStatus.refund:
      case BookingStatus.dibatalkan:
        return OutlinedButton(
          onPressed: () => controller.hapusRiwayat(item),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, size: 14, color: Colors.red),
              SizedBox(width: 4),
              Text(
                'Hapus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        );
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config['bg'] as Color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config['label'] as String,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: config['text'] as Color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _config(BookingStatus status) {
    switch (status) {
      case BookingStatus.dibayar:
        return {
          'label': 'DIBAYAR',
          'bg': const Color(0xFFE3F2FD),
          'text': const Color(0xFF1565C0),
        };
      case BookingStatus.menunggu:
        return {
          'label': 'MENUNGGU',
          'bg': const Color(0xFFFFF3E0),
          'text': const Color(0xFFE65100),
        };
      case BookingStatus.refund:
        return {
          'label': 'REFUNDED',
          'bg': const Color(0xFFF3E5F5),
          'text': const Color(0xFF6A1B9A),
        };
      case BookingStatus.dibatalkan:
        return {
          'label': 'DIBATALKAN',
          'bg': const Color(0xFFFFEbee),
          'text': const Color(0xFFf44336),
        };
    }
  }
}
