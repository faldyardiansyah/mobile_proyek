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
  });

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