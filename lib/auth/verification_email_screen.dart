import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'controller/auth_controller.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

Future<void> _bukaAplikasiEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: '',
  );

  try {
    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  } catch (e) {
    Get.snackbar(
      'Error',
      'Aplikasi email tidak ditemukan',
      snackPosition: SnackPosition.TOP,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 50,
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Verifikasi Email Anda',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami telah mengirim link verifikasi ke\n$email\n\nSilakan buka email dan klik link tersebut.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Tombol buka aplikasi email
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _bukaAplikasiEmail, // ← langsung buka email
                  icon: const Icon(Icons.email_outlined, color: Colors.white),
                  label: const Text(
                    'Buka Aplikasi Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol kirim ulang
              Obx(
                () => TextButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.resendVerification(email),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Ulang Email Verifikasi',
                          style: TextStyle(color: Colors.blue, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 8),

              // Kembali ke login
              TextButton(
                onPressed: () => Get.offAllNamed('/login'),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}