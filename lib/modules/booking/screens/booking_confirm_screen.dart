import 'package:appkonkos_mobile/modules/booking/controllers/booking_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:appkonkos_mobile/auth/controller/auth_controller.dart';

class BookingConfirmScreen extends StatefulWidget {
  final String redirectUrl;
  final String bookingId;
  final int totalHarga;
  final String kamarNama;
  final String tipeKamarNama;
  final int durasi;
  final int hargaPerBulan;
  final String tipeProperty;
  final String peraturan;

  const BookingConfirmScreen({
    super.key,
    required this.redirectUrl,
    required this.bookingId,
    required this.totalHarga,
    required this.kamarNama,
    required this.tipeKamarNama,
    required this.durasi,
    required this.hargaPerBulan,
    required this.tipeProperty,
    this.peraturan = '',
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  static const Color blue = Color(0xFF007BC2);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

  bool _setuju = false;
  DateTime _tglMulai = DateTime.now();
   DateTime _tambahBulan(DateTime date, int bulan) {
    int totalBulan = date.month + bulan;
    int tahun = date.year + ((totalBulan - 1) ~/ 12);
    int bulanBaru = ((totalBulan - 1) % 12) + 1;
    int hariMax = DateUtils.getDaysInMonth(tahun, bulanBaru);
    int hari = date.day > hariMax ? hariMax : date.day;
    return DateTime(tahun, bulanBaru, hari);
  }

  String _formatHarga(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatTanggal(DateTime dt) {
    final bulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  String _formatJenisKelamin(String raw) {
    switch (raw.toUpperCase()) {
      case 'L': return 'Laki-laki';
      case 'P': return 'Perempuan';
      default:  return raw.isEmpty ? '-' : raw;
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tglMulai,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tglMulai = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    final user = authC.user;
    final satuanDurasi = widget.tipeProperty == 'Kontrakan' ? 'Tahun' : 'Bulan';
    const biayaLayanan = 10000;
    final total = widget.totalHarga + biayaLayanan;

    final tglSelesai = widget.tipeProperty == 'Kontrakan'
    ? DateTime(_tglMulai.year + widget.durasi, _tglMulai.month, _tglMulai.day)
    : _tambahBulan(_tglMulai, widget.durasi);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Konfirmasi & Bayar',
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
          child: Column(
            children: [
              // === DATA PENYEWA ===
              _sectionCard(
                title: 'Data Penyewa',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline, color: blue, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Data ini diambil dari profil Anda dan digunakan oleh pemilik properti untuk verifikasi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: blue,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow('NAMA LENGKAP', user['name']?.toString() ?? '-'),
                    _infoRow('EMAIL', user['email']?.toString() ?? '-'),
                    _infoRow('NOMOR TELEPON', user['no_telepon']?.toString() ?? '-'),
                    _infoRow(
                      'JENIS KELAMIN',
                      _formatJenisKelamin(user['jenis_kelamin']?.toString() ?? ''),
                    ),
                    _infoRow('PEKERJAAN', user['pekerjaan']?.toString() ?? '-'),
                    _infoRow('DOMISILI', user['kota_asal']?.toString() ?? '-'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // === DETAIL WAKTU SEWA ===
              _sectionCard(
                title: 'Detail Waktu Sewa',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bed_outlined, color: blue, size: 20),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tipeKamarNama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                widget.kamarNama.isNotEmpty
                                    ? 'Kamar ${widget.kamarNama}'
                                    : widget.tipeKamarNama,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow('DURASI SEWA', '${widget.durasi} $satuanDurasi'),
                    const SizedBox(height: 4),

                    // Tanggal check-in
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANGGAL CHECK-IN',
                          style: TextStyle(
                            fontSize: 10,
                            color: textGrey,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: _pilihTanggal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: blue,
                                  size: 16,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _formatTanggal(_tglMulai),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textDark,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Ubah',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                    // Perkiraan check-out
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERKIRAAN CHECK-OUT',
                          style: TextStyle(
                            fontSize: 10,
                            color: textGrey,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_outlined,
                                color: textGrey,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _formatTanggal(tglSelesai),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                'Otomatis',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // === RINCIAN HARGA ===
              _sectionCard(
                title: 'Rincian Harga',
                child: Column(
                  children: [
                    _hargaRow(
                      'Harga Sewa (${widget.durasi} $satuanDurasi)',
                      'Rp ${_formatHarga(widget.totalHarga)}',
                    ),
                    const SizedBox(height: 8),
                    _hargaRow(
                      'Biaya Layanan',
                      'Rp ${_formatHarga(biayaLayanan)}',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        Text(
                          'Rp ${_formatHarga(total)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // === KEBIJAKAN PROPERTI ===
              _sectionCard(
                title: 'Kebijakan Properti',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dengan melanjutkan pembayaran, Anda menyetujui aturan yang telah ditetapkan oleh pemilik. Pelanggaran terhadap aturan dapat dikenakan sanksi sesuai ketentuan pemilik properti.',
                      style: TextStyle(
                        fontSize: 13,
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                    if (widget.peraturan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.rule_rounded,
                              color: Color(0xFFD97706),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.peraturan,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF92400E),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _setuju = !_setuju),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _setuju ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _setuju ? blue : const Color(0xFFE2E8F0),
                            width: _setuju ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _setuju ? blue : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _setuju ? blue : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                              ),
                              child: _setuju
                                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Saya menyetujui Aturan Properti dan Ketentuan Layanan APPKONKOS.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Obx(() {
                final bookingC = Get.find<BookingController>();
                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _setuju
                          ? AppColor.primary
                          : Colors.grey.shade300,
                      elevation: _setuju ? 4 : 0,
                      shadowColor: AppColor.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    onPressed: (_setuju && !bookingC.isLoading.value)
                        ? () async {
                            final tglStr =
                                '${_tglMulai.year}-${_tglMulai.month.toString().padLeft(2, '0')}-${_tglMulai.day.toString().padLeft(2, '0')}';
                            await bookingC.submitBookingFinal(
                              tglMulai: tglStr,
                            );
                          }
                        : null,
                    child: bookingC.isLoading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: _setuju ? Colors.white : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Konfirmasi & Bayar',
                                style: TextStyle(
                                  color: _setuju ? Colors.white : Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.security_rounded, color: textGrey, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Pembayaran diproses dengan aman oleh Midtrans',
                    style: TextStyle(fontSize: 11, color: textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: textGrey,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hargaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: textGrey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ],
    );
  }
}