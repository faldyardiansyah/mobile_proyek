import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'splash_screen_3.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(
      image: "assets/image/splash2.png",
      title: "Booking Cepat &",
      highlight: "Mudah",
      description: "Temukan kamar impianmu dan amankan\n" "segera hanya dengan beberapa ketukan jari.\n" "Tanpa ribet, langsung huni.",
      buttonText: "Lanjut",
      currentIndex: 1,
      onNext: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen3()),
        );
        
      },
      onSkip: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen3()),
        );
      },
    );
  }
}
