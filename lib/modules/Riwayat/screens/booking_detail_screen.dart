import 'dart:io';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/riwayat_controller.dart';
import '../models/model_riwayat.dart';

class BookingDetailScreen extends StatelessWidget {
  final ModelRiwayat item;
  final RiwayatController controller;

  const BookingDetailScreen({
    super.key,
    required this.item,
    required this.controller,
  });

  static const Color _primary = Color(0xFF1565C0);

  String _formatTanggal(DateTime? dt) {
    if (dt == null) return '-';
    final bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}';
  }

  String _formatHargaInt(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  Future<File> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final noStruk = item.rawId != null && item.rawId!.length >= 8
        ? 'BK-${item.rawId!.substring(0, 8).toUpperCase()}'
        : 'BK-${now.millisecondsSinceEpoch.toString().substring(6)}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('APPKONKOS', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.Text('Payment Receipt', style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('NO: $noStruk', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text(_formatTanggal(item.bookingTime), style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 16),
              pw.Text('DETAIL PROPERTI', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600, letterSpacing: 1)),
              pw.SizedBox(height: 8),
              pw.Text(item.title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(item.location, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              if (item.tipeKamar.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Tipe Kamar: ${item.tipeKamar}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
              if (item.kamarNama.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Nomor Kamar: ${item.kamarNama}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
              if (item.gender.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text('Tipe Penghuni: ${_genderLabel(item.gender)}', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              ],
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(color: PdfColors.blue50, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [
                      pw.Text('CHECK-IN', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text(_formatTanggal(item.checkIn), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ]),
                    pw.Text('→', style: const pw.TextStyle(fontSize: 20, color: PdfColors.grey)),
                    pw.Column(children: [
                      pw.Text('CHECK-OUT', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                      pw.SizedBox(height: 4),
                      pw.Text(_formatTanggal(item.checkOut), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    ]),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Text('RINCIAN BIAYA', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600, letterSpacing: 1)),
              pw.SizedBox(height: 12),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
               pw.Text(
                  item.durasi > 0
                      ? 'Harga Sewa (${item.durasi} ${item.tipeProperty == 'Kontrakan' ? 'Tahun' : 'Bulan'})'
                      : 'Harga Sewa',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
                pw.Text('Rp ${_formatHargaInt((item.totalHarga ?? 0) - 10000)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ]),
              pw.SizedBox(height: 6),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Biaya Layanan', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.Text('Rp 10.000', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ]),
              pw.SizedBox(height: 10),
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 10),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Total Pembayaran', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                pw.Text(item.price, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
              ]),
              pw.SizedBox(height: 30),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(20),
                    border: pw.Border.all(color: PdfColors.green700, width: 1.5),
                  ),
                  child: pw.Text('LUNAS / PAID', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Dokumen ini dibuat otomatis oleh sistem APPKONKOS.\nTidak memerlukan tanda tangan.',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
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

  Future<void> _hubungiPemilik() async {
    var noWa = item.noWaPemilik;
    if (noWa.isEmpty) {
      Get.snackbar('Info', 'Nomor WA pemilik tidak tersedia');
      return;
    }
    if (noWa.startsWith('0')) noWa = '62${noWa.substring(1)}';
    final noStruk = item.rawId != null && item.rawId!.length >= 8
        ? 'BK-${item.rawId!.substring(0, 8).toUpperCase()}'
        : item.id;
    final pesan = '''✅ *Konfirmasi Pembayaran Booking*

🏠 *${item.title}*
📍 ${item.location}
📅 Check-in: ${_formatTanggal(item.checkIn)}
📅 Check-out: ${_formatTanggal(item.checkOut)}
💰 Total: ${item.price}
🔖 No. Booking: $noStruk

Pembayaran telah berhasil dilakukan melalui AppKonkos.
Terima kasih! 🙏''';

    final uri = Uri.parse('https://api.whatsapp.com/send?phone=$noWa&text=${Uri.encodeComponent(pesan)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'WhatsApp tidak tersedia');
    }
  }

  void _showRefundSheet(BuildContext context) {
    final alasanController = TextEditingController();
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Ajukan Refund', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('Nominal refund: ${item.price}', style: const TextStyle(fontSize: 13, color: AppColor.grey)),
                const SizedBox(height: 16),
                TextField(
                  controller: alasanController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Tuliskan alasan pengajuan refund (min. 10 karakter)...',
                    hintStyle: const TextStyle(color: AppColor.grey, fontSize: 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (alasanController.text.trim().length < 10) {
                        Get.snackbar('Perhatian', 'Alasan refund minimal 10 karakter',
                            backgroundColor: Colors.orange.shade50, colorText: Colors.orange.shade800);
                        return;
                      }
                      Get.back();
                      await controller.submitRefund(item, alasanController.text.trim());
                    },
                    child: const Text('Kirim Pengajuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header foto
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: _primary,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageAsset.isNotEmpty
                      ? Image.network(item.imageAsset, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.home, size: 80, color: Colors.grey)))
                      : Container(color: Colors.grey[300], child: const Icon(Icons.home, size: 80, color: Colors.grey)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + ID
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(),
                      Text(item.id, style: const TextStyle(fontSize: 11, color: AppColor.grey, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nama
                  Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),

                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: AppColor.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.location.isNotEmpty ? item.location : '-', style: const TextStyle(fontSize: 13, color: AppColor.grey))),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Info Booking
                  _buildSectionTitle('Informasi Booking'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
  _buildInfoRow(Icons.calendar_today_outlined, 'Tanggal Booking', _formatTanggal(item.bookingTime)),

  // Gender badge — hanya kosan
  if (item.gender.isNotEmpty)
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.people_outline, size: 18, color: _primary),
          const SizedBox(width: 10),
          const Text('Tipe Penghuni', style: TextStyle(fontSize: 13, color: AppColor.grey)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _genderColor(item.gender).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _genderLabel(item.gender),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _genderColor(item.gender)),
            ),
          ),
        ],
      ),
    ),

  if (item.tipeKamar.isNotEmpty)
    _buildInfoRow(Icons.category_outlined, 'Tipe Kamar', item.tipeKamar),
  if (item.kamarNama.isNotEmpty)
    _buildInfoRow(Icons.meeting_room_outlined, 'Nomor Kamar', item.kamarNama),

  _buildInfoRow(Icons.login_rounded, 'Check In', _formatTanggal(item.checkIn)),
  _buildInfoRow(Icons.logout_rounded, 'Check Out', _formatTanggal(item.checkOut)),
  if (item.durasi > 0)
    _buildInfoRow(Icons.timelapse_rounded, 'Durasi',
        '${item.durasi} ${item.tipeProperty == 'Kontrakan' ? 'Tahun' : 'Bulan'}'),
]),

                  const SizedBox(height: 16),

                  // Rincian biaya
                  _buildSectionTitle('Rincian Biaya'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(Icons.home_outlined, 'Biaya Sewa',
                        'Rp ${_formatHargaInt((item.totalHarga ?? 0) - 10000)}'),
                    _buildInfoRow(Icons.receipt_outlined, 'Biaya Layanan', 'Rp 10.000'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1A2E))),
                        Text(item.price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primary)),
                      ],
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // Konten sesuai status
                  _buildStatusContent(context),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context) {
    switch (item.status) {
      case BookingStatus.menunggu:
        return _buildMenungguContent(context);
      case BookingStatus.dibayar:
        return _buildDibayarContent(context);
      case BookingStatus.refund:
        return _buildRefundContent(context);
      case BookingStatus.dibatalkan:
        return _buildDibatalkanContent();
    }
  }

  Widget _buildMenungguContent(BuildContext context) {
    return Column(
      children: [
        // Countdown
        if (item.canceldate != null)
          Obx(() {
            controller.tick;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Batas Waktu Pembayaran',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 13)),
                        Text(item.canceldate ?? '', style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
                  Text(
                    item.counttime,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange.shade800, fontFamily: 'monospace'),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () { Get.back(); controller.batalkanBooking(item); },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Batalkan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () { Get.back(); controller.bayarSekarang(item); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDibayarContent(BuildContext context) {
    return Column(
      children: [
        // Info WA pemilik
        if (item.noWaPemilik.isNotEmpty)
          _buildInfoCard([
            _buildInfoRow(Icons.phone_outlined, 'WA Pemilik', item.noWaPemilik),
          ]),
        if (item.noWaPemilik.isNotEmpty) const SizedBox(height: 16),

        // Tombol-tombol
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: const Text('Download Struk PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                final file = await _generatePdf();
                await Printing.layoutPdf(onLayout: (_) async => file.readAsBytesSync());
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
              side: const BorderSide(color: _primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.share_rounded, color: _primary),
            label: const Text('Bagikan Struk', style: TextStyle(color: _primary, fontWeight: FontWeight.bold)),
            onPressed: () async {
              try {
                final file = await _generatePdf();
                await Share.shareXFiles([XFile(file.path)], text: 'Struk Booking AppKonkos');
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: Image.asset('assets/image/wa.png', width: 18, height: 18),
            label: const Text('Hubungi Pemilik via WA', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            onPressed: _hubungiPemilik,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.orange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.replay_rounded, color: Colors.orange),
            label: const Text('Ajukan Refund', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            onPressed: () => _showRefundSheet(context),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRefundContent(BuildContext context) {
    final refundStatus = item.refundStatus ?? 'pending';

    // Config per status refund
    final configs = {
      'pending': {
        'color': Colors.orange,
        'bgColor': Colors.orange.shade50,
        'borderColor': Colors.orange.shade200,
        'icon': Icons.access_time_rounded,
        'label': '🟡 Menunggu Persetujuan Admin',
        'desc': 'Pengajuan refund kamu sedang ditinjau oleh admin.',
      },
      'diproses': {
        'color': Colors.blue,
        'bgColor': Colors.blue.shade50,
        'borderColor': Colors.blue.shade200,
        'icon': Icons.sync_rounded,
        'label': '🟠 Dana Sedang Diproses',
        'desc': 'Refund telah disetujui. Dana sedang dalam proses transfer.',
      },
      'selesai': {
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
        'borderColor': Colors.green.shade200,
        'icon': Icons.check_circle_outline_rounded,
        'label': '🟢 Dana Sudah Ditransfer',
        'desc': 'Refund telah selesai. Dana sudah ditransfer ke akunmu.',
      },
      'ditolak': {
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'borderColor': Colors.red.shade200,
        'icon': Icons.cancel_outlined,
        'label': '🔴 Refund Ditolak',
        'desc': 'Maaf, pengajuan refund kamu tidak dapat diproses.',
      },
    };

    final config = configs[refundStatus] ?? configs['pending']!;
    final color = config['color'] as Color;
    final bgColor = config['bgColor'] as Color;
    final borderColor = config['borderColor'] as Color;
    final icon = config['icon'] as IconData;
    final label = config['label'] as String;
    final desc = config['desc'] as String;

    return Column(
      children: [
        // Info refund
        _buildSectionTitle('Informasi Refund'),
        const SizedBox(height: 12),
        _buildInfoCard([
          if (item.nominalRefund != null)
            _buildInfoRow(Icons.payments_outlined, 'Nominal Refund', 'Rp ${_formatHargaInt(item.nominalRefund!)}'),
          if (item.alasanRefund != null && item.alasanRefund!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.description_outlined, size: 18, color: _primary),
                  const SizedBox(width: 10),
                  const Text('Alasan', style: TextStyle(fontSize: 13, color: AppColor.grey)),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      item.alasanRefund!,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                ],
              ),
            ),
        ]),
        const SizedBox(height: 16),

        // Status badge refund
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
              const SizedBox(height: 4),
              Text(desc, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
            ],
          ),
        ),

        // Tombol lihat bukti transfer (hanya kalau selesai)
        if (refundStatus == 'selesai' && item.buktiTransfer != null) ...[
          const SizedBox(height: 16),
          _buildSectionTitle('Bukti Transfer'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _lihatBuktiTransfer(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.receipt_long_rounded, color: Colors.green.shade700),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bukti Transfer Refund', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1A2E))),
                        Text('Tap untuk melihat', style: TextStyle(fontSize: 12, color: AppColor.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColor.grey),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDibatalkanContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 48),
            const SizedBox(height: 12),
            Text('Booking Dibatalkan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Booking ini telah dibatalkan.', textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _lihatBuktiTransfer(BuildContext context) {
    if (item.buktiTransfer == null) return;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bukti Transfer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.buktiTransfer!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Gagal memuat gambar', style: TextStyle(color: AppColor.grey)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final configs = {
      BookingStatus.dibayar: {'label': 'DIBAYAR', 'bg': const Color(0xFFE3F2FD), 'text': const Color(0xFF1565C0)},
      BookingStatus.menunggu: {'label': 'MENUNGGU PEMBAYARAN', 'bg': const Color(0xFFFFF3E0), 'text': const Color(0xFFE65100)},
      BookingStatus.refund: {'label': 'REFUND', 'bg': const Color(0xFFF3E5F5), 'text': const Color(0xFF6A1B9A)},
      BookingStatus.dibatalkan: {'label': 'DIBATALKAN', 'bg': const Color(0xFFFFEBEE), 'text': const Color(0xFFf44336)},
    };
    final config = configs[item.status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: config['bg'] as Color, borderRadius: BorderRadius.circular(6)),
      child: Text(config['label'] as String,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: config['text'] as Color, letterSpacing: 0.5)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColor.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  String _genderLabel(String gender) {
  switch (gender.toLowerCase()) {
    case 'putra': return '👨 Putra';
    case 'putri': return '👩 Putri';
    case 'campur': return '👥 Campur';
    default: return gender;
  }
}

Color _genderColor(String gender) {
  switch (gender.toLowerCase()) {
    case 'putra': return Colors.blue;
    case 'putri': return Colors.pink;
    case 'campur': return Colors.purple;
    default: return Colors.grey;
  }
}
}