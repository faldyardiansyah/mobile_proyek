class Property {
  final int id;
  final String name;
  final String price;
  final String priceMax;
  final String location;
  final double rating;
  final String type;
  final String foto;
  final String period;
  final double? lat;
  final double? lng;
  final String gender; 

  Property({
    required this.id,
    required this.name,
    required this.price,
    required this.priceMax,
    required this.location,
    required this.rating,
    required this.type,
    required this.foto,
    required this.period,
    this.lat,
    this.lng,
    this.gender = '', 
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? 0,
      name: json['nama'] ?? '',
      price: json['harga'].toString(),
      priceMax: json['harga_max']?.toString() ?? '0',
      location: json['alamat'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      type: json['tipe'] ?? '',
      foto: json['foto'] ?? '',
      period: json['period'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      gender: json['gender'] ?? '',
    );
  }
}