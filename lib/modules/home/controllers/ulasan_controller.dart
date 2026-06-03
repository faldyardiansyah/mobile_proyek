import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class UlasanController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final ulasanList = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final bolehReview = false.obs;
  final sudahReview = false.obs;
  final rataRating = 0.0.obs;
  final totalUlasan = 0.obs;
  final isAnonymous = false.obs;

  final selectedRating = 0.obs;
  final komentarCtrl = TextEditingController();

  Future<void> loadUlasan(String tipe, int propertiId) async {
    try {
      isLoading(true);
      final res = await _api.getUlasan(tipe, propertiId);
      if (res.data['success'] == true) {
        ulasanList.value = List<Map<String, dynamic>>.from(res.data['data']);
        rataRating.value = (res.data['rata_rata'] ?? 0).toDouble();
        totalUlasan.value = res.data['total'] ?? 0;
      }
    } catch (e) {
      print('ERROR load ulasan: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> cekBolehReview(String tipe, int propertiId) async {
    try {
      final res = await _api.cekBolehReview(tipe, propertiId);
      bolehReview.value = res.data['boleh'] ?? false;
      sudahReview.value = res.data['sudah_review'] ?? false;
    } catch (e) {
      bolehReview.value = false;
    }
  }

  Future<void> kirimUlasan({
    required String tipe,
    required int propertiId,
  }) async {
    if (selectedRating.value == 0) {
      Get.snackbar('Perhatian', 'Pilih rating dulu ya!',
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (komentarCtrl.text.trim().length < 10) {
      Get.snackbar('Perhatian', 'Komentar minimal 10 karakter.',
          snackPosition: SnackPosition.TOP);
      return;
    }

    try {
      isSubmitting(true);
      final res = await _api.kirimUlasan({
        'tipe'        : tipe,
        'properti_id' : propertiId,
        'rating'      : selectedRating.value,
        'komentar'    : komentarCtrl.text.trim(),
        'is_anonymous' : isAnonymous.value,
      });

      if (res.data['success'] == true) {
        Get.back(); // tutup bottom sheet
        Get.snackbar(
          '⭐ Terima kasih!',
          'Ulasan kamu berhasil dikirim.',
          backgroundColor: const Color(0xFFE8F5E9),
          colorText: const Color(0xFF2E7D32),
          snackPosition: SnackPosition.TOP,
        );
        // Reload ulasan
        await loadUlasan(tipe, propertiId);
        await cekBolehReview(tipe, propertiId);
        komentarCtrl.clear();
        selectedRating.value = 0;
        isAnonymous.value = false;
      } else {
        Get.snackbar('Gagal', res.data['message'] ?? 'Terjadi kesalahan.');
      }
    } catch (e) {
      final dynamic err = e;
      final msg = err?.response?.data?['message'] ?? 'Terjadi kesalahan.';
      Get.snackbar('Gagal', msg,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFC62828));
    } finally {
      isSubmitting(false);
    }
  }

  @override
  void onClose() {
    komentarCtrl.dispose();
    super.onClose();
  }
}