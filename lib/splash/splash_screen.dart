import 'package:appkonkos_mobile/splash/splash_screen_1.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    startAnimation();
  }

  Future<void> startAnimation() async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 1));
    await _controller.reverse();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen1()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/image/konten.png", height: 300),
            const SizedBox(height: 10),
            const Text(
              "Apkonkos",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2A5E),
              ),
            ),
            const Text(
              "Aplikasi Pencarian Kontrakan\n dan Kosan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
