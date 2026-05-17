import 'package:appkonkos_mobile/modules/profile/personal_info_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BookingController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final _storage = GetStorage();
  final durasiController = TextEditingController(text: '1');

  final RxInt selectedDurasi = 1.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final tipeProperty = ''.obs;

  String? kamarId;
  String? kamarNama;
  int? hargaPerBulan;
  String? tipeKamarNama;
  String? kontrakanId;

  final List<int> opsiDurasi = [1, 2, 3];

  int get totalBiaya => (hargaPerBulan ?? 0) * selectedDurasi.value;

  void setKamar({
  String? id,
  String? kId,
  required String nama,
  required int harga,
  required String tipeNama,
}) {
  kamarId = id;
  kontrakanId = kId;
  kamarNama = nama;
  hargaPerBulan = harga;
  tipeKamarNama = tipeNama;
  selectedDurasi.value = 1;
  errorMessage.value = '';
}

  void selectDurasi(int bulan) {
    selectedDurasi.value = bulan;
  }

  String get formattedHargaPerBulan =>
      _formatHarga(hargaPerBulan?.toString() ?? '0');
  String get formattedTotal => _formatHarga(totalBiaya.toString());

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  void setTipeProperty(String tipe) {
    tipeProperty.value = tipe;
  }

  Future<bool> submitBooking() async {
    if (kamarId == null && kontrakanId == null) {
      errorMessage.value = 'Kamar tidak valid.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final now = DateTime.now();
      final tglMulai =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final body = <String, dynamic>{
        'tgl_mulai_sewa': tglMulai,
        'durasi_bulan': selectedDurasi.value,
      };
      if (kamarId != null) body['kamar_id'] = kamarId;
      if (kontrakanId != null) body['kontrakan_id'] = kontrakanId;

      final response = await _api.post('/bookings', body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        final snapToken = response.data['snap_token'];
        final redirectUrl = response.data['redirect_url'];
        print('>>> SNAP TOKEN: $snapToken');
        print('>>> REDIRECT URL: $redirectUrl');

        // Buka halaman pembayaran Midtrans
        if (redirectUrl != null) {
          Get.back();
          await Future.delayed(const Duration(milliseconds: 300));
          _openMidtransPayment(redirectUrl);
          return true;
        }
        return true;
      } else if (response.data['message'] == 'profil_tidak_lengkap') {
        // Profil tidak lengkap — arahkan ke halaman profil
        Get.back();
        _showProfilTidakLengkap(response.data['field_kosong'] ?? []);
        return false;
      } else {
        errorMessage.value =
            response.data['message'] ?? 'Booking gagal. Coba lagi.';
        return false;
      }
    } catch (e) {
      final dynamic err = e;
      if (err?.response != null) {
        final data = err.response?.data;

        // Cek profil tidak lengkap dari exception
        if (data is Map && data['message'] == 'profil_tidak_lengkap') {
          Get.back();
          _showProfilTidakLengkap(
            List<String>.from(data['field_kosong'] ?? []),
          );
          return false;
        }

        errorMessage.value = data is Map && data['message'] != null
            ? data['message']
            : 'Terjadi kesalahan. Coba lagi.';
      } else {
        errorMessage.value = 'Tidak dapat terhubung ke server.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Buka WebView Midtrans
  void _openMidtransPayment(String url) {
    Get.to(() => MidtransWebView(url: url));
  }

  // Dialog profil tidak lengkap
  void _showProfilTidakLengkap(List fieldKosong) {
    final labelMap = {
      'no_telepon': 'Nomor Telepon',
      'no_wa': 'Nomor WhatsApp',
      'domisili': 'Domisili',
      'jenis_kelamin': 'Jenis Kelamin',
      'pekerjaan': 'Pekerjaan',
    };

    final labels = fieldKosong.map((f) => labelMap[f] ?? f).toList();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text(
              'Profil Belum Lengkap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lengkapi profil dulu sebelum booking ya! Data yang belum diisi:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...labels.map(
              (label) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel_outlined,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Nanti', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BC2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Get.back();
              // Navigasi ke halaman personal info
              Get.to(() => PersonalInfoScreen())?.then((_) {
                Get.snackbar(
                  'Profil Diperbarui',
                  'Silakan lanjutkan booking kamu!',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFFE3F2FD),
                  colorText: const Color(0xFF0D47A1),
                );
              });
            },
            child: const Text(
              'Lengkapi Profil',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ===== WebView untuk Midtrans =====
class MidtransWebView extends StatefulWidget {
  final String url;
  const MidtransWebView({super.key, required this.url});

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            // Deteksi callback Midtrans
            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              Get.back();
              Get.snackbar(
                '✅ Pembayaran Berhasil',
                'Booking kamu sudah dikonfirmasi!',
                backgroundColor: const Color(0xFFE8F5E9),
                colorText: const Color(0xFF2E7D32),
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 4),
              );
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=pending')) {
              Get.back();
              Get.snackbar(
                '⏳ Menunggu Pembayaran',
                'Selesaikan pembayaran sebelum batas waktu ya!',
                snackPosition: SnackPosition.TOP,
                duration: const Duration(seconds: 4),
              );
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              Get.back();
              Get.snackbar(
                '❌ Pembayaran Gagal',
                'Pembayaran dibatalkan atau kadaluarsa.',
                backgroundColor: const Color(0xFFFFEBEE),
                colorText: const Color(0xFFC62828),
                snackPosition: SnackPosition.TOP,
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: Color(0xFF0B1020),
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0B1020)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF007BC2)),
            ),
        ],
      ),
    );
  }
}
