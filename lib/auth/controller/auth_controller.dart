import 'package:appkonkos_mobile/modules/Riwayat/controllers/riwayat_controller.dart';
import 'package:appkonkos_mobile/services/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final box = GetStorage();

  final isLoading = false.obs;
  final isHidden = true.obs;
  final isRegisterPasswordHidden = true.obs;
  final isAgreeTerms = false.obs;

  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();
  final namaRegisterController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final registerphoneController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    scopes: ['email', 'profile'],
  );

  var user = {}.obs;

  @override
  void onInit() {
    super.onInit();
    final storedUser = box.read('user');
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
    registerphoneController.dispose();
    super.onClose();
  }

  void togglePassword() => isHidden.value = !isHidden.value;
  void toggleRegisterPassword() =>
      isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  void toggleAgreeTerms(bool? v) => isAgreeTerms.value = v ?? false;

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Sign in via Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return;

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        _showSnackbar('Error', 'Gagal mendapatkan token Google', Colors.red);
        return;
      }

      final response = await _api.post('/auth/google', {'id_token': idToken});

      if (response != null && response.statusCode == 200) {
        final data = response.data;

        if (data['token'] != null && data['user'] != null) {
          box.write('token', data['token']);
          box.write('user', data['user']);
          user.value = Map<String, dynamic>.from(data['user']);

          if (user.value['id'] != null) {
            NotificationService.switchUser(user.value['id'].toString());
          }

          Get.offAllNamed('/home');

          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<RiwayatController>()) {
              Get.find<RiwayatController>().fetchRiwayat();
            }
          });

          _showSnackbar(
            'Berhasil',
            'Selamat datang ${user.value['name']}',
            Colors.green,
          );
        }
      }
    } on DioException catch (e) {
      _showSnackbar(
        'Gagal',
        e.response?.data?['message'] ?? 'Login Google gagal',
        Colors.red,
      );
    } catch (e) {
      debugPrint('Google login error: $e');
      _showSnackbar('Error', 'Terjadi kesalahan, coba lagi', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

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
          box.write('token', data['token']);
          box.write('user', data['user']);
          user.value = Map<String, dynamic>.from(data['user']);

          try {
            final profileResponse = await _api.get('/profile');
            if (profileResponse.statusCode == 200) {
              final data = profileResponse.data;
              if (data is Map && data['user'] != null) {
                user.value = Map<String, dynamic>.from(data['user']);
                box.write('user', data['user']);
              }
            }
          } catch (_) {}
          if (user.value['id'] != null) {
            NotificationService.switchUser(user.value['id'].toString());
          }
          Get.offAllNamed('/home');
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<RiwayatController>()) {
              Get.find<RiwayatController>().fetchRiwayat();
            }
          });
          _showSnackbar(
            'Berhasil',
            'Selamat datang ${user.value['name']}',
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
      // if (e.response?.statusCode == 403) {
      //   final email = emailLoginController.text.trim();
      //   _showSnackbar(
      //     'Verifikasi Email',
      //     'Email belum diverifikasi. Silakan cek inbox Anda.',
      //     Colors.orange,
      //   );
      //   Get.toNamed('/verify-email', arguments: {'email': email});
      // } else
      {
        _showSnackbar(
          'Login Gagal',
          e.response?.data?['message'] ?? 'Terjadi kesalahan server',
          Colors.red,
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _showSnackbar(
        'Error',
        'Terjadi kesalahan, silakan coba lagi',
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (namaRegisterController.text.isEmpty ||
        registerEmailController.text.isEmpty ||
        registerPasswordController.text.isEmpty ||
        registerphoneController.text.isEmpty ||
        !isAgreeTerms.value) {
      _showSnackbar(
        'Perhatian',
        'Lengkapi data dan setujui syarat ketentuan',
        Colors.orange,
      );
      return;
    }

    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!emailRegex.hasMatch(registerEmailController.text.trim())) {
      _showSnackbar('Perhatian', 'Format email tidak valid', Colors.orange);
      return;
    }

    if (registerphoneController.text.trim().length < 12) {
      _showSnackbar(
        'Perhatian',
        'Nomor telepon minimal 12 digit',
        Colors.orange,
      );
      return;
    }

    if (registerPasswordController.text.length < 8) {
      _showSnackbar('Perhatian', 'Password minimal 8 karakter', Colors.orange);
      return;
    }

    try {
      isLoading.value = true;

      final response = await _api.post('/auth/register', {
        'name': namaRegisterController.text.trim(),
        'email': registerEmailController.text.trim(),
        'no_telepon': registerphoneController.text.trim(),
        'password': registerPasswordController.text,
        'password_confirmation': registerPasswordController.text,
      });

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        final data = response.data;
        debugPrint('REGISTER RESPONSE: $data');

        if (data != null && data['token'] != null) {
          final email = registerEmailController.text.trim();

          namaRegisterController.clear();
          registerEmailController.clear();
          registerPasswordController.clear();
          registerphoneController.clear();
          isAgreeTerms.value = false;

          Get.offAllNamed('/verify-email', arguments: {'email': email});
          _showSnackbar(
            'Berhasil',
            'Cek email Anda untuk verifikasi akun',
            Colors.green,
          );
        } else {
          _showSnackbar(
            'Gagal',
            'Respon server tidak sesuai format',
            Colors.red,
          );
        }
      }
    } on DioException catch (e) {
      debugPrint('Register DioException: $e');
      String errorMessage = 'Terjadi kesalahan';
      if (e.response != null && e.response?.data != null) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          if (errors.containsKey('email')) {
            errorMessage = 'Email sudah terdaftar, gunakan email lain';
          } else {
            errorMessage = errors.values.first[0].toString();
          }
        } else {
          errorMessage = e.response?.data['message'] ?? 'Registrasi gagal';
        }
      }
      _showSnackbar('Gagal', errorMessage, Colors.red);
    } catch (e) {
      debugPrint('Register error: $e');
      _showSnackbar(
        'Gagal',
        'Terjadi kesalahan, silakan coba lagi',
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendVerification(String email) async {
    try {
      isLoading.value = true;
      final response = await _api.post('/auth/resend-verification', {
        'email': email,
      });
      if (response?.statusCode == 200) {
        _showSnackbar(
          'Berhasil',
          'Email verifikasi telah dikirim ulang',
          Colors.green,
        );
      }
    } on DioException catch (e) {
      debugPrint('Resend verification error: $e');
      _showSnackbar(
        'Gagal',
        e.response?.data?['message'] ?? 'Gagal mengirim ulang',
        Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    NotificationService.switchUser('global');
    final namaUser = user.value['name'] ?? 'Pengguna';
    try {
      await _api.post('/auth/logout', {}).timeout(const Duration(seconds: 2));
    } catch (_) {
    } finally {
      box.remove('token');
      box.remove('user');
      user.value = {};

      if (Get.isRegistered<RiwayatController>()) {
        Get.delete<RiwayatController>(force: true);
      }

      Get.offAllNamed('/login');
      _showSnackbar(
        'Berhasil',
        'Berhasil Logout dari akun $namaUser',
        Colors.green,
      );
    }
  }

  bool get isLoggedIn => box.read('token') != null;

  void _showSnackbar(String title, String message, MaterialColor color) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.shade50,
      colorText: color.shade800,
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 3),
    );
  }
}
