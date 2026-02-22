import 'package:appkonkos_mobile/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    "Selamat Datang di Apkonkos",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                        const Text("Email", style: TextStyle(fontSize: 16, color: Colors.black)),
                        const SizedBox(height: 8),
                        _buildTextField(
                          hint: "Masukkan email",
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 8),
                        _buildForgotPasswordRow(),
                        const SizedBox(height: 8),

                        Obx(() => _buildTextField(
                          hint: "Masukkan password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          obscureText: authController.isHidden.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authController.isHidden.value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => authController.togglePassword(),
                          ),
                        )),

                        const SizedBox(height: 30),
                        _buildLoginButton(authController),
                        const SizedBox(height: 20),
                        const Center(child: Text("Atau masuk dengan", style: TextStyle(fontSize: 14, color: Colors.grey))),
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
      width: 60, height: 60,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
      child: const Icon(Icons.home_rounded, color: Colors.white, size: 35),
    );
  }

  Widget _buildTextField({
    required String hint, 
    required IconData icon, 
    bool isPassword = false, 
    bool obscureText = false, 
    Widget? suffixIcon
  }) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildForgotPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Password", style: TextStyle(fontSize: 16, color: Colors.black)),
        TextButton(onPressed: () {}, child: const Text("Lupa Password?", style: TextStyle(color: Color(0xFF1E88E5)))),
      ],
    );
  }

  Widget _buildLoginButton(AuthController controller) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => controller.login(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildSocialRow() {
    return const Row(
      children: [
        SocialButton(Icon(Icons.g_mobiledata, color: Colors.red), "Google"),
        SocialButton(Icon(Icons.facebook, color: Colors.blue), "Facebook"),
        SocialButton(Icon(Icons.apple, color: Colors.black), "Apple"),
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
          child: const Text("Daftar", style: TextStyle(color: Color(0xFF1E88E5)))
        ),
      ],
    );
  }
}

class SocialButton extends StatelessWidget {
  final Icon icon;
  final String label;
  const SocialButton(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon, const SizedBox(width: 6),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}