import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../home/controllers/home_controller.dart';
import '../../utils/app_color.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});
  static const Color _bg = Color(0xFFF5F7FB);
  static const Color _card = Colors.white;
  static const Color _text1 = Color(0xFF0D1B2A);
  static const Color _text2 = Color(0xFF4A5568);
  static const Color _text3 = Color(0xFF94A3B8);
  static const Color _div = Color(0xFFF0F4F8);

  String _fmt(String n) {
    final v = int.tryParse(n) ?? 0;
    return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
          _buildAppBar(controller),
            Expanded(
              child: Obx(() {
                if (controller.wishlist.isEmpty) return _buildEmpty();
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  itemCount: controller.wishlist.length,
                  itemBuilder: (_, i) =>
                      _buildCard(controller, controller.wishlist[i], i),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(HomeController controller) {
    return Container(
      color: _bg,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              controller.tabIndex.value = 0;
              HapticFeedback.lightImpact();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: _text1,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            "Properti Tersimpan",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text1,
            ),
          ),
          const Spacer(),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${controller.wishlist.length} properti",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2);
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 52,
              color: AppColor.primary,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            "Wishlist masih kosong",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _text1,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          const Text(
            "Simpan properti favoritmu\nagar mudah ditemukan lagi",
            style: TextStyle(fontSize: 13, color: _text3, height: 1.5),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildCard(HomeController controller, dynamic data, int index) {
    final isKosan = (data.type ?? '').toLowerCase() == 'kosan';
    final gender = (data.gender ?? '').toString();

    return GestureDetector(
          onTap: () => Get.to(() => const DetailScreen(), arguments: data),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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

                    // Gradient
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x55000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),

                    // Badges
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

                    // Fav button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.toggleFavorite(data);
                        },
                        child:
                            Container(
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
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                )
                                .animate(onPlay: (c) => c.forward())
                                .scale(
                                  duration: 200.ms,
                                  curve: Curves.easeOutBack,
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
                        color: _div,
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
                              const Text(
                                "Mulai dari",
                                style: TextStyle(
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
                                    TextSpan(text: "Rp ${_fmt(data.price)}"),
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

  Widget _genderPill(String gender) {
    final g = gender.toLowerCase();
    final isCampur = g.contains('campur');
    final isPutra = g.contains('putra') || g.contains('laki');
    Color bg, text;
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
}
