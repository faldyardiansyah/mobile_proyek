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
  void onInit(){
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
        phoneController.text = userData['telepon'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data profil");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiService.updateProfile({
        'nama': nameController.text,
        'email': emailController.text,
        'telepon': phoneController.text,
      });

      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Profil berhasil diperbarui", 
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan saat menyimpan data");
    } finally {
      isLoading.value = false;
    }
  }
}