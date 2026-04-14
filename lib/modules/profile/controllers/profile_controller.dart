import 'package:appkonkos_mobile/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    loadUserData();
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200) {
        var userData = response.data['data'];
        nameController.text = userData['nama'] ?? '';
        emailController.text = userData['email'] ?? '';
        String telp = userData['telepon'] ?? '';
        phoneController.text = telp.isEmpty ? '-' : telp;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data profil");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      String phoneInput = phoneController.text.trim();
      dynamic phoneValue = (phoneInput == '-' || phoneInput.isEmpty) ? null : phoneInput;

      var data = {
        'nama': nameController.text,
        'email': emailController.text,
        'telepon': phoneValue,
      };

      final response = await _apiService.updateProfile(data);

      if (response.statusCode == 200) {
        final authController = Get.find<AuthController>();
        authController.user['nama'] = nameController.text;
        authController.user['email'] = emailController.text;
        authController.user['telepon'] = phoneValue;

        authController.user.refresh();

        if (phoneValue == null) phoneController.text = '-';

        Get.snackbar(
          "Sukses", 
          "Profil berhasil diperbarui", 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan saat menyimpan data");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}