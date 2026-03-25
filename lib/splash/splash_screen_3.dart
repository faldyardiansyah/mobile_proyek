import 'package:flutter/material.dart';
import 'widget/onboarding_screen.dart';
import '../auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen3 extends StatelessWidget {
  const SplashScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: Lottie.asset(
        'assets/lottie/security_payment.json',
        width: 300,
        height: 300,
        repeat: true,
      ),
      title: "Pembayaran",
      highlight: "Aman & Terpercaya",
      description:
          "Nikmati Kemudahan transaksi digital yang\n"
          "aman untuk kos & kontrakan idamanmu.",
      buttonText: "Masuk",
      currentIndex: 2,
      onNext: () {
        Get.offAll(() => const LoginScreen());
      },
      onSkip: () {
        Get.offAll(() => const LoginScreen());
      },
    );
  }
}
