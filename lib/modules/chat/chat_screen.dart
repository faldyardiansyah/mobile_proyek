import 'dart:convert';
import 'dart:math';
import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../home/controllers/home_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final HomeController homeController = Get.find();

  final ChatUser _currentUser = ChatUser(id: '1', firstName: 'User');
  final ChatUser _botUser = ChatUser(
    id: '2',
    firstName: 'Asisten Kos & Kontrakan',
    profileImage: "https://cdn-icons-png.flaticon.com/512/4712/4712035.png",
  );

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  final String modelName = 'gemini-2.5-flash';

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        user: _botUser,
        createdAt: DateTime.now(),
        text:
            "Halo! Saya Asisten Appkonkos. Saya bisa bantu kamu cari kos atau kontrakan di mana saja. Misalnya coba tanya: \"Kosan dekat RSUD Indramayu\" atau \"Kontrakan murah dekat alun-alun\" 😊",
      ),
    );
  }

  // ─── Haversine Distance ───────────────────────────────────────────────────
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  // ─── Step 1: Ekstrak nama lokasi dari pesan user ──────────────────────────
  Future<String?> _extractLocation(String userMessage) async {
    final body = {
      "contents": [
        {
          "parts": [
            {
              "text": """
                Dari kalimat berikut, ekstrak nama lokasi/tempat spesifik yang disebutkan user.
                Kalimat: "$userMessage"

                Aturan:
                - Jawab HANYA nama lokasinya saja. Contoh: "RSUD Indramayu", "Polindra", "Alun-alun Indramayu".
                - Jika lokasinya tidak spesifik atau tidak ada, jawab persis: NONE
                - Jangan tambahkan penjelasan apapun.
                """
            }
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result =
            data['candidates'][0]['content']['parts'][0]['text']?.trim() ?? '';
        return result == 'NONE' || result.isEmpty ? null : result;
      }
    } catch (e) {
      debugPrint("Extract location error: $e");
    }
    return null;
  }

  // ─── Step 2: Geocoding nama lokasi → lat/lng (Nominatim, gratis) ──────────
  Future<Map<String, double>?> _geocode(String locationName) async {
    final encoded =
        Uri.encodeComponent("$locationName, Indramayu, Jawa Barat, Indonesia");
    final url =
        "https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=1";

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'AppKonkos/1.0 (appkonkos@gmail.com)'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lng': double.parse(data[0]['lon']),
          };
        }
      }
    } catch (e) {
      debugPrint("Geocode error: $e");
    }
    return null;
  }

  // ─── Build default list tanpa filter jarak ────────────────────────────────
  String _defaultKosList() {
    return homeController.allProperties
        .map((p) =>
            '${p.name} (Tipe: ${p.type}, Lokasi: ${p.location}, Harga: Rp${p.price})')
        .join('\n');
  }

  // ─── Step 3: Filter + hitung jarak, ambil top N terdekat ─────────────────
  List<Map<String, dynamic>> _getSortedByDistance(
      double targetLat, double targetLng) {
    return homeController.allProperties.map((p) {
      double? lat = double.tryParse(p.lat.toString());
      double? lng = double.tryParse(p.lng.toString());
      double jarak = (lat != null && lng != null && lat != 0 && lng != 0)
          ? _calculateDistance(lat, lng, targetLat, targetLng)
          : 999.0;
      return {'property': p, 'jarak': jarak};
    }).toList()
      ..sort(
          (a, b) => (a['jarak'] as double).compareTo(b['jarak'] as double));
  }

  // ─── Main: Kirim ke Gemini ────────────────────────────────────────────────
  Future<String> askGemini(String userMessage) async {
    String kosList;
    String lokasiContext = "";

    // Ekstrak lokasi dari pesan user
    final locationName = await _extractLocation(userMessage);

    if (locationName != null) {
      // Geocoding lokasi yang disebut user
      final coords = await _geocode(locationName);

      if (coords != null) {
        // Hitung jarak, ambil top 10 terdekat
        final sorted =
            _getSortedByDistance(coords['lat']!, coords['lng']!);

        kosList = sorted.take(10).map((e) {
          final p = e['property'];
          final jarak = (e['jarak'] as double);
          final jarakStr =
              jarak < 999 ? "${jarak.toStringAsFixed(1)} km" : "jarak tidak diketahui";
          return '${p.name} (Tipe: ${p.type}, Lokasi: ${p.location}, Jarak ke $locationName: $jarakStr, Harga: Rp${p.price})';
        }).join('\n');

        lokasiContext =
            "User mencari properti dekat $locationName. Urutkan rekomendasi dari yang paling dekat.";
      } else {
        // Geocoding gagal, pakai semua data tapi tetap sebutkan lokasi
        kosList = _defaultKosList();
        lokasiContext =
            "User mencari properti dekat $locationName. Data koordinat tidak tersedia, gunakan nama lokasi untuk memperkirakan.";
      }
    } else {
      // Tidak ada lokasi spesifik, kirim semua data
      kosList = _defaultKosList();
      lokasiContext = "User tidak menyebut lokasi spesifik, bantu berdasarkan preferensi lain.";
    }

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text": """
              Kamu adalah asisten ramah Appkonkos, aplikasi pencari kos dan kontrakan di Indramayu.

              Konteks: $lokasiContext

              Data properti yang tersedia:
              $kosList

              Pertanyaan user: $userMessage

              Tugasmu:
              1. Rekomendasikan 5 properti terbaik yang paling relevan dengan pertanyaan user.
              2. Jika ada data jarak, urutkan dari yang TERDEKAT.
              3. Untuk setiap properti yang kamu rekomendasikan, wajib tambahkan kode [MATCH: Nama Properti] tepat setelah menyebut nama properti tersebut.
              4. Format setiap rekomendasi dengan jelas, misalnya:
                "1. Kosan Melati [MATCH: Kosan Melati] - hanya 0.3 km dari RSUD, harga Rp500.000/bulan, cocok untuk kamu!"
              5. Jawab dengan ramah dan informatif menggunakan bahasa Indonesia.
              6. Jangan gunakan markdown seperti ** atau ##.
              7. Jika data properti tidak ada yang cocok, katakan dengan jujur.
              """
            }
          ]
        }
      ]
    };

    http.Response response;
    int retry = 0;
    while (true) {
      response = await http.post(
        Uri.parse(
            'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 503 && retry < 2) {
        retry++;
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }
      break;
    }

    if (response.statusCode != 200) {
      throw Exception('Server sibuk, coba lagi ya 😅');
    }

    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] ??
        'Maaf, saya belum bisa menjawab.';
  }

  // ─── Handle Send ──────────────────────────────────────────────────────────
  void _handleSendMessage(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _isTyping = true;
    });

    try {
      final answer = await askGemini(m.text);

      setState(() {
        _isTyping = false;
        _messages.insert(
          0,
          ChatMessage(
              user: _botUser, createdAt: DateTime.now(), text: answer),
        );
      });
    } catch (e) {
      setState(() => _isTyping = false);
      Get.snackbar(
        "Waduh!",
        "Asisten sedang istirahat. Coba lagi dalam 1 menit ya!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      debugPrint("Detail Error: $e");
    }
  }

  // ─── Build UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asisten Appkonkos AI")),
      body: DashChat(
        currentUser: _currentUser,
        onSend: _handleSendMessage,
        messages: _messages,
        typingUsers: _isTyping ? [_botUser] : [],
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.blueAccent,
          currentUserTextColor: Colors.white,
          containerColor: Colors.grey[200]!,
          textColor: Colors.black87,
          messageTextBuilder: (message, previousMessage, nextMessage) {
            return _buildMessageWidget(message);
          },
        ),
      ),
    );
  }

  // ─── Parse semua [MATCH:] dalam satu pesan ────────────────────────────────
  Widget _buildMessageWidget(ChatMessage message) {
    if (message.user.id != _botUser.id) {
      return Text(message.text);
    }

    // Cek apakah ada MATCH tag
    final RegExp regExp = RegExp(r'\[MATCH:\s*(.*?)\]');
    final matches = regExp.allMatches(message.text);

    if (matches.isEmpty) {
      return Text(message.text);
    }

    try {
      // Pisahkan teks berdasarkan [MATCH:...] tag
      final List<Widget> widgets = [];
      String remainingText = message.text;

      // Ambil teks sebelum match pertama sebagai intro
      final firstMatchStart = matches.first.start;
      if (firstMatchStart > 0) {
        // Cari baris sebelum match pertama
        final introText = remainingText.substring(0, firstMatchStart).trim();
        // Hanya tampilkan baris sebelum nomor pertama
        final introLines = introText.split('\n');
        final introOnly = introLines
            .where((l) => !RegExp(r'^\d+\.').hasMatch(l.trim()))
            .join('\n')
            .trim();
        if (introOnly.isNotEmpty) {
          widgets.add(Text(introOnly));
          widgets.add(const SizedBox(height: 8));
        }
      }

      // Untuk setiap match, buat card properti
      for (final match in matches) {
        final propertyName = match.group(1)?.trim() ?? '';

        // Cari teks deskripsi baris ini (antara nomor dan [MATCH])
        final matchStart = match.start;
        // Cari awal baris ini
        final lineStart = remainingText.lastIndexOf('\n', matchStart - 1) + 1;
        String lineDesc = remainingText.substring(lineStart, matchStart).trim();
        // Hapus prefix nomor "1. " dll
        lineDesc = lineDesc.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        // Hapus nama properti dari deskripsi (karena sudah di card)
        lineDesc = lineDesc
            .replaceFirst(RegExp(RegExp.escape(propertyName), caseSensitive: false), '')
            .replaceFirst(RegExp(r'^\s*[-–]\s*'), '')
            .trim();

        // Cari teks setelah [MATCH:...] sampai sebelum [MATCH:...] berikutnya
        final afterMatch = remainingText.substring(match.end);
        final nextMatchIdx =
            RegExp(r'\[MATCH:').firstMatch(afterMatch)?.start ?? afterMatch.length;
        final afterText = afterMatch.substring(0, nextMatchIdx).trim();

        // Gabungkan deskripsi
        final fullDesc = [lineDesc, afterText].where((s) => s.isNotEmpty).join(' ');

        // Cari properti di data
        final property = homeController.allProperties.firstWhereOrNull(
          (p) => p.name.toLowerCase().contains(propertyName.toLowerCase()),
        );

        if (property != null) {
          widgets.add(_buildPropertyCard(property, fullDesc));
          widgets.add(const SizedBox(height: 12));
        }
      }

      // Teks penutup setelah semua match
      final lastMatchEnd = matches.last.end;
      if (lastMatchEnd < message.text.length) {
        final closingText = message.text.substring(lastMatchEnd).trim();
        // Hapus deskripsi baris terakhir yang sudah ditampilkan di card
        final lines = closingText.split('\n');
        final closingOnly = lines
            .where((l) => !RegExp(r'^\d+\.').hasMatch(l.trim()) && l.trim().isNotEmpty)
            .join('\n')
            .trim();
        if (closingOnly.isNotEmpty) {
          widgets.add(const SizedBox(height: 4));
          widgets.add(Text(closingOnly));
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    } catch (e) {
      // Fallback: tampilkan teks biasa tanpa tag
      return Text(message.text.replaceAll(RegExp(r'\[MATCH:.*?\]'), '').trim());
    }
  }

  // ─── Card Properti ────────────────────────────────────────────────────────
  Widget _buildPropertyCard(dynamic property, String description) {
    return GestureDetector(
      onTap: () => Get.toNamed('/detail', arguments: property),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar & Badge Tipe
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: property.foto != null && property.foto.isNotEmpty
                      ? Image.network(
                          property.foto,
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      property.type ?? '-',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // Info Properti
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 3),
                      Text(
                        property.rating.toString(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on,
                          size: 13, color: Colors.grey),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                          fontSize: 11, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${property.price}",
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                         child: InkWell(
                          onTap: () => Get.to(() => const DetailScreen(), arguments: property),
                          borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Lihat Detail →",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 130,
      width: double.infinity,
      color: Colors.blue.shade50,
      child: const Icon(Icons.home_work_rounded, size: 50, color: Colors.blue),
    );
  }
}