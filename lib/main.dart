import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:appkonkos_mobile/splash/splash_screen.dart';
import 'auth/controller/auth_controller.dart';

void main() {

  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Apkonkos",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}