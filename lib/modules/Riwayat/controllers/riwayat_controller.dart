import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/model_riwayat.dart';
import 'package:appkonkos_mobile/modules/booking/screens/midtrans_webview_screen.dart';

class RiwayatController extends GetxController {
  final _api = Get.find<ApiService>();
  final selectedTab = 0.obs;
  final tabs = ["Semua", "Menunggu", "Dibayar", "Dibatalkan", "Refund"];
  final _tick = 0.obs;
  final isLoading = false.obs;

  final listRiwayats = <ModelRiwayat>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
    Stream.periodic(const Duration(seconds: 1)).listen((_) => _tick.value++);
  }

  int get tick => _tick.value;

  Future<void> fetchRiwayat() async {
    try {
      isLoading.value = true;
      final response = await _api.getRiwayatBooking();

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        listRiwayats.value = data.map((item) {
          // ambil foto
          String foto = '';
          if (item['kamar'] != null) {
            final fotos = item['kamar']?['tipe_kamar']?['kosan']?['fotos'];
            if (fotos != null && (fotos as List).isNotEmpty) {
              foto = fotos[0]['url']?.toString() ?? '';
            }
          } else if (item['kontrakan'] != null) {
            final fotos = item['kontrakan']?['fotos'];
            if (fotos != null && (fotos as List).isNotEmpty) {
              foto = fotos[0]['url']?.toString() ?? '';
            }
          }

          BookingStatus status;
          switch (item['status_booking']?.toString()) {
            case 'settlement':
            case 'paid':
            case 'lunas':
              status = BookingStatus.dibayar;
              break;
            case 'batal':
              status = BookingStatus.dibatalkan;
              break;
            case 'refund':
              status = BookingStatus.refund;
              break;
            default:
              status = BookingStatus.menunggu;
          }

          final String bookingId = item['id']?.toString() ?? '';
          final String namaTitle =
              item['kamar']?['tipe_kamar']?['nama'] ??
              item['kontrakan']?['nama'] ??
              'Properti';
          final String alamat =
              item['kamar']?['tipe_kamar']?['kosan']?['alamat'] ??
              item['kontrakan']?['alamat'] ??
              '';
          final int totalBiaya = item['total_biaya'] ?? 0;

          return ModelRiwayat(
            id: '#BK-${bookingId.length >= 8 ? bookingId.substring(0, 8).toUpperCase() : bookingId.toUpperCase()}',
            rawId: bookingId,
            title: namaTitle,
            location: alamat,
            price: 'Rp ${_formatHarga(totalBiaya.toString())}',
            status: status,
            imageAsset: foto,
            bookingTime: item['created_at'] != null
                ? DateTime.tryParse(item['created_at'])
                : null,
            totalHarga: totalBiaya,
          );
        }).toList();
      }
    } catch (e) {
      print('>>> ERROR FETCH RIWAYAT: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> batalkanBooking(ModelRiwayat item) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Booking?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin membatalkan booking ${item.title}?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tidak', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Get.back();
              try {
                // pakai rawId untuk hit API
                await _api.cancelBooking(item.rawId ?? item.id);
                await fetchRiwayat(); // refresh dari server
                Get.snackbar(
                  'Dibatalkan',
                  'Booking ${item.title} telah dibatalkan',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  snackPosition: SnackPosition.TOP,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal membatalkan booking',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                );
              }
            },
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<ModelRiwayat> get filteredList {
    _tick.value;
    if (selectedTab.value == 0) return listRiwayats;
    final statusMap = {
      1: BookingStatus.menunggu,
      2: BookingStatus.dibayar,
      3: BookingStatus.dibatalkan,
      4: BookingStatus.refund,
    };
    return listRiwayats
        .where((b) => b.status == statusMap[selectedTab.value])
        .toList();
  }

  void selectTab(int index) => selectedTab.value = index;

  void tambahRiwayat({
    required String id,
    String? rawId,
    required String title,
    required String location,
    required String price,
    required BookingStatus status,
    required String imageAsset,
    DateTime? bookingTime,
    String? redirectUrl,
    int? totalHarga,
  }) {
    final index = listRiwayats.indexWhere((r) => r.id == id);
    final item = ModelRiwayat(
      id: id,
      rawId: rawId,
      title: title,
      location: location,
      price: price,
      status: status,
      imageAsset: imageAsset,
      bookingTime: bookingTime,
      redirectUrl: redirectUrl,
      totalHarga: totalHarga,
    );
    if (index >= 0) {
      listRiwayats[index] = item;
    } else {
      listRiwayats.insert(0, item);
    }
  }

  void updateStatus(String id, BookingStatus status) {
    final index = listRiwayats.indexWhere((r) => r.id == id);
    if (index >= 0) {
      final old = listRiwayats[index];
      listRiwayats[index] = ModelRiwayat(
        id: old.id,
        rawId: old.rawId, // ← tambah ini
        title: old.title,
        location: old.location,
        price: old.price,
        status: status,
        imageAsset: old.imageAsset,
        bookingTime: old.bookingTime,
        redirectUrl: old.redirectUrl,
        totalHarga: old.totalHarga,
      );
    }
  }

  void ajukanRefund(ModelRiwayat item) {
    Get.snackbar(
      'Refund',
      'Mengajukan refund untuk ${item.title}',
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      snackPosition: SnackPosition.TOP,
    );
  }

  void bayarSekarang(ModelRiwayat item) {
    if (item.redirectUrl == null || item.redirectUrl!.isEmpty) {
      Get.snackbar(
        'Error',
        'URL pembayaran tidak tersedia',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return;
    }
    if (item.sisaWaktu == Duration.zero) {
      Get.snackbar(
        'Kadaluarsa',
        'Waktu pembayaran sudah habis',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return;
    }
    Get.to(
      () => MidtransWebView(
        url: item.redirectUrl!,
        totalHarga: item.totalHarga ?? 0,
        bookingId: item.rawId ?? '',
        tipeKamarNama: item.title,
      ),
    );
  }

  String _formatHarga(String angka) {
    final number = int.tryParse(angka) ?? 0;
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
