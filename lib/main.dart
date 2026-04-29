import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:appkonkos_mobile/splash/splash_screen.dart';
import 'package:appkonkos_mobile/auth/login_screen.dart';
import 'package:appkonkos_mobile/auth/register_screen.dart';
import 'package:appkonkos_mobile/modules/home/home_screen.dart';
import 'auth/controller/auth_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  Get.put(ApiService());
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
      getPages: [
        GetPage(name: '/login',    page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home',     page: () =>  HomeScreen()),
      ],
    );
  }
}