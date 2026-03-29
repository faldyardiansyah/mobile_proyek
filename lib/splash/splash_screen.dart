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
            Image.asset("assets/image/logo.png", height: 200)
                .animate()
                .fadeIn(duration: const Duration(seconds: 1))
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
             SizedBox(height: 45),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: _AnimatedDot(index: index),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final int index;
  const _AnimatedDot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF4A89F3),
        shape: BoxShape.circle,
      ),
    )
    .animate(onPlay: (controller) => controller.repeat())
    .fadeIn(
      delay: Duration(milliseconds: index * 200),
      duration: const Duration(milliseconds: 400),
    )
    .then()
    .fadeOut(duration: const Duration(milliseconds: 400))
    .then()
    .scaleXY(
      begin: 0.6,
      end: 1.0,
      duration: const Duration(milliseconds: 300),
    );
  }
}
