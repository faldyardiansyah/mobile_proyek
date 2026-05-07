import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/riwayat_controller.dart';
import 'models/model_riwayat.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatController());
    return ColoredBox(
      color: AppColor.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildTabBar(controller),
          Expanded(
            child: Obx(() {
              final list = controller.filteredList;
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada riwayat booking',
                    style: TextStyle(color: AppColor.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) =>
                    _BookingCard(item: list[index], controller: controller),
              );
            }),
          ),
        ],
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
                color:
                    isSelected ? const Color(0xFF1565C0) : Colors.white,
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
                  child: Image.network(
                    item.imageAsset,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: AppColor.grey200,
                      child: const Icon(
                        Icons.broken_image,
                        color: AppColor.grey300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(status: item.status),
                      const SizedBox(height: 4,),
                      Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),),
                      const SizedBox(height: 4,),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColor.grey,),
                          const SizedBox(width: 2,),
                          Expanded(child: Text(item.location, style: const TextStyle(fontSize: 11, color: AppColor.grey), overflow: TextOverflow.ellipsis,),)
                        ],
                      )
                    ]
                  )
                ),
                if (item.status == BookingStatus.menunggu && item.canceldate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF6B00),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(item.counttime!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColor.white, fontFamily: 'monospace'),),
                )
                else 
                Text(item.id, style: const TextStyle(fontSize: 11, color: AppColor.grey),)
              ],
            ),
            const SizedBox(height: 12,),
            const Divider(height: 1, color: AppColor.grey300,),
            const SizedBox(height: 12,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.status == BookingStatus.refund ? (item.canceldate ?? " ") : 'TOTAL', style: const TextStyle(fontSize: 11, color: AppColor.grey, letterSpacing: 0.5),),
                    if (item.status != BookingStatus.refund)
                    Text(item.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),)
                  ],
                ),
                _buildActionButton(),
              ],
            )
          ],
        ),
      ),
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
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: const Text(
          'Ajukan Refund',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0)),
        ),
      );

    case BookingStatus.menunggu:
      return ElevatedButton(
        onPressed: () => controller.bayarSekarang(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
        ),
        child: const Text(
          'Bayar Sekarang',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      );

    case BookingStatus.refund:
      return const SizedBox.shrink();
  }

  }
}


class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context){
    final config = _config(status);
    return Container(
      padding:  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: config['bg'] as Color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(config['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: config['text'] as Color, letterSpacing: 0.5),),
    );
  }
 Map<String, dynamic> _config(BookingStatus status) {
    switch (status) {
      case BookingStatus.dibayar:
        return {'label': 'DIBAYAR', 'bg': const Color(0xFFE3F2FD), 'text': const Color(0xFF1565C0)};
      case BookingStatus.menunggu:
        return {'label': 'MENUNGGU', 'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFE65100)};
      case BookingStatus.refund:
        return {'label': 'REFUNDED', 'bg': const Color(0xFFF3E5F5), 'text': const Color(0xFF6A1B9A)};
    }
  }
}