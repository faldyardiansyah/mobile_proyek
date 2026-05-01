import 'package:flutter/material.dart';
import 'widget/onboarding_screen.dart';
import 'splash_screen_3.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:get_storage/get_storage.dart';

final box = GetStorage();

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: Lottie.asset(
        'assets/lottie/calendar_booking.json',
        width: 800,
        height: 300,
        repeat: true,
      ),
      title: "Booking Cepat &",
      highlight: "Mudah",
      description:
          "Temukan kamar impianmu dan amankan\n"
          "segera hanya dengan beberapa ketukan jari.\n"
          "Tanpa ribet, langsung huni.",
      buttonText: "Lanjut",
      currentIndex: 1,
      onNext: () {
        Get.to(() => const SplashScreen3());
      },
      onSkip: () {
        box.write('onboarding_done', true);
        Get.offAll(() => const SplashScreen3());
      },
    );
  }
}
