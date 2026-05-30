import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  final List<Map<String, dynamic>> _methods = const [
    {'name': 'BCA Virtual Account', 'number': '1234 5678 9012', 'icon': Icons.account_balance_outlined, 'active': true},
    {'name': 'Mandiri Virtual Account', 'number': '9876 5432 1098', 'icon': Icons.account_balance_outlined, 'active': false},
    {'name': 'GoPay', 'number': '0812 3456 7890', 'icon': Icons.wallet_outlined, 'active': false},
    {'name': 'OVO', 'number': '0812 3456 7890', 'icon': Icons.wallet_outlined, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metode Tersimpan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: _methods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final method = _methods[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: method['active'] ? AppColor.primary : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3FB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(method['icon'] as IconData, color: AppColor.primary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(method['name'] as String,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(method['number'] as String,
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                                ],
                              ),
                            ),
                            if (method['active'] as bool)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('Utama',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColor.primary)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.add, color: AppColor.primary),
                    label: Text('Tambah Metode Pembayaran',
                        style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}