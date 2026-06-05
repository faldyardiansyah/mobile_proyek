import 'package:get/get.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import '../../home/models/property_model.dart';
import '../controllers/ulasan_controller.dart';

class DetailController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = true.obs;
  final detail = Rxn<Map<String, dynamic>>();
  final selectedRoomTypeId = Rxn<int>();
  final selectedRoomId = Rxn<int>();

  @override
void onInit() {
  super.onInit();
  final Property args = Get.arguments as Property;
  final int id = int.parse(args.id.toString());
  final String tipe = args.type.toLowerCase();

  fetchDetail(id, args.type).then((_) {
    final ulasanCtrl = Get.isRegistered<UlasanController>()
        ? Get.find<UlasanController>()
        : Get.put(UlasanController());
    ulasanCtrl.loadUlasan(tipe, id);  
    ulasanCtrl.cekBolehReview(tipe, id);   
  });
}

  @override
  void onClose() {
    detail.value = null;
    selectedRoomTypeId.value = null;
    selectedRoomId.value = null;
    if (Get.isRegistered<UlasanController>()) {
      Get.delete<UlasanController>();
    }
    super.onClose();
  }

  Future<void> fetchDetail(int id, String tipe) async {
  try {
    isLoading(true);
    final res = tipe == 'Kosan'
        ? await _api.getDetailKosan(id)
        : await _api.getDetailKontrakan(id);
    
    detail.value = res.data['data']; 
    final rt = detail.value?['room_types'];
    if (rt is List && rt.isNotEmpty) {
      print("=== KEY FASILITAS KAMAR: ${rt[0].keys.toList()} ===");
      print("=== FASILITAS KAMAR: ${rt[0]['fasilitas']} ===");
      print("=== FASILITAS TIPE: ${rt[0]['fasilitas_tipe']} ===");
    }
    print("=== FASILITAS UMUM: ${detail.value?['fasilitas_umum']} ===");

  } catch (e) {
    Get.snackbar('Error', 'Gagal memuat detail properti');
  } finally {
    isLoading(false);
  }
}

  List<dynamic> get roomTypes => detail.value?['room_types'] ?? [];

  List<dynamic> roomsForType(int typeId) {
    final found = roomTypes.firstWhereOrNull((t) => t['id'] == typeId);
    return found?['rooms'] ?? [];
  }

  void selectRoomType(int id) {
    selectedRoomTypeId.value = id;
    selectedRoomId.value = null;
  }

  void selectRoom(int id) {
    selectedRoomId.value = id;
  }

  bool get canBook {
    final tipe = detail.value?['tipe']?.toString().toLowerCase() ?? '';

    if (tipe == 'kosan') {
      return selectedRoomTypeId.value != null && selectedRoomId.value != null;
    }

    return true;
  }
}
