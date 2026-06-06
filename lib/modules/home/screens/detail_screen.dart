import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:share_plus/share_plus.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../controllers/detail_controller.dart';
import '../controllers/ulasan_controller.dart';
import '../widgets/review_card.dart';
import '../widgets/full_screen_gallery.dart';
import '../controllers/home_controller.dart';
import '../models/property_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:appkonkos_mobile/modules/booking/widgets/booking_bottom_sheet.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // ─── Design tokens ────────────────────────────────────────────────────────

  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textMid = Color(0xFF4A5568);
  static const Color textGrey = Color(0xFF8896A5);
  static const Color divClr = Color(0xFFF0F4F8);
  static const Color cardBg = Color(0xFFF8FAFD);

  final ScrollController _scrollCtrl = ScrollController();
  final ValueNotifier<bool> _isScrolled = ValueNotifier(false);
  final ValueNotifier<int> _photoIdx = ValueNotifier(0);

  late DetailController ctrl;
  late HomeController homeCtrl;
  late Property property;

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<DetailController>()
        ? Get.find<DetailController>()
        : Get.put(DetailController());
    homeCtrl = Get.find<HomeController>();
    property = Get.arguments as Property;
    _scrollCtrl.addListener(() => _isScrolled.value = _scrollCtrl.offset > 260);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _isScrolled.dispose();
    _photoIdx.dispose();
    super.dispose();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  String _formatHarga(String angka) {
    final n = int.tryParse(angka) ?? 0;
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  // ─── Fasilitas chip (besar, untuk fasilitas umum) ─────────────────────────
  Widget _fasChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Color(0xFFE8F1FD),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Color(0xFFBDD8FA)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_rounded,
          size: 13,
          color: AppColor.primary,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColor.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _buildFasWrap(List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((f) => _fasChip(f.toString())).toList(),
    );
  }

  // ─── Mini chip (fasilitas kamar dalam card tipe) ──────────────────────────
  Widget _miniChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F4FF),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Color(0xFFD0DEFF)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF4A68C4),
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  // ─── Gender badge ─────────────────────────────────────────────────────────
  Widget _genderBadge(String gender) {
    if (gender.isEmpty) return const SizedBox.shrink();
    final g = gender.toLowerCase();
    final isCampur = g.contains('campur');
    final isPutra = g.contains('putra') || g.contains('laki');

    Color bg, border, text;
    IconData icon;

    if (isCampur) {
      bg = const Color(0xFFFFF3E0);
      border = const Color(0xFFFFCC80);
      text = const Color(0xFFE65100);
      icon = Icons.people_rounded;
    } else if (isPutra) {
      bg = const Color(0xFFE3F2FD);
      border = const Color(0xFF90CAF9);
      text = const Color(0xFF1565C0);
      icon = Icons.male_rounded;
    } else {
      bg = const Color(0xFFFCE4EC);
      border = const Color(0xFFF48FB1);
      text = const Color(0xFFC62828);
      icon = Icons.female_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: text),
          const SizedBox(width: 4),
          Text(
            gender.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section title ────────────────────────────────────────────────────────
  Widget _sectionTitle(String t, {IconData? icon}) => Row(
    children: [
      if (icon != null) ...[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Color(0xFFE8F1FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColor.primary),
        ),
        const SizedBox(width: 10),
      ],
      Text(
        t,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
    ],
  );

  Widget _divider() => Container(
    height: 1,
    color: divClr,
    margin: const EdgeInsets.symmetric(vertical: 20),
  );

  // ─── Ulasan bottom sheet ──────────────────────────────────────────────────
  void _showUlasanSheet(UlasanController uc, String tipe, int id) {
    uc.selectedRating.value = 0;
    uc.komentarCtrl.clear();
    uc.isAnonymous.value = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tulis Ulasan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Rating",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () => uc.selectedRating.value = i + 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(
                            i < uc.selectedRating.value
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Komentar",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: uc.komentarCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: "Ceritakan pengalamanmu tinggal di sini...",
                    hintStyle: const TextStyle(color: textGrey, fontSize: 13),
                    filled: true,
                    fillColor: cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColor.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => GestureDetector(
                    onTap: () => uc.isAnonymous.value = !uc.isAnonymous.value,
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: uc.isAnonymous.value
                                ? AppColor.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: uc.isAnonymous.value
                                  ? AppColor.primary
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: uc.isAnonymous.value
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 15,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Sembunyikan nama (Anonim)",
                          style: TextStyle(fontSize: 13, color: textDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: uc.isSubmitting.value
                          ? null
                          : () => uc.kirimUlasan(tipe: tipe, propertiId: id),
                      child: uc.isSubmitting.value
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              "Kirim Ulasan",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        final data = ctrl.detail.value;
        if (data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
          );
        }
        return Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                children: [_buildHero(data['fotos'] ?? ''), _buildBody(data)],
              ),
            ),
            _buildAppBar(data),
            _buildBottomBar(data),
          ],
        );
      }),
    );
  }

  // ─── Hero image ───────────────────────────────────────────────────────────
  Widget _buildHero(dynamic foto) {
    List<String> photos = [];
    if (foto is List)
      photos = foto.map((e) => e.toString()).toList();
    else if (foto is String && foto.isNotEmpty)
      photos = [foto];
    if (photos.isEmpty) photos = ['https://via.placeholder.com/400x300'];

    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: photos.length,
            options: CarouselOptions(
              height: 340,
              viewportFraction: 1,
              enlargeCenterPage: false,
              enableInfiniteScroll: photos.length > 1,
              autoPlay: photos.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              onPageChanged: (i, _) => _photoIdx.value = i,
            ),
            itemBuilder: (ctx, i, _) => GestureDetector(
              onTap: () => Get.to(
                () => FullscreenGallery(images: photos, initialIndex: i),
              ),
              child: Hero(
                tag: photos[i],
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: Image.network(
                    photos[i],
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, p) => p == null
                        ? child
                        : const Center(child: CircularProgressIndicator()),
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.broken_image,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
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
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xCC000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // Dots
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _photoIdx,
              builder: (_, idx, __) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == idx ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == idx
                          ? Colors.white
                          : Colors.white.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Counter pill
          Positioned(
            right: 16,
            bottom: 48,
            child: ValueListenableBuilder<int>(
              valueListenable: _photoIdx,
              builder: (_, idx, __) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${idx + 1} / ${photos.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── App bar (sticky) ─────────────────────────────────────────────────────
  Widget _buildAppBar(Map<String, dynamic> data) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isScrolled,
      builder: (_, scrolled, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: scrolled ? Colors.white : Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _appBarBtn(
                  Icons.arrow_back_ios_new_rounded,
                  scrolled,
                  () => Get.back(),
                ),
                Row(
                  children: [
                    _appBarBtn(
                      Icons.share_rounded,
                      scrolled,
                      () => _share(data),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final isFav = homeCtrl.isFavorite(property);
                      return _appBarBtn(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        scrolled,
                        () => homeCtrl.toggleFavorite(property),
                        iconColor: isFav ? Colors.red : null,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBarBtn(
    IconData icon,
    bool scrolled,
    VoidCallback onTap, {
    Color? iconColor,
  }) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scrolled
            ? const Color(0xFFF1F5F9)
            : Colors.black.withOpacity(0.35),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: iconColor ?? (scrolled ? textDark : Colors.white),
      ),
    ),
  );

  // ─── Body ─────────────────────────────────────────────────────────────────
  Widget _buildBody(Map<String, dynamic> data) {
    final tipe = data['tipe'] ?? '';
    final gender = data['gender']?.toString() ?? '';
    final lat = double.tryParse(data['lat']?.toString() ?? '0');
    final lng = double.tryParse(data['lng']?.toString() ?? '0');

    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 14, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Badges row
                  Row(
                    children: [
                      _typeBadge(tipe),
                      if (gender.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _genderBadge(gender),
                      ],
                      const Spacer(),
                      _ratingWidget(data),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Nama
                  Text(
                    data['nama'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.2,
                      color: textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Alamat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColor.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['alamat'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textMid,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Konten tipe
            _divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: tipe == 'Kosan'
                  ? _buildKosanSection(data)
                  : _buildKontrakanSection(data),
            ),

            // ── Lokasi
            _divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle("Lokasi", icon: Icons.map_rounded),
                      GestureDetector(
                        onTap: () => _openMaps(lat, lng, data['nama'] ?? ''),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F1FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 13,
                                color: AppColor.primary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Buka Maps",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColor.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildMapCard(
                    lat,
                    lng,
                    data['nama'] ?? '',
                    data['alamat'] ?? '',
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: textGrey,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          data['alamat'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            height: 1.4,
                            color: textGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Peraturan (setelah map)
            if ((data['peraturan'] ?? '').isNotEmpty) ...[
              _divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Peraturan", icon: Icons.rule_rounded),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Text(
                        data['peraturan'],
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Ulasan
            _divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildUlasanSection(data),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ratingWidget(Map<String, dynamic> data) {
    final uc = Get.isRegistered<UlasanController>()
        ? Get.find<UlasanController>()
        : null;
    return Obx(() {
      final rating = uc != null && uc.totalUlasan.value > 0
          ? uc.rataRating.value.toStringAsFixed(1)
          : (data['rating']?.toString() ?? '0');
      final total = uc?.totalUlasan.value ?? 0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              rating,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF795548),
              ),
            ),
            if (total > 0) ...[
              const SizedBox(width: 3),
              Text(
                "($total)",
                style: const TextStyle(fontSize: 11, color: Color(0xFFA1887F)),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ─── Kosan section ────────────────────────────────────────────────────────
  Widget _buildKosanSection(Map<String, dynamic> data) {
    final fasUmum = data['fasilitas_umum'] is List
        ? List<dynamic>.from(data['fasilitas_umum'])
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fasilitas Umum
        if (fasUmum.isNotEmpty) ...[
          _sectionTitle("Fasilitas Umum", icon: Icons.apartment_rounded),
          const SizedBox(height: 12),
          _buildFasWrap(fasUmum),
          _divider(),
        ],

        // Tipe kamar
        Obx(() {
          final roomTypes = ctrl.roomTypes;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("Pilih Tipe Kamar", icon: Icons.bed_rounded),
              const SizedBox(height: 12),

              ...roomTypes.map<Widget>((tipe) {
                final isSel = ctrl.selectedRoomTypeId.value == tipe['id'];
                final fas = tipe['fasilitas'] is List
                    ? List<dynamic>.from(tipe['fasilitas'])
                    : <dynamic>[];

                return GestureDetector(
                  onTap: () => ctrl.selectRoomType(tipe['id']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isSel ? Color(0xFFE8F1FD) : cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel
                            ? AppColor.primary
                            : const Color(0xFFE2E8F0),
                        width: isSel ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColor.primary
                                      : Color(0xFFE8EEF8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.bed_rounded,
                                  size: 20,
                                  color: isSel ? Colors.white : AppColor.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tipe['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isSel
                                            ? AppColor.primary
                                            : textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color:
                                                (tipe['available_count'] ?? 0) >
                                                    0
                                                ? const Color(0xFF22C55E)
                                                : Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${tipe['available_count']} kamar tersedia',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color:
                                                (tipe['available_count'] ?? 0) >
                                                    0
                                                ? const Color(0xFF16A34A)
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rp ${_formatHarga(tipe['price'].toString())}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isSel
                                          ? AppColor.primary
                                          : textDark,
                                    ),
                                  ),
                                  Text(
                                    '/ bulan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSel
                                          ? AppColor.primary.withOpacity(0.7)
                                          : textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Fasilitas tipe
                        if (fas.isNotEmpty) ...[
                          Container(
                            height: 1,
                            color: isSel ? Color(0xFFBDD8FA) : divClr,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: fas
                                  .map((f) => _miniChip(f.toString()))
                                  .toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),

              // Grid nomor kamar
              if (ctrl.selectedRoomTypeId.value != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divClr),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Pilih Nomor Kamar",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          Row(
                            children: [
                              _legendDot(true, "Tersedia"),
                              const SizedBox(width: 12),
                              _legendDot(false, "Terisi"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 4,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.2,
                        children: ctrl
                            .roomsForType(ctrl.selectedRoomTypeId.value!)
                            .map<Widget>((kamar) {
                              final avail = kamar['status'] == 'tersedia';
                              final isSel =
                                  ctrl.selectedRoomId.value == kamar['id'];
                              return GestureDetector(
                                onTap: avail
                                    ? () => ctrl.selectRoom(kamar['id'])
                                    : null,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSel
                                        ? AppColor.primary
                                        : avail
                                        ? Colors.white
                                        : const Color(0xFFF1F4F8),
                                    border: Border.all(
                                      color: isSel
                                          ? AppColor.primary
                                          : avail
                                          ? Color(0xFFBDD8FA)
                                          : const Color(0xFFD8DEE6),
                                      width: isSel ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      kamar['number'] ?? '',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isSel
                                            ? Colors.white
                                            : avail
                                            ? AppColor.primary
                                            : textGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  // ─── Kontrakan section ────────────────────────────────────────────────────
  Widget _buildKontrakanSection(Map<String, dynamic> data) {
    final fas = data['fasilitas'] is List
        ? List<dynamic>.from(data['fasilitas'])
        : <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fas.isNotEmpty) ...[
          _sectionTitle("Fasilitas", icon: Icons.home_work_rounded),
          const SizedBox(height: 12),
          _buildFasWrap(fas),
          _divider(),
        ],

        _sectionTitle("Harga Sewa", icon: Icons.payments_rounded),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColor.primary, AppColor.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColor.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rp ${_formatHarga(data['harga']?.toString() ?? '0')}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'per tahun',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        if ((data['sisa_kamar'] ?? 0) > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF6EE7B7)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 7),
                Text(
                  '${data['sisa_kamar']} unit tersedia',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUlasanSection(Map<String, dynamic> data) {
    final UlasanController uc = Get.isRegistered<UlasanController>()
        ? Get.find<UlasanController>()
        : Get.put(UlasanController());
    final tipe = (data['tipe']?.toString() ?? '').toLowerCase();
    final id = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '') ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Ulasan", icon: Icons.reviews_rounded),
                Obx(
                  () => Text(
                    '${uc.totalUlasan.value} ulasan  ·  ⭐ ${uc.rataRating.value.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12, color: textGrey),
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!uc.bolehReview.value) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () => _showUlasanSheet(uc, tipe, id),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        "Tulis Ulasan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (uc.isLoading.value)
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          if (uc.ulasanList.isEmpty)
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: divClr),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 36,
                      color: Color(0xFFCBD5E1),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Belum ada ulasan",
                      style: TextStyle(color: textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          return Column(
            children: uc.ulasanList
                .map(
                  (u) => ReviewCard(
                    name: u['nama_user'] ?? 'Anonim',
                    time: u['created_at'] ?? '',
                    comment: u['komentar'] ?? '',
                    rating: (u['rating'] as num?)?.toInt() ?? 0,
                    avatar: u['foto_user'],
                    balasanPemilik: u['balasan_pemilik'],
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildMapCard(double? lat, double? lng, String nama, String alamat) {
    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "Lokasi tidak tersedia",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    final point = LatLng(lat, lng);
    return GestureDetector(
      onTap: () => _openMaps(lat, lng, nama),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.appkonkos_mobile',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          color: AppColor.primary,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Buka di Google Maps",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Bottom bar ───────────────────────────────────────────────────────────
  Widget _buildBottomBar(Map<String, dynamic> data) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // WA button
              GestureDetector(
                onTap: () async {
                  String noWa = data['no_wa']?.toString() ?? '';
                  if (noWa.isEmpty) {
                    Get.snackbar(
                      "Oops",
                      "Nomor WhatsApp tidak tersedia",
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }
                  if (noWa.startsWith('0')) noWa = '62${noWa.substring(1)}';
                  final pesan =
                      "Halo, saya tertarik dengan ${data['nama']} yang ada di AppKonkos.";
                  final uri = Uri.parse(
                    "https://api.whatsapp.com/send?phone=$noWa&text=${Uri.encodeComponent(pesan)}",
                  );
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    Get.snackbar(
                      "Error",
                      "WhatsApp tidak ditemukan",
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: AppColor.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Image(
                    image: AssetImage("assets/image/wa.png"),
                    height: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Book button
              Expanded(
                child: Obx(
                  () => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctrl.canBook
                            ? AppColor.primary
                            : Colors.grey.shade300,
                        elevation: ctrl.canBook ? 0 : 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: ctrl.canBook ? () => _onBook(data) : null,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data['tipe'] == 'Kosan' &&
                                    ctrl.selectedRoomId.value == null
                                ? Icons.bed_outlined
                                : Icons.calendar_month_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['tipe'] == 'Kosan' &&
                                    ctrl.selectedRoomId.value == null
                                ? "Pilih Kamar Dulu"
                                : "Pesan Sekarang",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onBook(Map<String, dynamic> data) {
    final tipe = data['tipe']?.toString().toLowerCase() ?? '';
    if (tipe == 'kontrakan') {
      BookingBottomSheet.show(
        kamarId: null,
        kontrakanId: data['id']?.toString(),
        kamarNama: data['nama'] ?? 'Kontrakan',
        hargaPerBulan: int.tryParse(data['harga']?.toString() ?? '0') ?? 0,
        tipeKamarNama: 'Kontrakan',
        tipeProperty: data['tipe'],
      );
      return;
    }
    final sel = ctrl.roomTypes.firstWhereOrNull(
      (t) => t['id'] == ctrl.selectedRoomTypeId.value,
    );
    final kamarNo =
        ctrl
            .roomsForType(ctrl.selectedRoomTypeId.value!)
            .firstWhereOrNull(
              (r) => r['id'] == ctrl.selectedRoomId.value,
            )?['number']
            ?.toString() ??
        '';
    BookingBottomSheet.show(
      kamarId: ctrl.selectedRoomId.value.toString(),
      kamarNama: kamarNo,
      hargaPerBulan: int.tryParse(sel?['price']?.toString() ?? '0') ?? 0,
      tipeKamarNama: sel?['name']?.toString() ?? '',
      tipeProperty: data['tipe'],
    );
  }

  // ─── Misc helpers ─────────────────────────────────────────────────────────
  Widget _typeBadge(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Color(0xFFE8F1FD),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Color(0xFFBDD8FA)),
    ),
    child: Text(
      type.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 0.7,
        color: AppColor.primary,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  Widget _legendDot(bool avail, String label) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: avail ? Colors.white : const Color(0xFFE9EEF3),
          border: Border.all(
            color: avail ? AppColor.primary : const Color(0xFFD4DCE5),
            width: 2,
          ),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: textGrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Future<void> _openMaps(double? lat, double? lng, String nama) async {
    if (lat == null || lng == null) return;
    final uri = Uri.parse('google.navigation:q=$lat,$lng');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    else
      await launchUrl(
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
        mode: LaunchMode.externalApplication,
      );
  }

  void _share(Map<String, dynamic> data) {
    final tipe = data['tipe'] ?? '';
    final harga = tipe == 'Kosan'
        ? 'Mulai dari Rp ${_formatHarga(data['room_types']?.isNotEmpty == true ? data['room_types'][0]['price'].toString() : '0')}/bulan'
        : 'Rp ${_formatHarga(data['harga']?.toString() ?? '0')}/tahun';
    Share.share(
      '🏠 *${data['nama']}*\n📍 ${data['alamat']}\n💰 $harga\n🏷️ Tipe: $tipe\n\n'
      'Temukan hunian impianmu di AppKonkos!\n👉 https://github.com/faldyardiansyah/mobile_proyek/releases/tag/v1.1.1',
      subject: 'Properti: ${data['nama']}',
    );
  }
}
