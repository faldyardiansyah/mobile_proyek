import 'package:appkonkos_mobile/modules/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import '../chat/chat_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  final List<Map<String, dynamic>> _faqs = const [
    {
      'question': 'Bagaimana cara memesan kosan?',
      'answer': 'Pilih kosan yang diinginkan, klik Pesan Sekarang, pilih kamar yang tersedia, lalu lakukan pembayaran sesuai metode yang dipilih.',
    },
    {
      'question': 'Apakah bisa membatalkan pemesanan?',
      'answer': 'Pemesanan bisa dibatalkan selama status masih Menunggu Pembayaran. Setelah pembayaran dikonfirmasi, pembatalan tidak bisa dilakukan.',
    },
    {
      'question': 'Bagaimana proses refund?',
      'answer': 'Refund akan diproses dalam 3-7 hari kerja setelah pengajuan disetujui oleh pihak pemilik kosan.',
    },
    {
      'question': 'Apakah data saya aman?',
      'answer': 'Data kamu tersimpan dengan aman dan terenkripsi. Kami tidak membagikan data pribadi kepada pihak ketiga.',
    },
    {
      'question': 'Bagaimana cara menghubungi pemilik kosan?',
      'answer': 'Kamu bisa menghubungi pemilik kosan melalui tombol WhatsApp yang tersedia di halaman detail kosan.',
    },
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
          'Pusat Bantuan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari pertanyaan...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: AppColor.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hubungi kami
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primary, AppColor.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 36),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Butuh bantuan langsung?',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 2),
                        Text('Tim kami siap membantu 24/7',
                            style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(() => const ChatScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColor.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('FAQ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8), letterSpacing: 0.5)),
            const SizedBox(height: 12),

            // FAQ accordion
            ...List.generate(_faqs.length, (index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF3FB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${index + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColor.primary, fontSize: 12)),
                    ),
                  ),
                  title: Text(_faqs[index]['question'] as String,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
                  iconColor: AppColor.primary,
                  collapsedIconColor: const Color(0xFF94A3B8),
                  children: [
                    Text(_faqs[index]['answer'] as String,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}