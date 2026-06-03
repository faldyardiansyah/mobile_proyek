import 'package:get/get.dart';
import 'package:appkonkos_mobile/services/api_service.dart';

class UlasanSayaController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // Ulasan yang sudah ditulis
  final ulasanList = <Map<String, dynamic>>[].obs;
  
  // Booking yang sudah lunas tapi belum direview
  final bookingBelumReview = <Map<String, dynamic>>[].obs;
  
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSemua();
  }

  Future<void> loadSemua() async {
    isLoading(true);
    await Future.wait([
      loadUlasanSaya(),
      loadBookingBelumReview(),
    ]);
    isLoading(false);
  }

  Future<void> loadUlasanSaya() async {
    try {
      final res = await _api.getUlasanSaya();
      if (res.data['success'] == true) {
        ulasanList.value =
            List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      print('ERROR ulasan saya: $e');
    }
  }

  Future<void> loadBookingBelumReview() async {
    try {
      final res = await _api.getBookingBelumReview();
      if (res.data['success'] == true) {
        // Simpan booking yang belum direview
        bookingBelumReview.value =
            List<Map<String, dynamic>>.from(res.data['data']);
      }
    } catch (e) {
      print('ERROR booking belum review: $e');
    }
  }
}