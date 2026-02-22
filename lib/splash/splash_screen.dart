import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:appkonkos_mobile/splash/splash_screen_1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTransition();
  }

  void _startTransition() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.off(() => const SplashScreen1());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/image/konten.png", height: 300)
                .animate()
                .fadeIn(duration: const Duration(seconds: 1))
                .scale()
                .then(delay: const Duration(seconds: 1))
                .fadeOut(duration: const Duration(seconds: 1)),
            
            const SizedBox(height: 10),
            
            const Text(
              "Apkonkos",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A5E),
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const Text(
              "Aplikasi Pencarian Kontrakan\n dan Kosan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}