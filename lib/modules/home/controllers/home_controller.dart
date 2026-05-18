import 'package:get/get.dart';
import '../models/property_model.dart';
import '../../../services/api_service.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final RxList<Property> allProperties = <Property>[].obs;
  final RxList<Property> properties = <Property>[].obs;
  final RxString searchQuery = ''.obs;

  final ApiService apiService = Get.find<ApiService>();

  final RxList<String> categories = <String>[
    "Semua",
    "Putra",
    "Putri",
    "Campur",
    "Kontrakan",
  ].obs;

  final RxList<String> genderOptions = <String>[
    "Semua",
    "Putra",
    "Putri",
    "Campur",
  ].obs;

  final RxInt selectedCategoryIndex = 0.obs;
  final RxString selectedSort = ''.obs;
  final RxDouble minRating = 0.0.obs;
  final RxString selectedLocation = 'Semua'.obs;
  final RxDouble maxPrice = 10000000.0.obs;
  final RxString selectedGender = ''.obs;

  final box = GetStorage();
  var wishlist = <Property>[].obs;
  var selectedType = ''.obs;
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadProperties();
    final user = box.read('user');
    if (user != null) {
      final userId = user['id'];
      final data = box.read('wishlist_$userId');
      if (data != null) {
        wishlist.value = (data as List)
            .map((e) => Property.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }
  }

  var isLoading = true.obs;
  var isSkeleton = true.obs;

  Future<void> loadProperties() async {
    try {
      isSkeleton.value = true;
      isLoading.value = true;
      final response = await apiService.get('/all-properties');
      print("DATA API: ${response.data}");
      final List data = response.data['data'] ?? [];
      final result = data.map((e) => Property.fromJson(e)).toList();
      allProperties.assignAll(result);
      properties.assignAll(result);
      await Future.delayed(const Duration(seconds: 2));
      isSkeleton.value = false;
    } catch (e) {
      print("ERROR LOAD PROPERTY: $e");
    } finally {
      isLoading.value = false;
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

  void setGender(String gender) {
    selectedGender.value = (gender == "Semua") ? "" : gender;
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
          selectedCategory == "Semua" ||
          property.type.toLowerCase().trim() ==
              selectedCategory.toLowerCase().trim() ||
          property.gender.toLowerCase().trim() ==
              selectedCategory.toLowerCase().trim();

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

      // filter gender hanya berlaku untuk kosan
      bool matchesGender =
          selectedGender.value.isEmpty ||
          property.type != "Kosan" ||
          property.gender.toLowerCase() == selectedGender.value.toLowerCase();

      return matchesCategory &&
          matchesSearch &&
          matchesRating &&
          matchesLocation &&
          matchesPrice &&
          matchesType &&
          matchesGender;
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

  bool isFavorite(Property item) {
    return wishlist.any((e) => e.id == item.id);
  }

  void toggleFavorite(Property item) {
    final user = box.read('user');
    final userId = user['id'];

    if (isFavorite(item)) {
      wishlist.removeWhere((e) => e.id == item.id);
    } else {
      wishlist.add(item);
    }

    box.write(
      'wishlist_$userId',
      wishlist
          .map(
            (e) => {
              'id': e.id,
              'nama': e.name,
              'harga': e.price,
              'harga_max': e.priceMax,
              'alamat': e.location,
              'rating': e.rating,
              'tipe': e.type,
              'foto': e.foto,
              'period': e.period,
              'lat': e.lat,
              'lng': e.lng,
              'gender': e.gender,
            },
          )
          .toList(),
    );
  }
}
