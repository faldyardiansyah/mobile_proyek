import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/riwayat_controller.dart';
import 'package:appkonkos_mobile/modules/riwayat/models/model_riwayat.dart';

class RiwayatScreen extends StatelessWidget {
  final RiwayatController controller = Get.put(RiwayatController());

  RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        title: Row(
          children: const [
            const Text(
            "Riwayat Booking",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
            const Spacer(),
            const Icon(
              Icons.notifications_none,
              color: Colors.black,
            ),
          ]
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tab("Semua", 0),
                _tab("Menunggu", 1),
                _tab("Dibayar", 2),
                _tab("Refund", 3),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 3. Daftar Riwayat menggunakan Obx
          Expanded(
            child: Obx(() {
              final listData = controller.filteredriwayats; // Perbaikan Case-Sensitive

              if (listData.isEmpty) {
                return const Center(child: Text("Tidak ada riwayat"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: listData.length,
                itemBuilder: (context, index) {
                  final item = listData[index];
                  return _bookingCard(item);
                },
              );
            }),
          )
        ],
      ),
    );
  }

  // Widget Tab Filter
  Widget _tab(String title, int index) {
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: Obx(() {
        bool active = controller.selectedTab.value == index;
        return Container(
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }),
    );
  }

  // Widget Card untuk List
  Widget _bookingCard(Riwayat item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  item.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rp ${item.price}",
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          color: _getStatusColor(item.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dibayar':
        return Colors.green;
      case 'menunggu':
        return Colors.orange;
      case 'refound':
      case 'refund':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}