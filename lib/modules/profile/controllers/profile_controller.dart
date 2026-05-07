import 'dart:io';
import 'package:appkonkos_mobile/auth/controller/auth_controller.dart';
import 'package:dio/dio.dart' as dio_lib;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var selectedImage = Rxn<File>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController noWaController;       
  late TextEditingController domisiliController;   
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  final selectedJenisKelamin = RxnString();        
  final selectedPekerjaan = RxnString();           

  final listJenisKelamin = ['Laki-laki', 'Perempuan'];
  final listPekerjaan = ['Mahasiswa', 'Karyawan', 'Lainnya'];

  final isOldPassHidden = true.obs;
  final isNewPassHidden = true.obs;
  final isConfirmPassHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    noWaController = TextEditingController();
    domisiliController = TextEditingController();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    loadUserData();
  }

Future<void> uploadFotoSaja() async {
  if (selectedImage.value == null) return;
  
  try {
    isLoading.value = true;
    final formData = dio_lib.FormData.fromMap({
      'foto': await dio_lib.MultipartFile.fromFile(
        selectedImage.value!.path,
        filename: 'foto_profil.jpg',
      ),
    });

    final response = await _apiService.postFormData('/profile/update', formData);

    if (response.statusCode == 200) {
      final authC = Get.find<AuthController>();
      final userData = response.data['user'];
      final updatedUser = Map<String, dynamic>.from(authC.user.value);
      updatedUser['profile_photo_url'] = userData['profile_photo_url'];
      authC.user.value = updatedUser;
      authC.box.write('user', authC.user.value);
      await loadUserData();
      selectedImage.value = null;

      Get.snackbar(
        'Berhasil',
        'Foto profil diperbarui',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    }
  } catch (e) {
    Get.snackbar('Gagal', 'Gagal mengupload foto',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800);
  } finally {
    isLoading.value = false;
  }
}
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200) {
        var userData = response.data['user'];
        nameController.text = userData['name'] ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['no_telepon'] ?? '-';
        noWaController.text = userData['no_wa'] ?? '';
        domisiliController.text = userData['domisili'] ?? '';

        // Set dropdown
        selectedJenisKelamin.value = userData['jenis_kelamin'];
        selectedPekerjaan.value = userData['pekerjaan'];

        final authC = Get.find<AuthController>();
        authC.user['profile_photo_url'] = userData['profile_photo_url'];
        authC.user['no_wa'] = userData['no_wa'];
        authC.user['jenis_kelamin'] = userData['jenis_kelamin'];
        authC.user['pekerjaan'] = userData['pekerjaan'];
        authC.user['domisili'] = userData['domisili'];
        authC.user.refresh();
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil data profil");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null) {
      selectedImage.value = File(picked.path);
      await uploadFotoSaja();
    }
  }

  void showImagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Foto',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _imageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () {
                      Get.back();
                      pickImage(ImageSource.camera);
                    },
                  ),
                  _imageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () {
                      Get.back();
                      pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF3F51B5)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

Future<void> changePassword() async {
  if (oldPasswordController.text.isEmpty ||
      newPasswordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty) {
    Get.snackbar('Perhatian', 'Semua field wajib diisi',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800);
    return;
  }

  if (newPasswordController.text.length < 8) {
    Get.snackbar('Perhatian', 'Password baru minimal 8 karakter',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800);
    return;
  }

  if (newPasswordController.text != confirmPasswordController.text) {
    Get.snackbar('Perhatian', 'Konfirmasi password tidak cocok',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800);
    return;
  }

  try {
    isLoading.value = true;

    final formData = dio_lib.FormData.fromMap({
      'password_lama' : oldPasswordController.text,
      'password_baru' : newPasswordController.text,
      'konfirmasi'    : confirmPasswordController.text,
    });

    final response = await _apiService.postFormData('/profile/update', formData);

    if (response.statusCode == 200) {
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Password berhasil diubah',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP,
      );
    }
  } catch (e) {
    Get.snackbar('Gagal', 'Password lama tidak sesuai',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800);
  } finally {
    isLoading.value = false;
  }
}
  Future<void> updateProfile() async {
    if (newPasswordController.text.isNotEmpty) {
      if (oldPasswordController.text.isEmpty) {
        Get.snackbar('Perhatian', 'Masukkan password lama',
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800);
        return;
      }
      if (newPasswordController.text.length < 8) {
        Get.snackbar('Perhatian', 'Password baru minimal 8 karakter',
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800);
        return;
      }
      if (newPasswordController.text != confirmPasswordController.text) {
        Get.snackbar('Perhatian', 'Konfirmasi password tidak cocok',
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.orange.shade800);
        return;
      }
    }

    try {
      isLoading.value = true;

      final formData = dio_lib.FormData.fromMap({
        'name'          : nameController.text.trim(),
        'no_telepon'    : phoneController.text.trim() == '-' ? '' : phoneController.text.trim(),
        'no_wa'         : noWaController.text.trim(),
        'domisili'      : domisiliController.text.trim(),
        if (selectedJenisKelamin.value != null)
          'jenis_kelamin' : selectedJenisKelamin.value!,
        if (selectedPekerjaan.value != null)
          'pekerjaan'     : selectedPekerjaan.value!,
        if (newPasswordController.text.isNotEmpty) ...{
          'password_lama' : oldPasswordController.text,
          'password_baru' : newPasswordController.text,
          'konfirmasi'    : confirmPasswordController.text,
        },
        if (selectedImage.value != null)
          'foto': await dio_lib.MultipartFile.fromFile(
            selectedImage.value!.path,
            filename: 'foto_profil.jpg',
          ),
      });

      final response = await _apiService.postFormData('/profile/update', formData);

      if (response.statusCode == 200) {
        final authC = Get.find<AuthController>();
        final userData = response.data['user'];

        authC.user['name']              = userData['name'];
        authC.user['no_telepon']        = userData['no_telepon'];
        authC.user['no_wa']             = userData['no_wa'];
        authC.user['jenis_kelamin']     = userData['jenis_kelamin'];
        authC.user['pekerjaan']         = userData['pekerjaan'];
        authC.user['domisili']          = userData['domisili'];
        authC.user['profile_photo_url'] = userData['profile_photo_url'];
        authC.user.refresh();

        authC.box.write('user', authC.user.value);

        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        selectedImage.value = null;

        Get.snackbar(
          'Berhasil',
          'Profil berhasil diperbarui',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    noWaController.dispose();
    domisiliController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}