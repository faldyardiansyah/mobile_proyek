import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/property_model.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../widgets/facility_item.dart';
import '../widgets/room_item.dart';
import '../widgets/review_card.dart';
import '../widgets/map_line.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  static const Color blue = Color(0xFF007BC2);
  static const Color lightBlue = Color(0xFFEAF6FF);
  static const Color softBlue = Color(0xFFF1F8FF);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
    final Property data = Get.arguments as Property;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildHeaderImage(data),
                      _buildTopButtons(),
                      Positioned(
                        right: 20,
                        bottom: 18,
                        child: _photoCounter(),
                      ),
                      Positioned(
                        top: 315,
                        left: 0,
                        right: 0,
                        child: _buildContentCard(data),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1070),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage(Property data) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Image.network(
        data.foto,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, size: 60, color: Colors.grey),
          );
        },
      ),
    );
  }

  Widget _buildTopButtons() {
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
              _circleButton(
                icon: Icons.share_outlined,
                onTap: () {},
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

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
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
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContentCard(Property data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _typeBadge(data.type),
              Row(
                children: [
                  const Icon(Icons.star_border, color: Colors.orange, size: 17),
                  const SizedBox(width: 4),
                  Text(
                    data.rating.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    "(128 Ulasan)",
                    style: TextStyle(
                      fontSize: 12,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            data.name,
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
              const Icon(
                Icons.location_on_outlined,
                color: blue,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                data.location,
                style: const TextStyle(
                  fontSize: 13,
                  color: textGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            "Fasilitas Utama",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FacilityItem(icon: Icons.wifi, title: "Free WiFi"),
              FacilityItem(icon: Icons.ac_unit, title: "AC Dingin"),
              FacilityItem(icon: Icons.bed_outlined, title: "Kasur"),
              FacilityItem(icon: Icons.wc, title: "KM Dalam"),
            ],
          ),
          const SizedBox(height: 32),

          const Text(
            "Deskripsi",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),

          const SizedBox(height: 13),

          const Text(
            "Hunian nyaman dan asri dengan fasilitas lengkap yang memanjakan penghuninya. Berlokasi strategis di Jakarta Selatan, dekat dengan stasiun MRT dan pusat perbelanjaan.",
            style: TextStyle(
              fontSize: 13.5,
              height: 1.7,
              color: Color(0xFF536273),
            ),
          ),

          const SizedBox(height: 8),

          InkWell(
            onTap: () {},
            child: const Text(
              "Baca Selengkapnya",
              style: TextStyle(
                fontSize: 13,
                color: blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ketersediaan Kamar",
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

          const SizedBox(height: 14),

          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.16,
            children: const [
              RoomItem(room: "A1", available: true),
              RoomItem(room: "A2", available: false),
              RoomItem(room: "A3", available: true),
              RoomItem(room: "A4", available: false),
              RoomItem(room: "B1", available: true),
              RoomItem(room: "B2", available: true),
              RoomItem(room: "B3", available: false),
              RoomItem(room: "B4", available: false),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Lokasi Kost",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Text(
                "Buka di Maps",
                style: TextStyle(
                  fontSize: 12,
                  color: blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _mapCard(),

          const SizedBox(height: 12),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 15,
                color: Color(0xFF718096),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Jl. H. Nawi Raya No. 12, Gandaria Selatan, Cilandak, Jakarta Selatan",
                  style: TextStyle(
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
                '"Tempatnya bersih banget! Ibu kostnya juga ramah parah. Worth it banget buat harga segini di Jaksel."',
            rating: 5,
            avatar:
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200",
          ),

          const SizedBox(height: 12),

          const ReviewCard(
            name: "Sarah Wijaya",
            time: "1 minggu yang lalu",
            comment:
                '"Fasilitas sesuai deskripsi. WiFi kenceng buat WFH. Cuma parkiran mobil agak sempit kalo penuh."',
            rating: 4,
            avatar:
                "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200",
          ),
        ],
      ),
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
              width: 1,
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.location_on_outlined,
                    color: blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Lihat Maps",
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade100,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
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
                  border: Border.all(
                    color: blue.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      elevation: 4,
                      shadowColor: AppColor.primary.withOpacity(0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: () {},
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Pesan Sekarang",
                          style: TextStyle(
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
            ],
          ),
        ),
      ),
    );
  }
}