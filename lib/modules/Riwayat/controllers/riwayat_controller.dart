import "package:get/get.dart";
import 'package:flutter/material.dart';
import '../models/model_riwayat.dart';

class RiwayatController extends GetxController{
  final selectedTab = 0.obs;
  final tabs = ["Semua", "Menunggu", "Dibayar", "Refund"];

  final listRiwayats = <ModelRiwayat>[
    ModelRiwayat(id: '#BK-3821', title: 'Kost Faldy', location: 'Lohbener, Indramayu', price: 'Rp 600.000', status: BookingStatus.dibayar, imageAsset: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=200'),
    ModelRiwayat(id: '#BK-3822', title: 'Kontrakan Pak Budi', location: 'Logbener, Indramayu', price: 'Rp 600.000', status: BookingStatus.menunggu, imageAsset: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=200'),
    ModelRiwayat(id: '#BK-3823', title: 'Kost Melati Eksklusif', location: 'Kebayoran Baru, Jakarta Selatan', price: 'Rp 2.500.000', status: BookingStatus.refund, imageAsset: 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=200'),
  ].obs;

  List<ModelRiwayat> get filteredList {
    if (selectedTab.value == 0) return listRiwayats;
    final statusMap = {
      1: BookingStatus.menunggu,
      2: BookingStatus.dibayar,
      3: BookingStatus.refund,
    };
    return listRiwayats.where((b) => b.status == statusMap[selectedTab.value]).toList();
  }

    void selectTab(int index) => selectedTab.value = index;
  
  void ajukanRefund(ModelRiwayat item){
    Get.snackbar('Refund', 'Mengajukan refund untuk ${item.title}',
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      snackPosition: SnackPosition.TOP,
    );
  }
  void bayarSekarang(ModelRiwayat item){
    Get.snackbar('Pembayaran', 'Mengajukan pembayaran untuk ${item.title}',
      backgroundColor: Colors.orange.shade50,
      colorText: Colors.orange.shade800,
      snackPosition: SnackPosition.TOP,
    );
  }
}