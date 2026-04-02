enum BookingStatus {
  menunggu,
  dibayar,
  refund,
}

class ModelRiwayat {
  final String id;
  final String title;
  final String price;
  final String location;
  final BookingStatus status;
  final String? counttime;
  final String? canceldate;
  final String imageAsset;
  ModelRiwayat({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.status,
    this.counttime,
    this.canceldate,
    required this.imageAsset,
  });
}