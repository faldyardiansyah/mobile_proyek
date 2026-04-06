import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final _storage = GetStorage();

  final isLoading = false.obs;
  final isHidden = true.obs;
  final isRegisterPasswordHidden = true.obs;
  final isAgreeTerms = false.obs;

  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();

  final namaRegisterController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();

  @override
  void onClose() {
    emailLoginController.dispose();
    passwordLoginController.dispose();
    namaRegisterController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.onClose();
  }

  void togglePassword() => isHidden.value = !isHidden.value;
  void toggleRegisterPassword() =>
      isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  void toggleAgreeTerms(bool? v) => isAgreeTerms.value = v ?? false;

  Future<void> login() async {
    if (emailLoginController.text.isEmpty ||
        passwordLoginController.text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Email dan password tidak boleh kosong',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,  
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),     
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _api.post('/auth/login', {
        'email': emailLoginController.text.trim(),
        'password': passwordLoginController.text,
      });
      _storage.write('token', response.data['token']);
      _storage.write('user', response.data['user']);

      Get.snackbar(
        'Berhasil',
        'Selamat datang ${response.data['user']['nama']}',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      Get.offAllNamed('/home');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Login gagal, silakan coba lagi';
      Get.snackbar(
        'Login Gagal',
        message,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (namaRegisterController.text.isEmpty ||
        registerEmailController.text.isEmpty ||
        registerPasswordController.text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua field harus diisi',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      return;
    }

    if (!isAgreeTerms.value) {
      Get.snackbar(
        'Perhatian',
        'Anda harus menyetujui syarat dan ketentuan',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      return;
    }

    if (registerPasswordController.text.length < 6) {
      Get.snackbar(
        'Perhatian',
        'Password harus minimal 6 karakter',
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _api.post('/auth/register', {
        'nama': namaRegisterController.text.trim(),
        'email': registerEmailController.text.trim(),
        'password': registerPasswordController.text,
        'password_confirmation': registerPasswordController.text,
      });
      _storage.write('token', response.data['token']);
      _storage.write('user', response.data['user']);

      Get.snackbar(
        'Berhasil',
        'Selamat datang ${response.data['user']['nama']}',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
      Get.offAllNamed('/login');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ?? 'Registrasi gagal, silakan coba lagi';
      Get.snackbar(
        'Registrasi Gagal',
        message,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } finally {
      _storage.erase();
      Get.offAllNamed('/login');
    }
  }

  bool get isLoggedIn => _storage.read('token') != null;
}
