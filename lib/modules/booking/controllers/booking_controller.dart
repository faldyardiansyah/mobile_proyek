import 'package:appkonkos_mobile/modules/booking/screens/midtrans_webview_screen.dart';
import 'package:appkonkos_mobile/modules/profile/personal_info_screen.dart';
import 'package:appkonkos_mobile/modules/booking/screens/booking_confirm_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:appkonkos_mobile/modules/Riwayat/controllers/riwayat_controller.dart';
import 'package:appkonkos_mobile/modules/Riwayat/models/model_riwayat.dart';

class BookingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final _storage = GetStorage();

  final RxInt selectedDurasi = 1.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final tipeProperty = ''.obs;
  final durasiController = TextEditingController(text: '1');

  String? kamarId;
  String? kamarNama;
  int? hargaPerBulan;
  String? tipeKamarNama;
  String? kontrakanId;
  String? peraturan;
  String? namaProperti;
  String? fotoProperti;

  String lastBookingId = '';
  String noWaPemilik = '';

  final List<int> opsiDurasi = [1, 2, 3];

  int get totalBiaya => (hargaPerBulan ?? 0) * selectedDurasi.value;

  void setKamar({
    String? id,
    String? kId,
    required String nama,
    required int harga,
    required String tipeNama,
    String? peraturanProperti,
    String? namaProperti,
    String? fotoProperti,
  }) {
    kamarId = id;
    kontrakanId = kId;
    kamarNama = nama;
    hargaPerBulan = harga;
    tipeKamarNama = tipeNama;
    peraturan = peraturanProperti ?? '';
    this.namaProperti = namaProperti ?? tipeNama;
    this.fotoProperti = fotoProperti ?? '';
    selectedDurasi.value = 1;
    errorMessage.value = '';
  }

  void selectDurasi(int bulan) {
    selectedDurasi.value = bulan;
  }

  String get formattedHargaPerBulan =>
      _formatHarga(hargaPerBulan?.toString() ?? '0');
  String get formattedTotal => _formatHarga(totalBiaya.toString());

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  void setTipeProperty(String tipe) {
    tipeProperty.value = tipe;
  }

  Future<bool> submitBookingFinal({
    required String tglMulai,
  }) async {
    if (kamarId == null && kontrakanId == null) {
      errorMessage.value = 'Kamar tidak valid.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final body = <String, dynamic>{
        'tgl_mulai_sewa': tglMulai,
        'durasi_bulan': selectedDurasi.value,
      };
      if (kamarId != null) body['kamar_id'] = kamarId;
      if (kontrakanId != null) body['kontrakan_id'] = kontrakanId;

      final response = await _api.post('/bookings', body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final redirectUrl = response.data['redirect_url']?.toString() ?? '';
        final snapToken = response.data['snap_token']?.toString() ?? '';
        final bookingId = response.data['booking_id']?.toString() ?? '';

        lastBookingId = bookingId;
        noWaPemilik = response.data['no_wa_pemilik']?.toString() ?? '';

        final url = redirectUrl.isNotEmpty
            ? redirectUrl
            : snapToken.isNotEmpty
            ? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/$snapToken'
            : '';

        if (url.isNotEmpty) {
          try {
            Get.find<RiwayatController>().tambahRiwayat(
              id: '#BK-$bookingId',
              rawId: bookingId,
              title:
                  '${tipeProperty.value} • ${namaProperti ?? tipeKamarNama ?? "Properti"}',
              location: '',
              price: 'Rp ${_formatHarga((totalBiaya + 10000).toString())}',
              status: BookingStatus.menunggu,
              imageAsset: fotoProperti ?? '',
              bookingTime: DateTime.now(),
              redirectUrl: url,
              totalHarga: totalBiaya + 10000,
            );
          } catch (e) {
            print('>>> ERROR TAMBAH RIWAYAT: $e');
          }

          isLoading.value = false;
          Get.to(
            () => MidtransWebView(
              url: url,
              totalHarga: totalBiaya + 10000,
              bookingId: bookingId,
              kamarNama: kamarNama ?? '',
              tipeKamarNama: tipeKamarNama ?? '',
              durasi: selectedDurasi.value,
              tipeProperty: tipeProperty.value,
              noWaPemilik: noWaPemilik,
              tglMulai: tglMulai,
            ),
          );
          return true;
        }
      } else if (response.data['message'] == 'profil_tidak_lengkap') {
        _showProfilTidakLengkap(response.data['field_kosong'] ?? []);
        return false;
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Booking gagal. Coba lagi.';
        return false;
      }
    } catch (e) {
      print('>>> ERROR: $e');
      final dynamic err = e;
      if (err?.response != null) {
        final data = err.response?.data;
        if (data is Map && data['message'] == 'profil_tidak_lengkap') {
          _showProfilTidakLengkap(
            List<String>.from(data['field_kosong'] ?? []),
          );
          return false;
        }
        errorMessage.value = data is Map && data['message'] != null
            ? data['message']
            : 'Terjadi kesalahan. Coba lagi.';
      } else {
        errorMessage.value = 'Tidak dapat terhubung ke server.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void _showProfilTidakLengkap(List fieldKosong) {
    final labelMap = {
      'no_telepon': 'Nomor Telepon',
      'no_wa': 'Nomor WhatsApp',
      'domisili': 'Domisili',
      'jenis_kelamin': 'Jenis Kelamin',
      'pekerjaan': 'Pekerjaan',
    };

    final labels = fieldKosong.map((f) => labelMap[f] ?? f).toList();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Profil Belum Lengkap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lengkapi profil dulu sebelum booking ya! Data yang belum diisi:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...labels.map(
              (label) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BC2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.to(() => PersonalInfoScreen())?.then((_) {
                Get.snackbar(
                  'Profil Diperbarui',
                  'Silakan lanjutkan booking kamu!',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFFE3F2FD),
                  colorText: const Color(0xFF0D47A1),
                );
              });
            },
            child: const Text(
              'Lengkapi Profil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}