import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:appkonkos_mobile/modules/Riwayat/models/model_riwayat.dart';
import 'package:appkonkos_mobile/modules/notification/notification_screen.dart';
import 'package:appkonkos_mobile/services/notification_service.dart';
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

  // ─── Design tokens ────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _card = Colors.white;
  static const Color _text1 = Color(0xFF0D1B2A);
  static const Color _text2 = Color(0xFF4A5568);
  static const Color _text3 = Color(0xFF94A3B8);
  static const Color _divClr = Color(0xFFF0F4F8);

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      riwayatController.fetchRiwayat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: _bg,
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

      // ── FAB
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom nav
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return Container(
      height: 62,
      width: 62,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: AppColor.primary,
        elevation: 0,
        shape: const CircleBorder(),
        onPressed: () => Get.to(() => const ChatScreen()),
        child: Image.asset(
          "assets/image/chatbot.png",
          width: 30,
          height: 30,
          color: Colors.white,
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  // ─── Bottom nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        height: 68,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _navItem("assets/image/search.png", "Cari", 0),
                  _navItem("assets/image/wishlist.png", "Simpan", 1),
                  const SizedBox(width: 44),
                  Obx(() {
                    final punya = riwayatController.listRiwayats.any(
                      (b) => b.status == BookingStatus.menunggu,
                    );
                    return _navItem(
                      "assets/image/riwayat.png",
                      "Riwayat",
                      3,
                      badge: punya,
                    );
                  }),
                  _navItem("assets/image/profile.png", "Profil", 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(String img, String label, int idx, {bool badge = false}) {
    final isSel = controller.tabIndex.value == idx;
    return InkWell(
      onTap: () {
        controller.tabIndex.value = idx;
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? AppColor.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isSel ? -4.0 : 0.0),
              duration: const Duration(milliseconds: 300),
              builder: (_, v, child) =>
                  Transform.translate(offset: Offset(0, v), child: child),
              child: Stack(
                children: [
                  Image.asset(
                    img,
                    width: isSel ? 25 : 23,
                    height: isSel ? 25 : 23,
                    color: isSel ? AppColor.primary : _text3,
                  ),
                  if (badge)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
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
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: isSel ? 10 : 9,
                fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                color: isSel ? AppColor.primary : _text3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (idx * 80).ms);
  }

  // ─── Home content ─────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    return SafeArea(
      child: Obx(() {
        final isSkeleton = controller.isSkeleton.value;
        return Skeletonizer(
          enabled: isSkeleton,
          effect: const ShimmerEffect(duration: Duration(milliseconds: 1000)),
          child: RefreshIndicator(
            color: AppColor.primary,
            onRefresh: () => controller.loadProperties(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  backgroundColor: _bg,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 0,
                  flexibleSpace: const SizedBox.shrink(),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(165),
                    child: Container(
                      color: _bg,
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildSearchBar(),
                          _buildCategories(),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildBanner()),
                SliverToBoxAdapter(
                  child: _buildSectionTitle("Properti Tersedia"),
                ),
                if (isSkeleton)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => _buildSkeletonCard(),
                      childCount: 3,
                    ),
                  )
                else if (controller.properties.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmpty(
                      controller.searchQuery.value.isNotEmpty
                          ? "Tidak ada yang cocok dengan pencarianmu"
                          : "Data tidak ditemukan",
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((_, i) {
                      if (i == controller.properties.length)
                        return const SizedBox(height: 110);
                      return _buildPropertyCard(controller.properties[i], i);
                    }, childCount: controller.properties.length + 1),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "APPKONKOS",
                    style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Obx(() {
                if (authC.user.isEmpty) return const SizedBox.shrink();
                return Row(
                  children: [
                    const Text(
                      "Halo, ",
                      style: TextStyle(fontSize: 13, color: _text2),
                    ),
                    Text(
                      authC.user['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _text1,
                      ),
                    ),
                    const Text(" 👋", style: TextStyle(fontSize: 13)),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2);
              }),
            ],
          ),
          _notifButton(),
        ],
      ),
    );
  }

  Widget _notifButton() {
    return GestureDetector(
      onTap: () {
        NotificationService.markAllAsRead();
        Get.to(() => const NotificationScreen());
      },
      child: Obx(() {
        final unread = NotificationService.getUnreadCount();
        return Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _divClr),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 22,
                color: _text1,
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: _divClr),
              ),
              child: TextField(
                onChanged: (v) => controller.searchProperty(v),
                style: const TextStyle(fontSize: 14, color: _text1),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search_rounded, color: _text3, size: 20),
                  hintText: "Cari hunian impianmu...",
                  hintStyle: TextStyle(color: _text3, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Categories ───────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return SizedBox(
      height: 68,
      child: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          scrollDirection: Axis.horizontal,
          itemCount: controller.categories.length,
          itemBuilder: (_, i) => Obx(() {
            final isSel = controller.selectedCategoryIndex.value == i;
            return GestureDetector(
              onTap: () {
                controller.changeCategory(i);
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSel ? AppColor.primary : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSel ? Colors.transparent : _divClr,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSel
                          ? AppColor.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSel ? 10 : 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  controller.categories[i],
                  style: TextStyle(
                    color: isSel ? Colors.white : _text2,
                    fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Banner ───────────────────────────────────────────────────────────────
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: Column(
        children: [
          SizedBox(
            height: 155,
            child: PageView.builder(
              controller: controller.bannerController,
              itemCount: controller.banners.length,
              onPageChanged: (i) => controller.bannerIndex.value = i,
              itemBuilder: (_, i) {
                final b = controller.banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [b['color'] as Color, b['accent'] as Color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Stack(
                    children: [
                      // Deco circles
                      Positioned(
                        right: -24,
                        top: -24,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                b['tag'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              b['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      b['btn'] as String,
                                      style: TextStyle(
                                        color: b['color'] as Color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: b['color'] as Color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: controller.bannerIndex.value == i ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: controller.bannerIndex.value == i
                        ? AppColor.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _text1,
                ),
              ),
            ],
          ),
          Text(
            "Lihat Semua",
            style: TextStyle(
              color: AppColor.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Empty state ──────────────────────────────────────────────────────────
  Widget _buildEmpty(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/404.json',
              width: 180,
              height: 180,
              repeat: true,
            ),
            const SizedBox(height: 16),
            Text(
              msg,
              style: const TextStyle(color: _text3, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Skeleton card ────────────────────────────────────────────────────────
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 170,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 15, width: 200, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(height: 12, width: 140, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(height: 12, width: 110, color: Colors.grey[200]),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 15, width: 120, color: Colors.grey[200]),
                    Container(
                      height: 34,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
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

  // ─── Property card ────────────────────────────────────────────────────────
  String _fmt(String n) {
    final v = int.tryParse(n) ?? 0;
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildPropertyCard(dynamic data, int index) {
    final isKosan = (data.type ?? '').toLowerCase() == 'kosan';
    final gender = (data.gender ?? '').toString();

    return GestureDetector(
          onTap: () => Get.to(() => const DetailScreen(), arguments: data),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Photo
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        data.foto,
                        height: 175,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 175,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: _text3,
                          ),
                        ),
                      ),
                    ),

                    // Top-left badges
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Wrap(
                        spacing: 6,
                        children: [
                          _pill(
                            isKosan ? "KOSAN" : "KONTRAKAN",
                            AppColor.primary,
                            Colors.white,
                          ),
                          if (isKosan && gender.isNotEmpty) _genderPill(gender),
                        ],
                      ),
                    ),

                    // Top-right fav
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Obx(() {
                        final isFav = controller.isFavorite(data);
                        return GestureDetector(
                          onTap: () => controller.toggleFavorite(data),
                          child: Container(
                            width: 36,
                            height: 36,
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
                              isFav
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFav ? Colors.red : _text3,
                              size: 18,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Bottom gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(0),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x55000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── Info
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _text1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFE082),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "${data.rating}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF795548),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: _text3,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _text2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Availability
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: data.availableCount > 0
                                  ? const Color(0xFF22C55E)
                                  : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isKosan
                                ? "${data.availableCount} kamar tersedia"
                                : data.availableCount > 0
                                ? "Unit tersedia"
                                : "Tidak tersedia",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: data.availableCount > 0
                                  ? const Color(0xFF16A34A)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      Container(
                        height: 1,
                        color: _divClr,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                      ),

                      // Price + CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Mulai dari",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _text3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: AppColor.primary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          data.price == data.priceMax ||
                                              data.priceMax == '0'
                                          ? "Rp ${_fmt(data.price)}"
                                          : "Rp ${_fmt(data.price)}",
                                    ),
                                    TextSpan(
                                      text: "/${data.period}",
                                      style: const TextStyle(
                                        color: _text3,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Get.to(
                              () => const DetailScreen(),
                              arguments: data,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColor.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text(
                                "Lihat Detail",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
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
        .animate(delay: (index * 80).ms)
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.25)
        .scale(begin: const Offset(0.96, 0.96));
  }

  // ─── Gender pill ──────────────────────────────────────────────────────────
  Widget _genderPill(String gender) {
    final g = gender.toLowerCase();
    final isCampur = g.contains('campur');
    final isPutra = g.contains('putra') || g.contains('laki');
    Color bg;
    Color text;
    if (isCampur) {
      bg = const Color(0xFFFFF3CD);
      text = const Color(0xFF854D0E);
    } else if (isPutra) {
      bg = const Color(0xFFDBEAFE);
      text = const Color(0xFF1D4ED8);
    } else {
      bg = const Color(0xFFFCE7F3);
      text = const Color(0xFF9D174D);
    }
    return _pill(gender.toUpperCase(), bg, text);
  }

  Widget _pill(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ─── Filter sheet ─────────────────────────────────────────────────────────
  void _showFilterSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Filter Pencarian",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _text1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.setType('');
                        controller.setGender('Semua');
                        controller.setSort('');
                        controller.setRating(0);
                        controller.setMaxPrice(10000000);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade100, height: 20),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fSec("Tipe Hunian", Icons.home_outlined),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          children: [
                            _fChip(
                              "Semua",
                              controller.selectedType.value == "",
                              () => controller.setType(""),
                            ),
                            _fChip(
                              "Kosan",
                              controller.selectedType.value == "Kosan",
                              () => controller.setType("Kosan"),
                            ),
                            _fChip(
                              "Kontrakan",
                              controller.selectedType.value == "Kontrakan",
                              () => controller.setType("Kontrakan"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _fSec("Tipe Penghuni", Icons.people_outline),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: controller.genderOptions
                              .map(
                                (g) => _fChip(
                                  g,
                                  g == "Semua"
                                      ? controller.selectedGender.value == ""
                                      : controller.selectedGender.value == g,
                                  () => controller.setGender(g),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _fSec("Urutan Harga", Icons.sort_rounded),
                      const SizedBox(height: 10),
                      Obx(
                        () => Wrap(
                          spacing: 8,
                          children: [
                            _fChip(
                              "💰 Termurah",
                              controller.selectedSort.value == "low",
                              () => controller.setSort("low"),
                            ),
                            _fChip(
                              "💎 Termahal",
                              controller.selectedSort.value == "high",
                              () => controller.setSort("high"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _fSec("Minimal Rating", Icons.star_outline_rounded),
                      const SizedBox(height: 4),
                      Obx(
                        () => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "⭐ ${controller.minRating.value.toStringAsFixed(1)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _text1,
                                  ),
                                ),
                                Text(
                                  controller.minRating.value == 0
                                      ? "Semua rating"
                                      : "Min. ${controller.minRating.value.toStringAsFixed(1)} bintang",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _text3,
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(Get.context!).copyWith(
                                activeTrackColor: AppColor.primary,
                                inactiveTrackColor: Colors.grey.shade200,
                                thumbColor: AppColor.primary,
                                overlayColor: AppColor.primary.withOpacity(0.1),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: controller.minRating.value,
                                min: 0,
                                max: 5,
                                divisions: 5,
                                onChanged: (v) => controller.setRating(v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      _fSec("Maksimal Harga", Icons.payments_outlined),
                      const SizedBox(height: 4),
                      Obx(() {
                        final h = controller.maxPrice.value.toInt();
                        final fmt = h.toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]}.',
                        );
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Rp $fmt",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: _text1,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    h >= 10000000 ? "Semua harga" : "Maks.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColor.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(Get.context!).copyWith(
                                activeTrackColor: AppColor.primary,
                                inactiveTrackColor: Colors.grey.shade200,
                                thumbColor: AppColor.primary,
                                overlayColor: AppColor.primary.withOpacity(0.1),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: controller.maxPrice.value,
                                min: 500000,
                                max: 10000000,
                                divisions: 19,
                                onChanged: (v) => controller.setMaxPrice(v),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "500rb",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                Text(
                                  "10jt",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Terapkan Filter",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _fSec(String title, IconData icon) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: AppColor.primary),
      ),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: _text1,
        ),
      ),
    ],
  );

  Widget _fChip(String label, bool isSel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppColor.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSel ? Colors.white : _text2,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
