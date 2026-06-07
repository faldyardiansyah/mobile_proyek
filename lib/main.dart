import 'package:appkonkos_mobile/auth/verification_email_screen.dart';
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
import 'services/notification_service.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  Get.put(ApiService());
  Get.put(AuthController());
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    // Delay init deep link sampai app benar-benar siap
    Future.delayed(const Duration(milliseconds: 500), () {
      _handleDeepLinks();
    });
  }

  void _handleDeepLinks() {
    // Fungsi untuk menangani navigasi
    void processVerification() {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.until((route) => route.isFirst);
        Get.offAllNamed('/login'); 
        
        Get.snackbar(
          'Berhasil',
          'Email berhasil diverifikasi! Silakan login.',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      });
    }

    _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'appkonkos' && uri.host == 'email-verified') {
        processVerification();
      }
    });

    _appLinks.getInitialLink().then((uri) {
      if (uri != null && uri.scheme == 'appkonkos' && uri.host == 'email-verified') {
        processVerification();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Apkonkos",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/verify-email', page: () => const VerifyEmailScreen()),
      
        GetPage(
          name: '/email-verified', 
          page: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Menampilkan loading indicator berputar sebentar
            ),
          ),
        ),
      ],
    );
  }
}