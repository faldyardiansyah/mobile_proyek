import 'package:get/get.dart';
import '../models/property_model.dart';

class HomeController extends GetxController {
  // Gunakan RxList agar reaktif dan hindari error JSArray
  final RxList<Property> properties = <Property>[].obs;
  final RxList<String> categories = <String>[
    "Semua",
    "Putra",
    "Putri",
    "Campur",
  ].obs;
  final RxInt selectedCategoryIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDummyData();
  }

  var tabIndex = 0.obs;

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void loadDummyData() {
    // Data dummy sesuai mockup
    var data = [
      Property(
        name: "Kost Exclusive Melati",
        type: "Putra",
        location: "Kebayoran Baru, Jakarta Selatan",
        price: "2.500.000",
        rating: 4.8,
        isYearly: false,
      ),
      Property(
        name: "Kontrakan Pak Budi",
        type: "Campur",
        location: "Margonda, Depok",
        price: "1.200.000",
        rating: 4.5,
        isYearly: false,
      ),
    ];
    properties.assignAll(
      data,
    ); // .assignAll wajib supaya Obx sadar ada data baru
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
  }
}
