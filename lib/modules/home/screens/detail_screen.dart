import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:share_plus/share_plus.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../controllers/detail_controller.dart';
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
  static const Color blue = Color(0xFF007BC2);
  static const Color lightBlue = Color(0xFFEAF6FF);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

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

    _scrollCtrl.addListener(() {
      _isScrolled.value = _scrollCtrl.offset > 260;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _isScrolled.dispose();
    _photoIdx.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
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
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeaderImage(data['fotos'] ?? ''),
                      // counter foto
                      Positioned(
                        right: 20,
                        bottom: 55,
                        child: ValueListenableBuilder<int>(
                          valueListenable: _photoIdx,
                          builder: (_, idx, __) {
                            final foto = data['fotos'];
                            int total = 1;
                            if (foto is List) {
                              total = foto.length;
                            } else if (foto is String && foto.isNotEmpty) {
                              total = 1;
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${idx + 1} / $total",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildContentCard(ctrl, data),
                ],
              ),
            ),
            _buildStickyHeader(data),
            _buildBottomBar(ctrl, data),
          ],
        );
      }),
    );
  }

  Widget _buildHeaderImage(dynamic foto) {
    List<String> photos = [];

    if (foto is List) {
      photos = foto.map((e) => e.toString()).toList();
    } else if (foto is String && foto.isNotEmpty) {
      photos = [foto];
    }

    if (photos.isEmpty) {
      photos = ['https://via.placeholder.com/400x300'];
    }

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
              onPageChanged: (index, reason) {
                _photoIdx.value = index;
              },
            ),
            itemBuilder: (context, index, realIndex) {
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () =>
                        FullscreenGallery(images: photos, initialIndex: index),
                  );
                },
                child: Hero(
                  tag: photos[index],
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // gradient bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),

          // indicator
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<int>(
              valueListenable: _photoIdx,
              builder: (_, idx, __) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    photos.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == idx ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == idx
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(Map<String, dynamic> data) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isScrolled,
      builder: (_, isScrolled, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: isScrolled ? Colors.white : Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _stickyButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  isScrolled: isScrolled,
                  onTap: () => Get.back(),
                ),
                Row(
                  children: [
                    _stickyButton(
                      icon: Icons.share_rounded,
                      isScrolled: isScrolled,
                      onTap: () => _shareProperty(data),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      final isFav = homeCtrl.isFavorite(property);
                      return _stickyButton(
                        icon: isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        isScrolled: isScrolled,
                        iconColor: isFav
                            ? Colors.red
                            : (isScrolled ? textDark : Colors.white),
                        onTap: () => homeCtrl.toggleFavorite(property),
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

  Widget _stickyButton({
    required IconData icon,
    required bool isScrolled,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: isScrolled
              ? const Color(0xFFF1F5F9)
              : Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor ?? (isScrolled ? textDark : Colors.white),
          size: 20,
        ),
      ),
    );
  }

  void _shareProperty(Map<String, dynamic> data) {
    final nama = data['nama'] ?? '';
    final alamat = data['alamat'] ?? '';
    final tipe = data['tipe'] ?? '';
    final harga = tipe == 'Kosan'
        ? 'Mulai dari Rp ${_formatHarga(data['room_types']?.isNotEmpty == true ? data['room_types'][0]['price'].toString() : '0')}/bulan'
        : 'Rp ${_formatHarga(data['harga']?.toString() ?? '0')}/tahun';
    const apkLink =
        'https://github.com/faldyardiansyah/mobile_proyek/releases/tag/v1.1.1';

    final text =
        '''🏠 *$nama*
📍 $alamat
💰 $harga
🏷️ Tipe: $tipe

Temukan hunian impianmu di AppKonkos!
👉 Buka app untuk detail lengkap $apkLink''';

    Share.share(text, subject: 'Properti: $nama');
  }

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Widget _buildContentCard(DetailController ctrl, Map<String, dynamic> data) {
    final tipe = data['tipe'] ?? '';
    final lat = double.tryParse(data['lat']?.toString() ?? '0');
    final lng = double.tryParse(data['lng']?.toString() ?? '0');

    return Transform.translate(
      offset: const Offset(0, -24),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _typeBadge(tipe),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_border,
                        color: Colors.orange,
                        size: 17,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        data['rating']?.toString() ?? '0',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
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
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: blue, size: 18),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      data['alamat'] ?? '',
                      style: const TextStyle(fontSize: 13, color: textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if ((data['peraturan'] ?? '').isNotEmpty) ...[
                const Text(
                  "Peraturan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['peraturan'],
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.7,
                    color: Color(0xFF536273),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (tipe == 'Kosan')
                _buildKosanSection(ctrl, data)
              else
                _buildKontrakanSection(data),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Lokasi",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openGoogleMaps(lat, lng, data['nama'] ?? ''),
                    child: const Text(
                      "Buka di Maps",
                      style: TextStyle(
                        fontSize: 12,
                        color: blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMapCard(lat, lng, data['nama'] ?? '', data['alamat'] ?? ''),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 15,
                    color: Color(0xFF718096),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data['alamat'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Ulasan & Komentar",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontSize: 12,
                      color: blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const ReviewCard(
                name: "Budi Santoso",
                time: "2 hari yang lalu",
                comment:
                    '"Tempatnya bersih banget! Worth it banget buat harga segini."',
                rating: 5,
                avatar:
                    "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKosanSection(DetailController ctrl, Map<String, dynamic> data) {
    return Obx(() {
      final roomTypes = ctrl.roomTypes;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilih Tipe Kamar",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: roomTypes.map<Widget>((tipe) {
              final isSelected = ctrl.selectedRoomTypeId.value == tipe['id'];
              return GestureDetector(
                onTap: () => ctrl.selectRoomType(tipe['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? blue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? blue : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipe['name'] ?? '',
                        style: TextStyle(
                          color: isSelected ? Colors.white : textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Rp ${_formatHarga(tipe['price'].toString())}/bln',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : textGrey,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '${tipe['available_count']} kamar tersedia',
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.green,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (ctrl.selectedRoomTypeId.value != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pilih Nomor Kamar",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                Row(
                  children: [
                    _legendItem(true, "TERSEDIA"),
                    const SizedBox(width: 10),
                    _legendItem(false, "TERISI"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.16,
              children: ctrl
                  .roomsForType(ctrl.selectedRoomTypeId.value!)
                  .map<Widget>((kamar) {
                    final isAvailable = kamar['status'] == 'tersedia';
                    final isSelected = ctrl.selectedRoomId.value == kamar['id'];
                    return GestureDetector(
                      onTap: isAvailable
                          ? () => ctrl.selectRoom(kamar['id'])
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected
                              ? blue
                              : isAvailable
                              ? Colors.white
                              : const Color(0xFFE9EEF3),
                          border: Border.all(
                            color: isSelected
                                ? blue
                                : isAvailable
                                ? const Color(0xFFD1E8FF)
                                : const Color(0xFFD4DCE5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            kamar['number'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : isAvailable
                                  ? blue
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
        ],
      );
    });
  }

  Widget _buildKontrakanSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Harga Sewa",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB8DCFF)),
          ),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, color: blue, size: 32),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rp ${_formatHarga(data['harga']?.toString() ?? '0')}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: blue,
                    ),
                  ),
                  const Text(
                    'per tahun',
                    style: TextStyle(fontSize: 13, color: textGrey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _typeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.7,
          color: blue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _legendItem(bool available, String text) {
    return Row(
      children: [
        Container(
          height: 9,
          width: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? Colors.white : const Color(0xFFE9EEF3),
            border: Border.all(
              color: available ? blue : const Color(0xFFD4DCE5),
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 8,
            color: textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _openGoogleMaps(double? lat, double? lng, String nama) async {
    if (lat == null || lng == null) return;
    final googleMapsUrl = 'google.navigation:q=$lat,$lng';
    final uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final webUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMapCard(double? lat, double? lng, String nama, String alamat) {
    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
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
      onTap: () => _openGoogleMaps(lat, lng, nama),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
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
                          Icons.location_on,
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
                        Icon(Icons.open_in_new, color: blue, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Buka di Google Maps",
                          style: TextStyle(
                            color: blue,
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

  Widget _buildBottomBar(DetailController ctrl, Map<String, dynamic> data) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: blue.withOpacity(0.35), width: 1.5),
                ),
                child: GestureDetector(
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

                    // ubah 08 jadi 628
                    if (noWa.startsWith('0')) {
                      noWa = '62${noWa.substring(1)}';
                    }

                    final pesan =
                        "Halo, saya tertarik dengan ${data['nama']} yang ada di AppKonkos.";

                    final uri = Uri.parse(
                      "https://api.whatsapp.com/send?phone=$noWa&text=${Uri.encodeComponent(pesan)}",
                    );

                    try {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      print("ERROR WA: $e");

                      Get.snackbar(
                        "Error",
                        "WhatsApp tidak ditemukan",
                        snackPosition: SnackPosition.TOP,
                      );
                    }
                  },
                  child: const Image(
                    image: AssetImage("assets/image/wa.png"),
                    height: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctrl.canBook
                            ? AppColor.primary
                            : Colors.grey.shade400,
                        elevation: ctrl.canBook ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: ctrl.canBook
                          ? () {
                              final tipe =
                                  data['tipe']?.toString().toLowerCase() ?? '';
                              if (tipe == 'kontrakan') {
                                final harga =
                                    int.tryParse(
                                      data['harga']?.toString() ?? '0',
                                    ) ??
                                    0;

                                BookingBottomSheet.show(
                                  kamarId: null,
                                  kontrakanId: data['id']?.toString(),
                                  kamarNama: data['nama'] ?? 'Kontrakan',
                                  hargaPerBulan: harga,
                                  tipeKamarNama: 'Kontrakan',
                                  tipeProperty: data['tipe'],
                                );
                                return;
                              }
                              final roomTypes = ctrl.roomTypes;
                              final selectedTypeId =
                                  ctrl.selectedRoomTypeId.value;
                              final selectedRoomId = ctrl.selectedRoomId.value;
                              final selectedType = roomTypes.firstWhereOrNull(
                                (t) => t['id'] == selectedTypeId,
                              );

                              final kamarNama =
                                  ctrl
                                      .roomsForType(selectedTypeId!)
                                      .firstWhereOrNull(
                                        (r) => r['id'] == selectedRoomId,
                                      )?['number']
                                      ?.toString() ??
                                  '';

                              final harga =
                                  int.tryParse(
                                    selectedType?['price']?.toString() ?? '0',
                                  ) ??
                                  0;

                              final tipeNama =
                                  selectedType?['name']?.toString() ?? '';

                              BookingBottomSheet.show(
                                kamarId: selectedRoomId.toString(),
                                kamarNama: kamarNama,
                                hargaPerBulan: harga,
                                tipeKamarNama: tipeNama,
                                tipeProperty: data['tipe'],
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            data['tipe'] == 'Kosan' &&
                                    ctrl.selectedRoomId.value == null
                                ? Icons.bed_outlined
                                : Icons.calendar_month_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
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
}
