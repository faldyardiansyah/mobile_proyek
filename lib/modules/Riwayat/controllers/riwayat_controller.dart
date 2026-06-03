import 'package:appkonkos_mobile/services/api_service.dart';
import 'package:appkonkos_mobile/services/notification_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import '../models/model_riwayat.dart';
import 'package:appkonkos_mobile/modules/booking/screens/midtrans_webview_screen.dart';

class RiwayatController extends GetxController {
  final _api = Get.find<ApiService>();
  final _box = GetStorage();
  final selectedTab = 0.obs;
  final tabs = ["Semua", "Menunggu", "Dibayar", "Dibatalkan", "Refund"];
  final _tick = 0.obs;
  final isLoading = false.obs;
  final listRiwayats = <ModelRiwayat>[].obs;
  final _processingCancel = <String>{};

  String get _cacheKey {
    final userId = _box.read('user_id') ?? 'guest';
    return 'riwayat_cache_$userId';
  }

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    fetchRiwayat();
    Stream.periodic(const Duration(seconds: 5)).listen((_) {
      _tick.value++;
      _cekAutoCancel();
    });
  }

  int get tick => _tick.value;

  void _loadCache() {
    try {
      final raw = _box.read(_cacheKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw);
        listRiwayats.value = decoded
            .map((e) => ModelRiwayat.fromJson(e))
            .toList();
      }
    } catch (e) {
      print('>>> ERROR LOAD CACHE: $e');
    }
  }

  void _saveCache() {
    try {
      final encoded = jsonEncode(listRiwayats.map((e) => e.toJson()).toList());
      _box.write(_cacheKey, encoded);
    } catch (e) {
      print('>>> ERROR SAVE CACHE: $e');
    }
  }

  Future<void> clearCache() async {
    await _box.remove(_cacheKey);
    listRiwayats.clear();
  }

  void _cekAutoCancel() {
    final expired = listRiwayats
        .where(
          (r) =>
              r.status == BookingStatus.menunggu &&
              r.bookingTime != null &&
              r.sisaWaktu == Duration.zero,
        )
        .toList();

    for (final item in expired) {
      final bookingId = item.rawId ?? item.id;
      if (_processingCancel.contains(bookingId)) continue;
      _processingCancel.add(bookingId);
      _autoCancelBooking(item, bookingId);
    }
  }

  Future<void> submitRefund(ModelRiwayat item, String alasan) async {
    try {
      final response = await _api.refundBooking(item.rawId ?? item.id, alasan);
      if (response.data['success'] == true) {
        updateStatus(item.id, BookingStatus.refund);
        await fetchRiwayat();
        Get.snackbar(
          'Berhasil',
          'Pengajuan refund berhasil dikirim',
          backgroundColor: Colors.purple.shade50,
          colorText: Colors.purple.shade800,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengajukan refund',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    }
  }

  Future<void> _autoCancelBooking(ModelRiwayat item, String bookingId) async {
    try {
      updateStatus(item.id, BookingStatus.dibatalkan);
      await _api.cancelBooking(bookingId);
    } catch (e) {
      print('ERROR AUTO CANCEL: $e');
    } finally {
      _processingCancel.remove(bookingId);
    }
  }

  Future<void> fetchRiwayat() async {
    try {
      isLoading.value = true;
      final response = await _api.getRiwayatBooking();

      if (response.data['success'] == true) {
        final List data = response.data['data'];
        listRiwayats.value = data.map((item) {
          final String foto = item['foto']?.toString() ?? '';
          final String namaTitle = item['nama']?.toString() ?? 'Properti';
          final String alamat = item['alamat']?.toString() ?? '';
          final int totalBiaya = item['total_biaya'] ?? 0;

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
            redirectUrl: item['redirect_url']?.toString() ?? '',
            checkIn: item['check_in'] != null
                ? DateTime.tryParse(item['check_in'])
                : null,
            checkOut: item['check_out'] != null
                ? DateTime.tryParse(item['check_out'])
                : null,
            refundStatus: item['refund_status']?.toString(),
            alasanRefund: item['alasan_refund']?.toString(),
            nominalRefund: item['nominal_refund'] != null
                ? int.tryParse(item['nominal_refund'].toString())
                : null,
            noWaPemilik: item['no_wa_pemilik']?.toString() ?? '',
            tipeProperty: item['tipe_property']?.toString() ?? '',
            durasi: item['durasi'] != null
                ? int.tryParse(item['durasi'].toString()) ?? 0
                : 0,
            buktiTransfer: item['bukti_transfer']?.toString(),
            kamarNama: item['kamar_nama']?.toString() ?? '', 
            tipeKamar: item['tipe_kamar']?.toString() ?? '', 
            gender: item['gender']?.toString() ?? '',
          );
        }).toList();

        _saveCache();
      }
    } catch (e) {
      print('>>> ERROR FETCH RIWAYAT: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> hapusRiwayat(ModelRiwayat item) async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Hapus riwayat booking ${item.title} dari daftar?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
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
                await _api.deleteBooking(item.rawId ?? item.id);
                listRiwayats.removeWhere((r) => r.id == item.id);
                _saveCache();
                Get.snackbar(
                  'Dihapus',
                  'Riwayat booking ${item.title} telah dihapus',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                  snackPosition: SnackPosition.TOP,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus riwayat',
                  backgroundColor: Colors.red.shade50,
                  colorText: Colors.red.shade800,
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
                await _api.cancelBooking(item.rawId ?? item.id);
                await fetchRiwayat();
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

  _saveCache();

  if (bookingTime != null) {
    final localBookingTime = bookingTime.toLocal(); 
    final now = DateTime.now();
    final deadline = localBookingTime.add(const Duration(hours: 24));
    final notif5Min = deadline.subtract(const Duration(minutes: 5));
    final notif1Min = deadline.subtract(const Duration(minutes: 1));

    if (notif5Min.isAfter(now)) {
      NotificationService().schedule(
        id: id.hashCode,
        title: '⏰ Segera Bayar!',
        body: 'Booking $title akan kedaluwarsa dalam 5 menit!',
        scheduledTime: notif5Min,
        type: NotifType.segeraBayar,
      );
    }

    if (notif1Min.isAfter(now)) {
      NotificationService().schedule(
        id: id.hashCode + 1,
        title: '🚨 1 Menit Lagi!',
        body: 'Booking $title akan kedaluwarsa dalam 1 menit!',
        scheduledTime: notif1Min,
        type: NotifType.segeraBayar,
      );
    }
  }
}

  void updateStatus(String id, BookingStatus status) {
  final index = listRiwayats.indexWhere((r) => r.id == id);
  if (index >= 0) {
    final old = listRiwayats[index];
    listRiwayats[index] = ModelRiwayat(
      id: old.id,
      rawId: old.rawId,
      title: old.title,
      location: old.location,
      price: old.price,
      status: status,
      imageAsset: old.imageAsset,
      bookingTime: old.bookingTime,
      redirectUrl: old.redirectUrl,
      totalHarga: old.totalHarga,
      refundStatus: old.refundStatus,
      alasanRefund: old.alasanRefund,
      nominalRefund: old.nominalRefund,
      noWaPemilik: old.noWaPemilik,
      tipeProperty: old.tipeProperty,
      durasi: old.durasi,
      checkIn: old.checkIn,
      checkOut: old.checkOut,
      buktiTransfer: old.buktiTransfer,
      kamarNama: old.kamarNama,   
      tipeKamar: old.tipeKamar,  
      gender: old.gender,        
    );
    switch (status) {
      case BookingStatus.dibayar:
        NotificationService().show(
          id: old.hashCode + 10,
          title: '✅ Pembayaran Berhasil!',
          body: 'Booking ${old.title} telah dikonfirmasi.',
          type: NotifType.pembayaranBerhasil,
        );
        NotificationService().cancel(old.id.hashCode);
        NotificationService().cancel(old.id.hashCode + 1);
        break;
      case BookingStatus.dibatalkan:
        NotificationService().show(
          id: old.hashCode + 20,
          title: '❌ Booking Dibatalkan',
          body: 'Booking ${old.title} telah dibatalkan.',
          type: NotifType.pembayaranGagal,
        );
        NotificationService().cancel(old.id.hashCode);
        NotificationService().cancel(old.id.hashCode + 1);
        break;
      case BookingStatus.refund:
        NotificationService().show(
          id: old.hashCode + 30,
          title: '🔄 Refund Diajukan',
          body: 'Permintaan refund ${old.title} sedang diproses.',
          type: NotifType.refund,
        );
        break;
      default:
        break;
    }
    _saveCache();
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
        tglMulai: item.checkIn != null
            ? '${item.checkIn!.year}-${item.checkIn!.month.toString().padLeft(2, '0')}-${item.checkIn!.day.toString().padLeft(2, '0')}'
            : '',
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
