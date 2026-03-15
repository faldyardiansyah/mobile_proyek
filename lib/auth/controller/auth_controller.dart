import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:appkonkos_mobile/modules/home/home_screen.dart';

class AuthController extends GetxController {
  var isHidden = true.obs;
  void togglePassword() {
    isHidden.value = !isHidden.value;
  }

  void login() {
    Get.snackbar(
      "Berhasil Masuk",
      "Selamat datang kembali di Apkonkos!",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      leftBarIndicatorColor: Colors.green,
      icon: const Icon(Icons.check_circle, color: Colors.green),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(() => HomeScreen());
    });
  }

  var isRegisterPasswordHidden = true.obs;
  var isAgreeTerms = false.obs;
  void toggleRegisterPassword() {
    isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  }
  void toggleAgreeTerms(bool? value) {
    isAgreeTerms.value = value ?? false;
  }
  void register() {
    if (isAgreeTerms.value == false) {
      Get.snackbar(
        "Peringatan",
        "Anda harus menyetujui syarat dan ketentuan Layanan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        leftBarIndicatorColor: Colors.red,
        icon: const Icon(Icons.error, color: Colors.red),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        "Sukses",
        "Akun berhasil dibuat! Silahkan masuk.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        leftBarIndicatorColor: Colors.green,
        icon: const Icon(Icons.check_circle, color: Colors.green),
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }
}
