import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import '../auth/login_screen.dart';

class SplashScreen3 extends StatelessWidget {
  const SplashScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScreen(image: "assets/image/splash3.png", title: "Pembayaran", highlight: "Aman & Terpercaya", description: "Nikmati Kemudahan transaksi digital yang\n" "aman untuk kos & kontrakan idamanmu.", buttonText: "Masuk", currentIndex: 2, onNext: (){Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));} , onSkip: (){Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));});
  }
}