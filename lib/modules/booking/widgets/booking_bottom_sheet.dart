import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';

class BookingBottomSheet extends StatelessWidget {
  const BookingBottomSheet({super.key});

  static void show({
    required String kamarId,
    required String kamarNama,
    required int hargaPerBulan,
    required String tipeKamarNama,
    required String tipeProperty,
  }) {
    final ctrl = Get.isRegistered<BookingController>()
        ? Get.find<BookingController>()
        : Get.put(BookingController());

    ctrl.setKamar(
      id: kamarId,
      nama: kamarNama,
      harga: hargaPerBulan,
      tipeNama: tipeKamarNama,
    );

    ctrl.tipeProperty.value = tipeProperty;

    Get.bottomSheet(
      const BookingBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BookingController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 14,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 55,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Konfirmasi Booking',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.meeting_room_outlined,
                      size: 18,
                      color: AppColor.blue,
                    ),

                    const SizedBox(width: 6),

                    Flexible(
                      child: Text(
                        '${ctrl.kamarNama} • ${ctrl.tipeKamarNama}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pilih Durasi Sewa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 18),

                Obx(() {
                  final isKontrakan = ctrl.tipeProperty.value == 'Kontrakan';

                  return Column(
                    children: [
                      Row(
                        children: ctrl.opsiDurasi.map((durasi) {
                          final isSelected =
                              ctrl.selectedDurasi.value == durasi;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                ctrl.selectDurasi(durasi);

                                ctrl.durasiController.text = durasi.toString();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.blue
                                      : const Color(0xFFF3F3F3),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColor.blue.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'OPSI',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white70
                                            : Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      isKontrakan
                                          ? '$durasi Tahun'
                                          : '$durasi Bulan',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: ctrl.durasiController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: isKontrakan
                              ? 'Input durasi tahun sendiri'
                              : 'Input durasi bulan sendiri',
                          prefixIcon: const Icon(
                            Icons.edit_calendar,
                            color: AppColor.blue,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(
                              color: AppColor.blue,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) {
                          ctrl.selectDurasi(int.tryParse(v) ?? 1);
                        },
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Obx(
                    () => Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ctrl.tipeProperty.value == 'Kontrakan'
                               ? 'Harga per tahun' : 'Harga per bulan',
                                 style: const TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                              ),
                            ),

                            Text(
                              'Rp ${ctrl.formattedHargaPerBulan}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Divider(),
                        ),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total\nPembayaran',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 14,
                                      color: AppColor.blue.withOpacity(0.8),
                                    ),

                                    const SizedBox(width: 4),
                                    const Text(
                                      'TERMASUK DEPOSIT\nAWAL',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColor.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Flexible(
                              child: Text(
                                'Rp${ctrl.formattedTotal}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColor.blue,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.blue,
                        elevation: 6,
                        shadowColor: AppColor.blue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: ctrl.isLoading.value
                          ? null
                          : () async {
                              final success = await ctrl.submitBooking();

                              if (success) {
                                Get.back();

                                Get.snackbar(
                                  'Berhasil',
                                  'Booking berhasil diajukan',
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                              }
                            },
                      icon: ctrl.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                      label: const Text(
                        'Ajukan Booking Sekarang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Dengan menekan tombol di atas, Anda menyetujui\nSyarat & Ketentuan yang berlaku.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
