import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../controllers/detail_controller.dart';
import '../widgets/map_line.dart';
import '../widgets/review_card.dart';


class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  static const Color blue = Color(0xFF007BC2);
  static const Color lightBlue = Color(0xFFEAF6FF);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
     final ctrl = Get.put(DetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = ctrl.detail.value;
          if (data == null) {
            return Center(child:Padding(
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
                        const Text("Data tidak ditemukan",style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ));  
          }
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildHeaderImage(data['foto'] ?? ''),
                        _buildTopButtons(data),
                        Positioned(
                          right: 20,
                          bottom: 18,
                          child: _photoCounter(),
                        ),
                        Positioned(
                          top: 315,
                          left: 0,
                          right: 0,
                          child: _buildContentCard(ctrl, data),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1200),
                  ],
                ),
              ),
              _buildBottomBar(ctrl, data),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeaderImage(String foto) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Image.network(
        foto,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade200,
          child: const Icon(Icons.image, size: 60, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildTopButtons(Map<String, dynamic> data) {
    return Positioned(
      top: 45,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Get.back(),
          ),
          Row(
            children: [
              // Tombol Share
              _circleButton(
                icon: Icons.share_outlined,
                onTap: () => _shareProperty(data),
              ),
              const SizedBox(width: 12),
              _circleButton(
                icon: Icons.favorite_border,
                onTap: () {},
              ),
            ],
          ),
        ],
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
    const apkLink = 'https://github.com/faldyardiansyah/mobile_proyek/releases/tag/v1.1.1'; 

    final text = '''🏠 *$nama*
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

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _photoCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "1 / 8 Photos",
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildContentCard(DetailController ctrl, Map<String, dynamic> data) {
    final tipe = data['tipe'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 45, height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // Badge tipe + rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _typeBadge(tipe),
              Row(
                children: [
                  const Icon(Icons.star_border, color: Colors.orange, size: 17),
                  const SizedBox(width: 4),
                  Text(
                    data['rating']?.toString() ?? '0',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textDark),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),
          Text(
            data['nama'] ?? '',
            style: const TextStyle(fontSize: 22, height: 1.2, color: textDark, fontWeight: FontWeight.w800),
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

          // Peraturan (jika ada)
          if ((data['peraturan'] ?? '').isNotEmpty) ...[
            const Text(
              "Peraturan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textDark),
            ),
            const SizedBox(height: 8),
            Text(
              data['peraturan'],
              style: const TextStyle(fontSize: 13.5, height: 1.7, color: Color(0xFF536273)),
            ),
            const SizedBox(height: 24),
          ],
          
          if (tipe == 'Kosan')
            _buildKosanSection(ctrl, data)
          else
            _buildKontrakanSection(data),

          const SizedBox(height: 30),

          // Lokasi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Lokasi",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
              ),
              Text(
                "Buka di Maps",
                style: TextStyle(fontSize: 12, color: blue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _mapCard(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 15, color: Color(0xFF718096)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data['alamat'] ?? '',
                  style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF718096)),
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
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
              ),
              Text(
                "Lihat Semua",
                style: TextStyle(fontSize: 12, color: blue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const ReviewCard(
            name: "Budi Santoso",
            time: "2 hari yang lalu",
            comment: '"Tempatnya bersih banget! Worth it banget buat harga segini."',
            rating: 5,
            avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
          ),
        ],
      ),
    );
  }

  // ===== SECTION KOSAN: pilih tipe kamar + nomor kamar =====
  Widget _buildKosanSection(DetailController ctrl, Map<String, dynamic> data) {
    return Obx(() {
      final roomTypes = ctrl.roomTypes;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilih Tipe Kamar",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
          ),
          const SizedBox(height: 12),

          // Chips tipe kamar
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: roomTypes.map<Widget>((tipe) {
              final isSelected = ctrl.selectedRoomTypeId.value == tipe['id'];
              return GestureDetector(
                onTap: () => ctrl.selectRoomType(tipe['id']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

          // Pilih nomor kamar (muncul setelah pilih tipe)
          if (ctrl.selectedRoomTypeId.value != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pilih Nomor Kamar",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
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
              children: ctrl.roomsForType(ctrl.selectedRoomTypeId.value!).map<Widget>((kamar) {
                final isAvailable = kamar['status'] == 'tersedia';
                final isSelected = ctrl.selectedRoomId.value == kamar['id'];
                return GestureDetector(
                  onTap: isAvailable ? () => ctrl.selectRoom(kamar['id']) : null,
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
              }).toList(),
            ),
          ],
        ],
      );
    });
  }

  // ===== SECTION KONTRAKAN: harga langsung tanpa pilih kamar =====
  Widget _buildKontrakanSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Harga Sewa",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: textDark),
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
          fontSize: 11, letterSpacing: 0.7, color: blue, fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _legendItem(bool available, String text) {
    return Row(
      children: [
        Container(
          height: 9, width: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: available ? Colors.white : const Color(0xFFE9EEF3),
            border: Border.all(
              color: available ? blue : const Color(0xFFD4DCE5),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 8, color: textGrey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _mapCard() {
    return Container(
      height: 135,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFBFC7CE),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 135),
            painter: MapLinePainter(),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined, color: blue, size: 20),
                  SizedBox(width: 8),
                  Text("Lihat Maps", style: TextStyle(color: blue, fontWeight: FontWeight.w800, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DetailController ctrl, Map<String, dynamic> data) {
    return Positioned(
      left: 0, right: 0, bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: blue.withOpacity(0.35), width: 1.5),
                ),
                child: const Icon(Icons.chat_bubble_outline, color: blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ctrl.canBook ? AppColor.primary : Colors.grey.shade400,
                      elevation: ctrl.canBook ? 4 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                    ),
                    onPressed: ctrl.canBook ? () {
                      // navigasi ke halaman booking
                      // Get.to(() => BookingScreen(), arguments: {
                      //   'properti': data,
                      //   'room_id': ctrl.selectedRoomId.value,
                      // });
                    } : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          data['tipe'] == 'Kosan' && ctrl.selectedRoomId.value == null
                              ? "Pilih Kamar Dulu"
                              : "Pesan Sekarang",
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}