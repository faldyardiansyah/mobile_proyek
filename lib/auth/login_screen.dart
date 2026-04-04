import 'package:appkonkos_mobile/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';
import '../utils/app_color.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController controller = Get.find<AuthController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColor.primaryLinear),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    "Selamat Datang di Apkonkos",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Masuk untuk mecari hunian impianmu",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 35),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Email",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: "Masukkan email",
                          icon: Icons.email_outlined, controller: controller.emailLoginController,
                        ),
                        const SizedBox(height: 8),
                        _buildForgotPasswordRow(),
                        const SizedBox(height: 8),

                        Obx(
                          () => _buildTextField(
                            hint: "Masukkan password",
                            icon: Icons.lock_outline,
                            controller: controller.passwordLoginController,
                            isPassword: true,
                            obscureText: controller.isHidden.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => controller.togglePassword(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        _buildLoginButton(controller),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "Atau masuk dengan",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSocialRow(),
                        const SizedBox(height: 24),
                        _buildRegisterRow(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(Icons.home_filled, color: Colors.white, size: 30)
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon, required TextEditingController controller,
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildForgotPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Password",
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Lupa Password?",
            style: TextStyle(color: Color(0xFF1E88E5)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AuthController controller) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryLinear.colors[0].withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Masuk",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.login, size: 16, color: Colors.white),
                  ],
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 3500.ms, color: Colors.white.withOpacity(0.4)),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SocialButton(
        Image(image: AssetImage("assets/image/google.png"), height: 20), 
        "Google",
      ),
      SocialButton(
        Image(image: AssetImage("assets/image/facebook.png"), height: 20), 
        "Facebook",
      ),
      ],
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun?", style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () {
            Get.to(() => const RegisterScreen());
          },
          child: const Text(
            "Daftar sekarang",
            style: TextStyle(color: Color(0xFF1E88E5)),
          ),
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  const SocialButton(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 6),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
