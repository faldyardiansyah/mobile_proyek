import 'package:get/get.dart';
import 'package:appkonkos_mobile/modules/Riwayat/models/model_riwayat.dart';

class RiwayatController extends GetxController {
  var selectedTab = 0.obs;

  var riwayats = <Riwayat>[
    Riwayat(
      title: 'Kost Faldy',
      location: 'Lohbener, indaramayu',
      price: 600000,
      image: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
      status: 'dibayar',
      date: "",
    ),
    Riwayat(
      title: 'Kontrakan Hanif',
      location: 'Lohbener, indaramayu',
      price: 600000,
      image: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
      status: 'Menunggu',
      date: "",
    ),
    Riwayat(
      title: 'Kost Mutiara',
      location: 'Lohbener, indaramayu',
      price: 600000,
      image: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80',
      status: 'refound',
      date: "dibatalkan pada 2025-03-31",
    )
  ].obs;

  List<Riwayat> get filteredriwayats {
    if (selectedTab.value == 0) return riwayats; 
      if (selectedTab.value == 1) return riwayats.where((riwayat) => riwayat.status == 'Menunggu').toList();
      if (selectedTab.value == 2) return riwayats.where((riwayat) => riwayat.status == 'dibayar').toList();
      if (selectedTab.value == 3) return riwayats.where((riwayat) => riwayat.status == 'refound').toList();
      return riwayats;
  }
}