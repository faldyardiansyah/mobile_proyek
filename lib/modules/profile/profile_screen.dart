import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './personal_info_screen.dart';
import './payment_screen.dart';
import './help_screen.dart';
import '../../auth/controller/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: AppColor.white,
        title: const Text(
          "Profile Saya",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Stack(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFD9C3A3),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.primary,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            final nama = authC.user['nama'] ?? 'User';
            return Text(
              nama,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "VERIFIED ACCOUNT",
              style: TextStyle(
                fontSize: 10,
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  const Text(
                    "AKUN & KEAMANAN",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _menu(icon: Icons.person_outline, title: "Informasi Pribadi", onTap: (){Get.to(() => const PersonalInfoScreen());}),
                  const SizedBox(height: 5),
                  _menu(icon: Icons.credit_card, title: "Metode Pembayaran", onTap: (){Get.to(()=> const PaymentScreen());}),
                  const SizedBox(height: 20),
                  const Text("Dukungan", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),),
                  const SizedBox(height: 10),
                  _menu(icon: Icons.help_outline, title: "Pusat Bantuan", onTap: (){Get.to(() => const HelpScreen());}),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(onPressed: (){authC.logout();}, label: const Text("Keluar Sesi"), icon: const Icon(Icons.logout, size: 18,), style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColor.primary,
                    elevation: 0,
                    side: const BorderSide(color: AppColor.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _menu({
    required IconData icon,
    required String title,
    required VoidCallback onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(leading: Icon(icon, color: AppColor.primary), title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios, size: 16,
      ),
        onTap: onTap
      ),
    );
  }
}
