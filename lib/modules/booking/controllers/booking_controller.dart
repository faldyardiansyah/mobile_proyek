import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class BookingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final _storage = GetStorage();
  final durasiController = TextEditingController(text: '1');
  // State
  final RxInt selectedDurasi = 1.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final tipeProperty = ''.obs;

  String? kamarId;
  String? kamarNama;
  int? hargaPerBulan;
  String? tipeKamarNama;

  final List<int> opsiDurasi = [1, 2, 3];

  int get totalBiaya => (hargaPerBulan ?? 0) * selectedDurasi.value;

  void setKamar({
    required String id,
    required String nama,
    required int harga,
    required String tipeNama,
  }) {
    kamarId = id;
    kamarNama = nama;
    hargaPerBulan = harga;
    tipeKamarNama = tipeNama;
    selectedDurasi.value = 1;
    errorMessage.value = '';
  }

  void selectDurasi(int bulan) {
    selectedDurasi.value = bulan;
  }

  String get formattedHargaPerBulan => _formatHarga(hargaPerBulan?.toString() ?? '0');
  String get formattedTotal => _formatHarga(totalBiaya.toString());

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Future<bool> submitBooking() async {
    if (kamarId == null) {
      errorMessage.value = 'Kamar tidak valid.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final tglMulai =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final response = await _api.post('/bookings', {
        'kamar_id': kamarId,
        'tgl_mulai_sewa': tglMulai,
        'durasi_bulan': selectedDurasi.value,
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        return true;
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Booking gagal. Coba lagi.';
        return false;
      }
    } catch (e) {
      final dynamic err = e;
      if (err?.response != null) {
        final data = err.response?.data;
        if (data is Map && data['message'] != null) {
          errorMessage.value = data['message'];
        } else {
          errorMessage.value = 'Terjadi kesalahan. Coba lagi.';
        }
      } else {
        errorMessage.value = 'Tidak dapat terhubung ke server.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  void setTipeProperty(String tipe) {
  tipeProperty.value = tipe;
}
}