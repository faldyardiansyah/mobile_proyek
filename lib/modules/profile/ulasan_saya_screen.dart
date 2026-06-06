import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'controllers/ulasan_saya_controller.dart';
import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:appkonkos_mobile/modules/home/controllers/ulasan_controller.dart';

class UlasanSayaScreen extends StatelessWidget {
  const UlasanSayaScreen({super.key});

  static const Color blue = Color(0xFF007BC2);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<UlasanSayaController>()
        ? Get.find<UlasanSayaController>()
        : Get.put(UlasanSayaController());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Ulasan Saya",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: textDark, size: 20),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final adaBelumReview = ctrl.bookingBelumReview.isNotEmpty;
        final adaUlasan = ctrl.ulasanList.isNotEmpty;

        if (!adaBelumReview && !adaUlasan) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "Belum ada ulasan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textGrey,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ulasan kamu akan muncul di sini\nsetelah menyelesaikan sewa.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: textGrey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadSemua,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // ===== SECTION: Menunggu Ulasan =====
              if (adaBelumReview) ...[
                Row(
                  children: [
                    Container(
                      width: 4, height: 18,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Menunggu Ulasanmu",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${ctrl.bookingBelumReview.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...ctrl.bookingBelumReview.map(
                  (b) => _buildBelumReviewCard(b, ctrl),
                ),
                const SizedBox(height: 20),
              ],

              // ===== SECTION: Ulasan yang sudah ditulis =====
              if (adaUlasan) ...[
                Row(
                  children: [
                    Container(
                      width: 4, height: 18,
                      decoration: BoxDecoration(
                        color: blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Ulasan Ditulis",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...ctrl.ulasanList.map((u) => _buildUlasanCard(u)),
              ],
            ],
          ),
        );
      }),
    );
  }

  // Card properti yang sudah lunas tapi belum direview
  Widget _buildBelumReviewCard(
      Map<String, dynamic> b, UlasanSayaController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.rate_review_outlined,
                color: Colors.orange.shade700, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b['properti_nama'] ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  (b['properti_tipe'] ?? '').toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol tulis ulasan
          GestureDetector(
            onTap: () {
              // Langsung buka bottom sheet ulasan
              _bukaFormUlasan(
                tipe: (b['properti_tipe'] ?? '').toString().toLowerCase(),
                propertiId: int.tryParse(
                        b['properti_id']?.toString() ?? '0') ??
                    0,
                propertiNama: b['properti_nama'] ?? '',
                onSelesai: () => ctrl.loadSemua(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Nilai",
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
    );
  }

  void _bukaFormUlasan({
    required String tipe,
    required int propertiId,
    required String propertiNama,
    required VoidCallback onSelesai,
  }) {
    final ulasanCtrl = Get.isRegistered<UlasanController>()
        ? Get.find<UlasanController>()
        : Get.put(UlasanController());

    ulasanCtrl.selectedRating.value = 0;
    ulasanCtrl.komentarCtrl.clear();
    ulasanCtrl.isAnonymous.value = false;

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
        
                Text(
                  "Ulasan untuk $propertiNama",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 20),
        
                const Text("Rating",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 10),
                Obx(() => Row(
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () =>
                          ulasanCtrl.selectedRating.value = i + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          i < ulasanCtrl.selectedRating.value
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.orange,
                          size: 38,
                        ),
                      ),
                    );
                  }),
                )),
        
                const SizedBox(height: 16),
                const Text("Komentar",
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: ulasanCtrl.komentarCtrl,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        "Ceritakan pengalamanmu tinggal di sini...",
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: blue, width: 1.5),
                    ),
                  ),
                ),
        
                Obx(() => Row(
                  children: [
                    Checkbox(
                      value: ulasanCtrl.isAnonymous.value,
                      activeColor: blue,
                      onChanged: (val) =>
                          ulasanCtrl.isAnonymous.value =
                              val ?? false,
                    ),
                    const Text("Kirim sebagai anonim",
                        style:
                            TextStyle(fontSize: 13, color: textGrey)),
                  ],
                )),
        
                const SizedBox(height: 12),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: ulasanCtrl.isSubmitting.value
                        ? null
                        : () async {
                            await ulasanCtrl.kirimUlasan(
                              tipe: tipe,
                              propertiId: propertiId,
                            );
                            onSelesai();
                          },
                    child: ulasanCtrl.isSubmitting.value
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text(
                            "Kirim Ulasan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildUlasanCard(Map<String, dynamic> u) {
    final int rating = (u['rating'] as num?)?.toInt() ?? 0;
    final bool isAnon = u['is_anonymous'] == true;
    final String? balasan = u['balasan_pemilik'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6FF),
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (u['properti_tipe'] ?? '').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    u['properti_nama'] ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: Colors.orange,
                        );
                      }),
                    ),
                    Row(
                      children: [
                        if (isAnon) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.visibility_off_outlined,
                                    size: 11, color: textGrey),
                                SizedBox(width: 4),
                                Text(
                                  "Anonim",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: textGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          u['created_at'] ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: textGrey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  u['komentar'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF536273),
                  ),
                ),
                if (balasan != null && balasan.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFBFDCFF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.storefront_outlined,
                            size: 15, color: blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Balasan Pemilik",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: blue,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                balasan,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}