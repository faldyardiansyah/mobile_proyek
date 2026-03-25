import 'package:flutter/material.dart';
import 'widget/onboarding_screen.dart';
import 'splash_screen_3.dart';
import 'package:get/get.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: Image.asset(
        'assets/image/splash2.png',
        height: MediaQuery.of(context).size.height * 0.35,
        fit: BoxFit.contain,
      ),
      title: "Booking Cepat &",
      highlight: "Mudah",
      description: "Temukan kamar impianmu dan amankan\n" "segera hanya dengan beberapa ketukan jari.\n" "Tanpa ribet, langsung huni.",
      buttonText: "Lanjut",
      currentIndex: 1,
      onNext: () {
        Get.to(() => const SplashScreen3());
      },
      onSkip: () {
        Get.to(() => const SplashScreen3());
      },
    );
  }
}
