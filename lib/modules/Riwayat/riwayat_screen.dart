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
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12), 
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
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildStatusActions(
    ModelRiwayat item, RiwayatController controller) {
  switch (item.status) {
    case BookingStatus.menunggu:
      return ElevatedButton(
        onPressed: () => controller.bayarSekarang(item),
        child: const Text('Bayar Sekarang'),
      );
    case BookingStatus.dibayar:
      return ElevatedButton(
        onPressed: () => controller.ajukanRefund(item),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.amber,
        ),
        child: const Text('Ajukan Refund'),
      );
    case BookingStatus.refund:
      return const Text(
        'Refund Diproses',
        style: TextStyle(color: AppColor.grey),
      );
    default:
      return const SizedBox(); // ✅ FIX biar aman
  }
}