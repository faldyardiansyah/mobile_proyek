import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import './controllers/home_controller.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  final controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            _buildHomeContent(),
            const Center(child: Text("Halaman Favorit")),
            const SizedBox(),
            const Center(child: Text("Halaman Riwayat")),
            const Center(child: Text("Halaman Profil")),
          ],
        ),
      ),

      floatingActionButton: Container(
        height: 68,
        width: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColor.white,
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: AppColor.primary,
          onPressed: () => Get.to(() => const ChatScreen()),
          child: const Icon(
            Icons.smart_toy_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomAppBar(
            color: Colors.white,
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: SizedBox(
              height: 78,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildNavItem(Icons.search, "Cari", 0),
                          const SizedBox(width: 20),
                          _buildNavItem(Icons.favorite_border, "Simpan", 1),
                        ],
                      ),
                      Row(
                        children: [
                          _buildNavItem(
                            Icons.assignment_outlined,
                            "Riwayat",
                            3,
                            hasNotification: true,
                          ),
                          const SizedBox(width: 20),
                          _buildNavItem(Icons.person_outline, "Profil", 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- KONTEN UTAMA HOME ---
  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderFancy(),
            _buildSearchWithFilter(),
            _buildCategoryScroll(),
            _buildSectionTitle("Properti Terdekat"),

            // Memperbaiki Improper Use of GetX dengan mengecek list
            Obx(() {
              if (controller.properties.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.properties.length,
                itemBuilder: (context, index) =>
                    _buildPropertyCard(controller.properties[index]),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- REFACTORED NAV ITEM ---
  Widget _buildNavItem(
    IconData icon,
    String label,
    int index, {
    bool hasNotification = false,
  }) {
    bool isSelected = controller.tabIndex.value == index;
    return InkWell(
      onTap: () => controller.tabIndex.value = index,
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? AppColor.primary
                      : const Color(0xFF94A3B8),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected
                        ? AppColor.primary
                        : const Color(0xFF94A3B8),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            // Titik notifikasi biru
            if (hasNotification)
              Positioned(
                top: 4,
                right: 14,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- UI LAINNYA (TETAP SAMA TAPI DIRAPIKAN) ---
  Widget _buildHeaderFancy() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "LOKASI SEKARANG",
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.stars, size: 18, color: AppColor.primary),
                  const SizedBox(width: 5),
                  const Text(
                    "Jakarta Selatan, DKI",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
          _buildCircleIconButton(Icons.notifications_none_rounded),
        ],
      ),
    );
  }

  Widget _buildSearchWithFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
                  hintText: "Cari hunian impianmu...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScroll() {
    return SizedBox(
      height: 75,
      child: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            bool isSelected = controller.selectedCategoryIndex.value == index;
            return GestureDetector(
              onTap: () => controller.changeCategory(index),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  controller.categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPropertyCard(dynamic data) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=400",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    _badge("TERSEDIA", AppColor.primary, Colors.white),
                    const SizedBox(width: 8),
                    _badge(data.type, Colors.white, AppColor.primary),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(
                          " ${data.rating}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    Text(
                      " ${data.location}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "Rp ${data.price}",
                        style: const TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        children: [
                          const TextSpan(
                            text: " /bulan",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Pesan",
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _badge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: bg == Colors.white ? Border.all(color: AppColor.primary) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Lihat Semua",
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Icon(icon, size: 22),
    );
  }
}
