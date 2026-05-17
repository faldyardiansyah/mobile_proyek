import 'package:flutter/material.dart';
import 'controller/auth_controller.dart';
import 'package:get/get.dart';
import '../utils/app_color.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController controller = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "LANGKAH 1 DARI 1",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.blue[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                    "Mulai Cari Kontrakan & Kos",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 3500.ms,
                    color: Colors.white.withOpacity(0.4),
                  ),
              const SizedBox(height: 10),
              const Text(
                "Buat akun baru untuk mulai memesan kontrakan & kosan impian Anda",
                style: TextStyle(fontSize: 16, color: AppColor.grey),
              ),
              SizedBox(height: 30),
              _buildInputField(
                "NAMA LENGKAP",
                "Masukkan nama lengkap",
                Icons.person,
                controller: controller.namaRegisterController,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                "EMAIL",
                "Masukkan email",
                Icons.email,
                controller: controller.registerEmailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              _buildInputField(
                "NO. TELEPON",
                "Masukkan nomor telepon",
                Icons.phone,
                controller: controller.registerphoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              const Text(
                "KATA SANDI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => TextField(
                  controller: controller.registerPasswordController,
                  obscureText: controller.isRegisterPasswordHidden.value,
                  scribbleEnabled: false,
                  enableIMEPersonalizedLearning: false,
                  decoration: InputDecoration(
                    hintText: "Minimal 8 karakter",
                    hintStyle: const TextStyle(color: AppColor.grey),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColor.grey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isRegisterPasswordHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => controller.toggleRegisterPassword(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColor.grey, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.isAgreeTerms.value,
                      onChanged: (value) => controller.toggleAgreeTerms(value),
                      activeColor: Colors.blue[400],
                    ),
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Saya setuju dengan syarat dan ketentuan Layanan",
                        style: TextStyle(fontSize: 14, color: AppColor.grey),
                        children: [
                          WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text: "Ketentuan Layanan & Privasi",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Obx(
                () =>
                    Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryLinear.colors[0]
                                    .withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            // Jika loading, tombol otomatis disable (null)
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.register(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
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
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Daftar Akun",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColor.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: AppColor.white,
                                      ),
                                    ],
                                  ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 3500.ms,
                          color: Colors.white.withOpacity(0.4),
                        ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: "Sudah memiliki akun? ",
                    style: TextStyle(color: AppColor.grey),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed('/login'); // ganti route login kamu
                          },
                          child: Text(
                            "Masuk Sekarang",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField(
  String label,
  String hint,
  IconData icon, {
  required controller,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          fontSize: 12,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        scribbleEnabled: false,
        enableIMEPersonalizedLearning: false,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.grey300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColor.grey200),
          ),
        ),
      ),
    ],
  );
}
