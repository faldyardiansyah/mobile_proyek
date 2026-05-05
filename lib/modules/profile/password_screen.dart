import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'controllers/profile_controller.dart';

class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
     final ProfileController controller = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: AppColor.white,
        title: const Text(
          'Ganti Password',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Info ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColor.primary, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kosongkan jika tidak ingin mengubah password',
                      style: TextStyle(color: AppColor.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Form Password ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GANTI PASSWORD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPasswordField(
                    label: 'Password Lama',
                    controller: controller.oldPasswordController,
                    isHidden: controller.isOldPassHidden,
                    hint: 'Masukkan password lama',
                  ),
                  _buildPasswordField(
                    label: 'Password Baru',
                    controller: controller.newPasswordController,
                    isHidden: controller.isNewPassHidden,
                    hint: 'Minimal 8 karakter',
                  ),
                  _buildPasswordField(
                    label: 'Konfirmasi Password Baru',
                    controller: controller.confirmPasswordController,
                    isHidden: controller.isConfirmPassHidden,
                    hint: 'Ulangi password baru',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Tombol Simpan ──
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.changePassword(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required RxBool isHidden,
    String hint = 'Masukkan password',
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() => TextField(
            controller: controller,
            obscureText: isHidden.value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColor.primary,
                size: 18,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isHidden.value ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF94A3B8),
                  size: 18,
                ),
                onPressed: () => isHidden.value = !isHidden.value,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.primary),
              ),
            ),
          )),
        ],
      ),
    );
  }
}