import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/services/api_service.dart';
import '../models/model_riwayat.dart';
import '../controllers/riwayat_controller.dart';

class RefundScreen extends StatefulWidget {
  final ModelRiwayat item;
  const RefundScreen({super.key, required this.item});

  @override
  State<RefundScreen> createState() => _RefundScreenState();
}

class _RefundScreenState extends State<RefundScreen> {
  static const Color blue = Color(0xFF1565C0);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGrey = Color(0xFF7B8794);

  final _alasanCtrl = TextEditingController();
  bool _isLoading = false;
  String? _selectedAlasan;

  final List<String> _alasanOptions = [
    'Kamar tidak sesuai deskripsi',
    'Terjadi perubahan rencana',
    'Masalah dengan pemilik properti',
    'Kondisi properti tidak layak',
    'Lainnya',
  ];

  @override
  void dispose() {
    _alasanCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRefund() async {
    final alasan = _selectedAlasan == 'Lainnya'
        ? _alasanCtrl.text.trim()
        : _selectedAlasan ?? '';

    if (alasan.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Pilih atau isi alasan refund terlebih dahulu',
        backgroundColor: const Color(0xFFFFF3E0),
        colorText: const Color(0xFFE65100),
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = Get.find<ApiService>();
      final rawId = widget.item.rawId ??
          widget.item.id.replaceAll('#BK-', '');

      final response = await api.post('/bookings/$rawId/refund', {
        'alasan_refund': alasan,
      });

      if (response.data['success'] == true) {
        Get.find<RiwayatController>().updateStatus(
          widget.item.id,
          BookingStatus.refund,
        );
        Get.back();
        Get.back();
        Get.snackbar(
          '✅ Refund Diajukan',
          'Permintaan refund sedang diproses oleh admin.',
          backgroundColor: const Color(0xFFF3E5F5),
          colorText: const Color(0xFF6A1B9A),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Gagal',
          response.data['message'] ?? 'Gagal mengajukan refund',
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: Colors.red,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung ke server',
        backgroundColor: const Color(0xFFFFEBEE),
        colorText: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Ajukan Refund',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            children: [
              // Info booking
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: widget.item.imageAsset.isNotEmpty
                          ? Image.network(
                              widget.item.imageAsset,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.price,
                            style: const TextStyle(
                              fontSize: 14,
                              color: blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.item.id,
                            style: const TextStyle(
                              fontSize: 11,
                              color: textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Warning
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Refund akan diproses oleh admin dalam 24 jam. Pastikan alasan refund yang kamu berikan valid.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          
              const SizedBox(height: 12),
          
              // Pilih alasan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Alasan Refund',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._alasanOptions.map((alasan) {
                      final isSelected = _selectedAlasan == alasan;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAlasan = alasan),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? blue
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: isSelected ? blue : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? blue
                                        : const Color(0xFFCBD5E1),
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 12,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                alasan,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  color: isSelected ? blue : textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
          
                    if (_selectedAlasan == 'Lainnya') ...[
                      const SizedBox(height: 4),
                      TextField(
                        controller: _alasanCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Jelaskan alasan refund kamu...',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            color: textGrey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: blue,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          
              const SizedBox(height: 24),
          
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAlasan != null
                        ? Colors.orange.shade700
                        : Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: (_selectedAlasan != null && !_isLoading)
                      ? _submitRefund
                      : null,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Kirim Permintaan Refund',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.home_outlined, color: Colors.grey),
    );
  }
}