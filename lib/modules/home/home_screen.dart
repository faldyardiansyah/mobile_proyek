import 'package:appkonkos_mobile/modules/riwayat/riwayat_screen.dart';
import 'package:appkonkos_mobile/modules/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import './controllers/home_controller.dart';
import '../chat/chat_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'package:appkonkos_mobile/auth/controller/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final authC = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            _buildHomeContent(),
            const WishlistScreen(),
            const SizedBox(),
            const RiwayatScreen(),
            ProfileScreen(),
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
        child: SizedBox(
          height: 64,
          width: 64,
          child: FloatingActionButton(
            backgroundColor: AppColor.primary,
            elevation: 4,
            shape: const CircleBorder(),
            onPressed: () => Get.to(() => const ChatScreen()),
            child: Image.asset(
              "assets/image/chatbot.png",
              width: 40,
              height: 40,
              color: AppColor.white,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem("assets/image/search.png", "Cari", 0),
                  _buildNavItem("assets/image/wishlist.png", "Simpan", 1),
                  const SizedBox(width: 40),
                  _buildNavItem(
                    "assets/image/riwayat.png",
                    "Riwayat",
                    3,
                    hasNotification: true,
                  ),
                  _buildNavItem("assets/image/profile.png", "Profil", 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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

            Obx(() {
              if (controller.properties.isEmpty && controller.searchQuery.value.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.properties.isEmpty && controller.searchQuery.value.isNotEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Text(
                      "Tidak ada properti yang cocok dengan pencarianmu.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.properties.length,
                itemBuilder: (context, index) =>
                    _buildPropertyCard(controller.properties[index], index),
              );
            }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    String imagePath,
    String label,
    int index, {
    bool hasNotification = false,
  }) {
    bool isSelected = controller.tabIndex.value == index;

    return InkWell(
      onTap: () {
        controller.tabIndex.value = index;
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(15),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        imagePath,
                        width: 24,
                        height: 24,
                        color: isSelected
                            ? AppColor.primary
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 4),
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
        },
      ),
    ).animate().fadeIn(delay: (index * 100).ms);
  }

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
                "APPKONKOS",
                style: TextStyle(
                  color: Color(0xFF0077B6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 5),
              Obx(() {
                if (authC.user.isEmpty) {
                  return const Text("Loading...");
                }

                return Text(
                  "Halo, Selamat datang, ${authC.user['nama']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3);
              }),
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
              child: TextField(
                onChanged: (value) => controller.searchProperty(value),
                decoration: const InputDecoration(
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
              onTap: () {
                controller.changeCategory(index);
                HapticFeedback.lightImpact();
              },
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

  Widget _buildPropertyCard(dynamic data, int index) {
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
              Positioned(
                top: 12,
                right: 12,
                child: Obx(() {
                  bool isFav = controller.isFavorite(data);

                  return GestureDetector(
                    onTap: () {
                      controller.toggleFavorite(data);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColor.primary : Colors.grey,
                        size: 20,
                      ),
                    ),
                  );
                }),
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
                    Expanded(
                      child: Text(
                        data.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4EAD7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFFC107),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${data.rating}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
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
    ).animate(delay: (index * 100).ms)
.fadeIn(duration: 500.ms)
.slideY(begin: 0.3)
.scale(begin: const Offset(0.95, 0.95));
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
