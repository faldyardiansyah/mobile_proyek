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

  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    final storedUser = _storage.read('user');
    if (storedUser != null) {
      user.value = Map<String, dynamic>.from(storedUser);
    }
  }

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
      _showSnackbar(
        'Perhatian',
        'Email dan password wajib diisi',
        Colors.orange,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await _api.post('/auth/login', {
        'email': emailLoginController.text.trim(),
        'password': passwordLoginController.text,
      });

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['token'] != null && data['user'] != null) {
          _storage.write('token', data['token']);
          _storage.write('user', data['user']);
          user.value = Map<String, dynamic>.from(data['user']);

          Get.offAllNamed('/home');
          _showSnackbar(
            'Berhasil',
            'Selamat datang ${user.value['nama']}',
            Colors.green,
          );
        } else {
          _showSnackbar(
            'Login Gagal',
            'Data dari server tidak lengkap',
            Colors.red,
          );
        }
      } else {
        _showSnackbar('Login Gagal', 'Email atau password salah', Colors.red);
      }
    } on DioException catch (e) {
      _showSnackbar(
        'Login Gagal',
        e.response?.data?['message'] ?? 'Terjadi kesalahan server',
        Colors.red,
      );
    } catch (e) {
      _showSnackbar('Error', 'Terjadi error: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (namaRegisterController.text.isEmpty ||
        registerEmailController.text.isEmpty ||
        !isAgreeTerms.value) {
      _showSnackbar(
        'Perhatian',
        'Lengkapi data dan setujui syarat ketentuan',
        Colors.orange,
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

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['token'] != null && data['user'] != null) {
          _storage.write('token', data['token']);
          _storage.write('user', data['user']);

          Get.offAllNamed('/login');
          _showSnackbar(
            'Berhasil',
            'Registrasi berhasil, silakan login',
            Colors.green,
          );
        } else {
          _showSnackbar('Gagal', 'Data server tidak valid', Colors.red);
        }
      } else {
        _showSnackbar('Gagal', 'Registrasi gagal', Colors.red);
      }
    } on DioException catch (e) {
      _showSnackbar(
        'Gagal',
        e.response?.data?['message'] ?? 'Registrasi gagal',
        Colors.red,
      );
    } catch (e) {
      _showSnackbar('Error', 'Terjadi error: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    String namaUser = user.value['nama'] ?? 'Pengguna';

    try {
      // Timeout agar tidak stuck jika server tidak merespon
      await _api.post('/auth/logout', {}).timeout(const Duration(seconds: 2));
    } catch (_) {
    } finally {
      _storage.erase();
      user.value = {};
      Get.offAllNamed('/login');
      _showSnackbar(
        'Berhasil',
        'Berhasil Logout dari akun $namaUser',
        Colors.green,
      );
    }
  }

  bool get isLoggedIn => _storage.read('token') != null;

  void _showSnackbar(String title, String message, MaterialColor color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.shade50,
      colorText: color.shade800,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    );
  }
}
