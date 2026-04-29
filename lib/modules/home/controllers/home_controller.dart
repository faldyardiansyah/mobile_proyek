import 'package:get/get.dart';
import '../models/property_model.dart';
import '../../../services/api_service.dart';

class HomeController extends GetxController {
  final RxList<Property> allProperties = <Property>[].obs;
  final RxList<Property> properties = <Property>[].obs;
  final RxString searchQuery = ''.obs;

  final ApiService apiService = Get.find<ApiService>();

  final RxList<String> categories = <String>["Semua", "Kosan", "Kontrakan"].obs;

  final RxInt selectedCategoryIndex = 0.obs;

  final RxString selectedSort = ''.obs;
  final RxDouble minRating = 0.0.obs;
  final RxString selectedLocation = 'Semua'.obs;
  final RxDouble maxPrice = 10000000.0.obs;

  var selectedType = ''.obs;
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      final response = await apiService.get('/all-properties');

      print("DATA API: ${response.data}");

      final List data = response.data['data'] ?? [];

      final result = data.map((e) => Property.fromJson(e)).toList();

      allProperties.assignAll(result);
      properties.assignAll(result);
    } catch (e) {
      print("ERROR LOAD PROPERTY: $e");
    }
  }

  void changeTab(int index) {
    tabIndex.value = index;
  }

  void setSort(String type) {
    selectedSort.value = (selectedSort.value == type) ? "" : type;
    applyFilter();
  }

  void setRating(double val) {
    minRating.value = val;
    applyFilter();
  }

  void setMaxPrice(double val) {
    maxPrice.value = val;
    applyFilter();
  }

  void setLocation(String loc) {
    selectedLocation.value = loc;
    applyFilter();
  }

  void setType(String type) {
    selectedType.value = type;
    applyFilter();
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
    applyFilter();
  }

  void searchProperty(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    String selectedCategory = categories[selectedCategoryIndex.value];
    String query = searchQuery.value.toLowerCase().trim();

    var filtered = allProperties.where((property) {
      double price =
          double.tryParse(property.price.replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;

      bool matchesCategory =
          selectedCategory == "Semua" || property.type == selectedCategory;

      bool matchesSearch =
          property.name.toLowerCase().contains(query) ||
          property.location.toLowerCase().contains(query);

      bool matchesRating = property.rating >= minRating.value;

      bool matchesLocation =
          selectedLocation.value == "Semua" ||
          property.location.contains(selectedLocation.value);

      bool matchesPrice = price <= maxPrice.value;

      bool matchesType =
          selectedType.value.isEmpty || property.type == selectedType.value;

      return matchesCategory &&
          matchesSearch &&
          matchesRating &&
          matchesLocation &&
          matchesPrice &&
          matchesType;
    }).toList();

    if (selectedSort.value == "low") {
      filtered.sort((a, b) {
        double pA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        double pB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return pA.compareTo(pB);
      });
    } else if (selectedSort.value == "high") {
      filtered.sort((a, b) {
        double pA =
            double.tryParse(a.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        double pB =
            double.tryParse(b.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return pB.compareTo(pA);
      });
    }

    properties.assignAll(filtered);
  }

  final wishlist = <Property>[].obs;

  bool isFavorite(Property item) {
    return wishlist.any((e) => e.id == item.id);
  }

  void toggleFavorite(Property item) {
    if (isFavorite(item)) {
      wishlist.removeWhere((e) => e.id == item.id);
    } else {
      wishlist.add(item);
    }
  }
}
