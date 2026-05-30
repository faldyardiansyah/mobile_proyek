enum BookingStatus { menunggu, dibayar, refund, dibatalkan }

class ModelRiwayat {
  final String id;
  final String title;
  final String price;
  final String location;
  final BookingStatus status;
  final String imageAsset;
  final String? rawId;
  final DateTime? bookingTime;
  final String? redirectUrl;
  final int? totalHarga;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? refundStatus;
  final String? alasanRefund;
  final int? nominalRefund;

  ModelRiwayat({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.status,
    required this.imageAsset,
    this.rawId,
    this.bookingTime,
    this.redirectUrl,
    this.totalHarga,
    this.checkIn,
    this.checkOut,
    this.refundStatus,
    this.alasanRefund,
    this.nominalRefund,
  });

  // ← TAMBAH INI
  factory ModelRiwayat.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'menunggu';
    final status = BookingStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => BookingStatus.menunggu,
    );
    return ModelRiwayat(
      id: json['id'] as String,
      title: json['title'] as String,
      price: json['price'] as String,
      location: json['location'] as String,
      status: status,
      imageAsset: json['imageAsset'] as String? ?? '',
      rawId: json['rawId'] as String?,
      bookingTime: json['bookingTime'] != null
          ? DateTime.tryParse(json['bookingTime'])
          : null,
      redirectUrl: json['redirectUrl'] as String?,
      totalHarga: json['totalHarga'] as int?,
      checkIn: json['check_in'] != null
          ? DateTime.tryParse(json['check_in'])
          : null,

      checkOut: json['check_out'] != null
          ? DateTime.tryParse(json['check_out'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'location': location,
    'status': status.name,
    'imageAsset': imageAsset,
    'rawId': rawId,
    'bookingTime': bookingTime?.toIso8601String(),
    'redirectUrl': redirectUrl,
    'totalHarga': totalHarga,
    'check_in': checkIn?.toIso8601String(),
    'check_out': checkOut?.toIso8601String(),
    'refund_status': refundStatus,
    'alasan_refund': alasanRefund,
    'nominal_refund': nominalRefund,
  };

  Duration get sisaWaktu {
    if (bookingTime == null) return Duration.zero;
    final deadline = bookingTime!.add(const Duration(hours: 24));
    final sisa = deadline.difference(DateTime.now());
    return sisa.isNegative ? Duration.zero : sisa;
  }

  String get counttime {
    final sisa = sisaWaktu;
    if (sisa == Duration.zero) return '00:00:00';
    final h = sisa.inHours.toString().padLeft(2, '0');
    final m = (sisa.inMinutes % 60).toString().padLeft(2, '0');
    final s = (sisa.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String? get canceldate {
    if (bookingTime == null) return null;
    final deadline = bookingTime!.add(const Duration(hours: 24));
    return 'Bayar sebelum ${deadline.day}/${deadline.month} '
        '${deadline.hour.toString().padLeft(2, '0')}:'
        '${deadline.minute.toString().padLeft(2, '0')}';
  }
}
