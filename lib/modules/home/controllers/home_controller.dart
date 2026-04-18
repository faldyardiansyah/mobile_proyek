import 'package:get/get.dart';
import '../models/property_model.dart';

class HomeController extends GetxController {
  final RxList<Property> allProperties = <Property>[].obs;
  final RxList<Property> properties = <Property>[].obs;
  final RxString searchQuery = ''.obs;
  
  final RxList<String> categories = <String>[
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
        location: "Lobener, Indramayu",
        price: "600.000",
        rating: 4.5,
        isYearly: false,
      ),
    ];
    allProperties.assignAll(data);
    properties.assignAll(data);
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

  var selectedType = ''.obs;
  void setType(String type){
    selectedType.value = type;
    applyFilter();
  }
  void applyFilter() {
    String selectedCategory = categories[selectedCategoryIndex.value].trim();
    String query = searchQuery.value.toLowerCase().trim();

    var filteredData = allProperties.where((property) {
    bool matchesCategory = selectedCategory == "Semua" || 
        property.type.trim() == selectedCategory;

    bool matchesSearch =
        property.name.toLowerCase().contains(query) ||
        property.location.toLowerCase().contains(query);

    bool matchesRating = property.rating >= minRating.value;

    bool matchesLocation =
        selectedLocation.value == "Semua" ||
        property.location.contains(selectedLocation.value);

    double priceDouble =
        double.tryParse(property.price.replaceAll('.', '')) ?? 0;
    bool matchesPrice = priceDouble <= maxPrice.value;

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
      filteredData.sort((a, b) {
        double pA = double.tryParse(a.price.replaceAll('.', '')) ?? 0;
        double pB = double.tryParse(b.price.replaceAll('.', '')) ?? 0;
        return pA.compareTo(pB);
      });
    } else if (selectedSort.value == "high") {
      filteredData.sort((a, b) {
        double pA = double.tryParse(a.price.replaceAll('.', '')) ?? 0;
        double pB = double.tryParse(b.price.replaceAll('.', '')) ?? 0;
        return pB.compareTo(pA);
      });
    }

    properties.assignAll(filteredData);
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
    applyFilter();
  }

  void searchProperty(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  var wishlist = <Property>[].obs;

  bool isFavorite(Property item) {
    return wishlist.contains(item);
  }

  void toggleFavorite(Property item) {
    if (wishlist.contains(item)) {
      wishlist.remove(item);
    } else {
      wishlist.add(item);
    }
  }
}