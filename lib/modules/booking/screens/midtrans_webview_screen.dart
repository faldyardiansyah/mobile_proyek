import 'dart:io';
import 'package:appkonkos_mobile/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:appkonkos_mobile/modules/Riwayat/controllers/riwayat_controller.dart';
import 'package:appkonkos_mobile/modules/Riwayat/models/model_riwayat.dart';
import 'package:lottie/lottie.dart';

class MidtransWebView extends StatefulWidget {
  final String url;
  final int totalHarga;
  final String bookingId;
  final String kamarNama;
  final String tipeKamarNama;
  final int durasi;
  final String tipeProperty;
  final String noWaPemilik;
  final String tglMulai;

  const MidtransWebView({
    super.key,
    required this.url,
    required this.totalHarga,
    this.bookingId = '',
    this.kamarNama = '',
    this.tipeKamarNama = '',
    this.durasi = 1,
    this.tipeProperty = '',
    this.noWaPemilik = '',
    this.tglMulai = '',
  });

  @override
  State<MidtransWebView> createState() => _MidtransWebViewState();
}

class _MidtransWebViewState extends State<MidtransWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  static const Color blue = Color(0xFF007BC2);
  static const Color textDark = Color(0xFF0B1020);
  static const Color textGrey = Color(0xFF7B8794);

  String kamarNama = '';
  String tipeKamarNama = '';
  int totalHarga = 0;
  int durasi = 1;
  String tipeProperty = '';
  String bookingId = '';
  String noWaPemilik = '';
  String tglMulai = '';

  @override
  void initState() {
    super.initState();
    kamarNama = widget.kamarNama;
    tipeKamarNama = widget.tipeKamarNama;
    totalHarga = widget.totalHarga;
    durasi = widget.durasi;
    tipeProperty = widget.tipeProperty;
    bookingId = widget.bookingId;
    noWaPemilik = widget.noWaPemilik;
    tglMulai = widget.tglMulai;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.contains('transaction_status=settlement') ||
                url.contains('transaction_status=capture')) {
              _showSuccessSheet();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=pending')) {
              _showPendingSheet();
              return NavigationDecision.prevent;
            }

            if (url.contains('transaction_status=deny') ||
                url.contains('transaction_status=cancel') ||
                url.contains('transaction_status=expire')) {
              Get.back();
              Get.snackbar(
                '❌ Pembayaran Gagal',
                'Pembayaran dibatalkan atau kadaluarsa.',
                backgroundColor: const Color(0xFFFFEBEE),
                colorText: const Color(0xFFC62828),
                snackPosition: SnackPosition.TOP,
              );
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  String _formatHarga(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _formatTanggal(DateTime dt) {
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  Future<File> _generatePdf() async {
    final pdf = pw.Document();
    final satuanDurasi = tipeProperty == 'Kontrakan' ? 'Tahun' : 'Bulan';
    final now = DateTime.now();
    final tglCheckin = tglMulai.isNotEmpty
        ? DateTime.tryParse(tglMulai) ?? now
        : now;
    final tglCheckout = tipeProperty == 'Kontrakan'
        ? DateTime(tglCheckin.year + durasi, tglCheckin.month, tglCheckin.day)
        : DateTime(tglCheckin.year, tglCheckin.month + durasi, tglCheckin.day);
    final noStruk = bookingId.isNotEmpty
        ? 'BK-${bookingId.substring(0, 8).toUpperCase()}'
        : 'BK-${now.millisecondsSinceEpoch.toString().substring(6)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'APPKONKOS',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text(
                        'Payment Receipt',
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'NO: $noStruk',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        _formatTanggal(tglCheckin),
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 20),

              // Detail properti
              pw.Text(
                'DETAIL PROPERTI',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                tipeKamarNama.isNotEmpty ? tipeKamarNama : 'Properti',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (kamarNama.isNotEmpty)
                pw.Text(
                  'Kamar $kamarNama',
                  style: const pw.TextStyle(
                    fontSize: 13,
                    color: PdfColors.grey700,
                  ),
                ),

              pw.SizedBox(height: 20),

              // Periode booking
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'CHECK-IN',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _formatTanggal(tglCheckin),
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Text(
                      '→',
                      style: const pw.TextStyle(
                        fontSize: 20,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'CHECK-OUT',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          _formatTanggal(tglCheckout),
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              // Rincian biaya
              pw.Text(
                'RINCIAN BIAYA',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600,
                  letterSpacing: 1,
                ),
              ),
              pw.SizedBox(height: 12),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Harga Sewa ($durasi $satuanDurasi)',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Rp ${_formatHarga(totalHarga - 10000)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Biaya Layanan',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Rp ${_formatHarga(10000)}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Pembayaran',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rp ${_formatHarga(totalHarga)}',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // Badge PAID
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(
                      color: PdfColors.green700,
                      width: 1.5,
                    ),
                  ),
                  child: pw.Text(
                    ' LUNAS / PAID',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green800,
                    ),
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  'Dokumen ini dibuat otomatis oleh sistem APPKONKOS.\nTidak memerlukan tanda tangan.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/struk_$noStruk.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _kirimWaKePemilik() async {
    var noWa = noWaPemilik;
    if (noWa.isEmpty) {
      Get.snackbar('Info', 'Nomor WA pemilik tidak tersedia');
      return;
    }
    if (noWa.startsWith('0')) noWa = '62${noWa.substring(1)}';

    final satuanDurasi = tipeProperty == 'Kontrakan' ? 'Tahun' : 'Bulan';
    final noStruk = bookingId.isNotEmpty
        ? 'BK-${bookingId.substring(0, 8).toUpperCase()}'
        : '-';

    final pesan =
        '''✅ *Konfirmasi Pembayaran Booking*

🏠 *$tipeKamarNama*
🚪 Kamar: $kamarNama
📅 Durasi: $durasi $satuanDurasi
💰 Total: Rp ${_formatHarga(totalHarga)}
🔖 No. Booking: $noStruk

Pembayaran telah berhasil dilakukan melalui AppKonkos.
Mohon konfirmasi ketersediaan kamar.

Terima kasih! 🙏''';

    final uri = Uri.parse(
      'https://api.whatsapp.com/send?phone=$noWa&text=${Uri.encodeComponent(pesan)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'WhatsApp tidak tersedia');
    }
  }

  void _showSuccessSheet() {
    try {
      final riwayatController = Get.find<RiwayatController>();
      final formattedId =
          '#BK-${bookingId.length >= 8 ? bookingId.substring(0, 8).toUpperCase() : bookingId.toUpperCase()}';
      riwayatController.updateStatus(formattedId, BookingStatus.dibayar);
      riwayatController.fetchRiwayat();
    } catch (_) {}

    NotificationService().show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: '✅ Pembayaran Berhasil!',
    body: 'Booking $tipeKamarNama telah dikonfirmasi. Terima kasih!',
    type: NotifType.pembayaranBerhasil,
    route: '/riwayat',
  );
  
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                Lottie.asset(
                  'assets/lottie/Done.json',
                  width: 170,
                  height: 170,
                  repeat: true,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pembayaran Berhasil!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kamarNama.isNotEmpty
                      ? 'Booking kamar $kamarNama berhasil dikonfirmasi.'
                      : 'Booking berhasil dikonfirmasi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: textGrey),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Simpan Struk PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final file = await _generatePdf();
                        await Printing.layoutPdf(
                          onLayout: (_) async => file.readAsBytesSync(),
                        );
                      } catch (e) {
                        Get.snackbar('Error', 'Gagal membuat PDF: $e');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, color: blue),
                    label: const Text(
                      'Bagikan Struk',
                      style: TextStyle(
                        color: blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final file = await _generatePdf();
                        await Share.shareXFiles(
                          [XFile(file.path)],
                          text: 'Struk Booking AppKonkos',
                          subject: 'Struk Pembayaran AppKonkos',
                        );
                      } catch (e) {
                        Get.snackbar('Error', 'Gagal berbagi: $e');
                      }
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Image.asset(
                      'assets/image/wa.png',
                      width: 20,
                      height: 20,
                    ),
                    label: const Text(
                      'Kirim ke Pemilik via WA',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: _kirimWaKePemilik,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Get.until((route) => route.isFirst),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: textGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
    );
  }

  void _showPendingSheet() {
    try {
      Get.find<RiwayatController>().tambahRiwayat(
        id: '#BK-$bookingId',
        title: tipeKamarNama.isNotEmpty ? tipeKamarNama : 'Properti',
        location: '',
        price: 'Rp ${_formatHarga(totalHarga)}',
        status: BookingStatus.menunggu,
        imageAsset: '',
        bookingTime: DateTime.now(),
      );
    } catch (_) {}
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: Colors.orange,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Menunggu Pembayaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selesaikan pembayaran sebelum batas waktu yang ditentukan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: textGrey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Get.until((route) => route.isFirst),
                  child: const Text(
                    'Oke, Mengerti',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pembayaran',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: textDark),
          onPressed: () {
            Get.dialog(
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Tinggalkan Pembayaran?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: const Text(
                  'Pembayaran belum selesai. Kamu masih bisa bayar nanti dari Riwayat Booking.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(
                      'Lanjutkan Bayar',
                      style: TextStyle(color: Color(0xFF1565C0)),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Get.back();
                      Get.back();
                    },
                    child: const Text(
                      'Keluar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: blue),
                      SizedBox(height: 16),
                      Text(
                        'Memuat halaman pembayaran...',
                        style: TextStyle(color: textGrey),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
