import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:appkonkos_mobile/modules/Riwayat/models/model_riwayat.dart';
import '../Riwayat/riwayat_screen.dart';
import 'package:appkonkos_mobile/modules/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:lottie/lottie.dart';
import './controllers/home_controller.dart';
import '../chat/chat_screen.dart';
import '../wishlist/wishlist_screen.dart';
import 'package:appkonkos_mobile/auth/controller/auth_controller.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShimmerEffect;
import 'package:skeletonizer/skeletonizer.dart';
import '../Riwayat/controllers/riwayat_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;
  late final RiwayatController riwayatController;

  AuthController get authC => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController());
    controller = Get.find<HomeController>();

    if (!Get.isRegistered<RiwayatController>()) {
      riwayatController = Get.put(RiwayatController(), permanent: true);
    } else {
      riwayatController = Get.find<RiwayatController>();
    }

    // fetch setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      riwayatController.fetchRiwayat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            _buildHomeContent(),
            const WishlistScreen(),
            const SizedBox(),
            RiwayatScreen(),
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
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
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
                    Obx(() {
                      riwayatController;
                      final punya = riwayatController.listRiwayats.any(
                        (b) => b.status == BookingStatus.menunggu,
                      );
                      return _buildNavItem(
                        "assets/image/riwayat.png",
                        "Riwayat",
                        3,
                        hasNotification: punya, // ← dinamis
                      );
                    }),
                    _buildNavItem("assets/image/profile.png", "Profil", 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Obx(() {
        final isSkeleton = controller.isSkeleton.value;
        return Skeletonizer(
          enabled: isSkeleton,
          effect: const ShimmerEffect(duration: Duration(milliseconds: 1000)),
          child: RefreshIndicator(
            onRefresh: () => controller.loadProperties(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: const Color(0xFFF8FAFC),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 0,
                  flexibleSpace: const SizedBox.shrink(),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(165),
                    child: Container(
                      color: const Color(0xFFF8FAFC),
                      child: Column(
                        children: [
                          _buildHeaderFancy(),
                          _buildSearchWithFilter(),
                          _buildCategoryScroll(),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSectionTitle("Properti Terdekat"),
                ),
                if (isSkeleton)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildSkeletonCard(),
                      childCount: 3,
                    ),
                  )
                else if (controller.properties.isEmpty &&
                    controller.searchQuery.value.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/404.json',
                              width: 200,
                              height: 200,
                              repeat: true,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Data tidak ditemukan",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (controller.properties.isEmpty &&
                    controller.searchQuery.value.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/lottie/404.json',
                              width: 200,
                              height: 200,
                              repeat: true,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Data tidak ada yang cocok dengan pencarianmu",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == controller.properties.length) {
                        return const SizedBox(height: 100);
                      }
                      return _buildPropertyCard(
                        controller.properties[index],
                        index,
                      );
                    }, childCount: controller.properties.length + 1),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 200, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 12, width: 150, color: Colors.grey[300]),
                const SizedBox(height: 8),
                Container(height: 12, width: 120, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 16, width: 130, color: Colors.grey[300]),
                    Container(
                      height: 36,
                      width: 80,
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
        ],
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
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isSelected ? -6 : 0),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Stack(
                children: [
                  Image.asset(
                    imagePath,
                    width: isSelected ? 26 : 24,
                    height: isSelected ? 26 : 24,
                    color: isSelected
                        ? AppColor.primary
                        : const Color(0xFF94A3B8),
                  ),
                  if (hasNotification)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColor.primary : const Color(0xFF94A3B8),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms);
  }

  Widget _buildHeaderFancy() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 31, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "APPKONKOS",
                style: TextStyle(
                  color: AppColor.primary,
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
                  "Halo, Selamat datang, ${authC.user['name']}",
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
          GestureDetector(
            onTap: () => _showFilterBottomSheet(),
            child: Container(
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
            return Obx(() {
              bool isSelected = controller.selectedCategoryIndex.value == index;
              return GestureDetector(
                onTap: () {
                  controller.changeCategory(index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primary : AppColor.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColor.primary.withOpacity(0.25)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 1),
                      ),
                    ],
                  ),
                  child: Text(
                    controller.categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColor.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildPropertyCard(dynamic data, int index) {
    return GestureDetector(
          onTap: () {
            Get.to(() => const DetailScreen(), arguments: data);
          },
          child: Container(
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
                        data.foto,
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
                          // badge gender huruf besar
                          if ((data.type ?? "").toLowerCase() == "kosan" &&
                              (data.gender ?? "").isNotEmpty) ...[
                            _badge(
                              (data.gender as String).toUpperCase(),
                              Colors.orange.shade100,
                              Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                          ],
                          _badge(
                            (data.type ?? "-").toUpperCase(),
                            Colors.white,
                            AppColor.primary,
                          ),
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
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            data.type.toLowerCase() == "kosan"
                                ? Icons.home_work_outlined
                                : Icons.home_work_outlined,
                            size: 15,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            data.type.toLowerCase() == "kosan"
                                ? "${data.availableCount} kamar tersedia"
                                : data.availableCount > 0
                                ? "Kontrakan tersedia"
                                : "Tidak tersedia",
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      data.price == data.priceMax ||
                                          data.priceMax == '0'
                                      ? "Rp ${_formatHarga(data.price)}"
                                      : "Rp ${_formatHarga(data.price)} - Rp ${_formatHarga(data.priceMax)}",
                                ),
                                TextSpan(
                                  text: "/${data.period}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Get.to(
                                () => const DetailScreen(),
                                arguments: data,
                              );
                            },
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
          ),
        )
        .animate(delay: (index * 100).ms)
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

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(width: 40, child: Divider(thickness: 4)),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Filter",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                // Tipe Hunian
                const SizedBox(height: 25),
                const Text(
                  "Tipe Hunian",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _filterChip(
                        "Semua",
                        controller.selectedType.value == "",
                        () => controller.setType(""),
                      ),
                      _filterChip(
                        "Kosan",
                        controller.selectedType.value == "Kosan",
                        () => controller.setType("Kosan"),
                      ),
                      _filterChip(
                        "Kontrakan",
                        controller.selectedType.value == "Kontrakan",
                        () => controller.setType("Kontrakan"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
                const Text(
                  "Tipe Penghuni",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: controller.genderOptions.map((gender) {
                      return _filterChip(
                        gender,
                        gender == "Semua"
                            ? controller.selectedGender.value == ""
                            : controller.selectedGender.value == gender,
                        () => controller.setGender(gender),
                      );
                    }).toList(),
                  ),
                ),

                // Urutan Harga
                const SizedBox(height: 25),
                const Text(
                  "Urutan Harga",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    children: [
                      _filterChip(
                        "Termurah",
                        controller.selectedSort.value == "low",
                        () => controller.setSort("low"),
                      ),
                      const SizedBox(width: 10),
                      _filterChip(
                        "Termahal",
                        controller.selectedSort.value == "high",
                        () => controller.setSort("high"),
                      ),
                    ],
                  ),
                ),

                // Minimal Rating
                const SizedBox(height: 25),
                const Text(
                  "Minimal Rating",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Slider(
                    value: controller.minRating.value,
                    min: 0,
                    max: 5,
                    divisions: 5,
                    label: controller.minRating.value.toString(),
                    onChanged: (val) => controller.setRating(val),
                  ),
                ),

                // Maksimal Harga
                const SizedBox(height: 25),
                const Text(
                  "Maksimal Harga",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Obx(
                  () => Column(
                    children: [
                      Slider(
                        value: controller.maxPrice.value,
                        min: 500000,
                        max: 10000000,
                        onChanged: (val) => controller.setMaxPrice(val),
                      ),
                      Text(
                        "Di bawah Rp ${controller.maxPrice.value.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F51B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Terapkan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
