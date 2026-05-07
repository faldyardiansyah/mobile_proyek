import 'package:get/get.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import '../../home/models/property_model.dart'; 

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
    fetchDetail(int.parse(args.id.toString()), args.type);
  }

  @override
  void onClose() {
    detail.value = null;
    selectedRoomTypeId.value = null;
    selectedRoomId.value = null;
    super.onClose();
  }

  Future<void> fetchDetail(int id, String tipe) async {
    try {
      isLoading(true);
      print("=== FETCH: tipe=$tipe id=$id ==="); 
      final res = tipe == 'Kosan'
          ? await _api.getDetailKosan(id)
          : await _api.getDetailKontrakan(id);
      print("=== RESPONSE: ${res.data} ==="); 
      detail.value = res.data['data'];
    } catch (e) {
      print("=== ERROR: $e ==="); 
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
    final tipe = detail.value?['tipe'] ?? '';
    if (tipe == 'Kosan') {
      return selectedRoomTypeId.value != null && selectedRoomId.value != null;
    }
    return true;
  }
}