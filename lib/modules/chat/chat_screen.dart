import 'dart:convert';
import 'dart:math';
import 'package:appkonkos_mobile/modules/home/screens/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../home/controllers/home_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final HomeController homeController = Get.find();
  final _box = GetStorage();
  static const _storageKey = 'chat_messages';

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
    final existing = _box.read<String>(_storageKey);
    if (existing == null) {
      _messages.add(
        ChatMessage(
          user: _botUser,
          createdAt: DateTime.now(),
          text:
              "Halo! Saya Asisten Appkonkos. Saya bisa bantu kamu cari kos atau kontrakan di mana saja. Misalnya coba tanya: \"Kosan dekat alun-alun Yogyakarta\" atau \"Kontrakan murah dekat alun-alun Indramayu\" 😊",
        ),
      );
    } else {
      _loadMessages();
    }
  }

  // ─── Haversine Distance ───────────────────────────────────────────────────

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
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
              "text":
                  """
                Dari kalimat berikut, ekstrak nama lokasi/tempat spesifik yang disebutkan user.
                Kalimat: "$userMessage"

                Aturan:
                - Jawab HANYA nama lokasinya saja. Contoh: "Universitas Indonesia", "Polindra", "Alun-alun Indramayu".
                - Jika lokasinya tidak spesifik atau tidak ada, jawab persis: NONE
                - Jangan tambahkan penjelasan apapun.
                """,
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
        ),
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
    final encoded = Uri.encodeComponent("$locationName, Indonesia");

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
            'lat': double.tryParse(data[0]['lat'].toString()) ?? 0.0,
            'lng': double.tryParse(data[0]['lon'].toString()) ?? 0.0,
          };
        }
      }
    } catch (e) {
      debugPrint("Geocode error: $e");
    }

    return null;
  }

  // ─── Build default list tanpa filter jarak (dengan rating) ───────────────
  String _defaultKosList() {
    return homeController.allProperties
        .map(
          (p) =>
              '${p.name} (Tipe: ${p.type}, Lokasi: ${p.location}, Rating: ${p.rating ?? '-'}⭐, Harga: Rp${p.price})',
        )
        .join('\n');
  }

  // ─── Step 3: Filter + hitung jarak, sort jarak lalu rating ───────────────
  List<Map<String, dynamic>> _getSortedByDistance(
    double targetLat,
    double targetLng,
  ) {
    return homeController.allProperties.map((p) {
      print("PROPERTY: ${p.name}");
      print("LAT: ${p.lat}");
      print("LNG: ${p.lng}");
      double? lat = double.tryParse(p.lat.toString());
      double? lng = double.tryParse(p.lng.toString());
      double jarak = (lat != null && lng != null && lat != 0 && lng != 0)
          ? _calculateDistance(lat, lng, targetLat, targetLng)
          : 999.0;
      return {'property': p, 'jarak': jarak};
    }).toList()..sort((a, b) {
      final jarakA = (a['jarak'] ?? 999.0) as double;
      final jarakB = (b['jarak'] ?? 999.0) as double;

      int cmp = jarakA.compareTo(jarakB);
      if (cmp != 0) return cmp;

      final ratingA =
          double.tryParse(
            ((a['property'] as dynamic)?.rating ?? '').toString(),
          ) ??
          0;

      final ratingB =
          double.tryParse(
            ((b['property'] as dynamic)?.rating ?? '').toString(),
          ) ??
          0;

      return ratingB.compareTo(ratingA);
    });
  }

  // ─── Main: Kirim ke Gemini ────────────────────────────────────────────────
  Future<String> askGemini(String userMessage) async {
    String kosList;
    String lokasiContext = "";

    final locationName = await _extractLocation(userMessage);

    if (locationName != null) {
      final coords = await _geocode(locationName);

      if (coords != null) {
        final sorted = _getSortedByDistance(coords['lat']!, coords['lng']!);

        kosList = sorted
            .take(10)
            .map((e) {
              final p = e['property'];
              final jarak = e['jarak'] as double;

              return '''
              ${p.name}
              - Tipe: ${p.type}
              - Lokasi: ${p.location}
              - Jarak dari $locationName: ${jarak.toStringAsFixed(1)} km
              - Rating: ${p.rating ?? '-'}⭐
              - Harga: Rp${p.price}
              ''';
            })
            .join('\n');

        lokasiContext =
            "User mencari properti dekat $locationName. Urutkan rekomendasi dari yang paling dekat. Jika jarak mirip (selisih kurang dari 0.5 km), prioritaskan rating yang lebih tinggi.";
      } else {
        kosList = _defaultKosList();
        lokasiContext =
            "User mencari properti dekat $locationName. Data koordinat tidak tersedia, gunakan nama lokasi untuk memperkirakan. Pertimbangkan juga rating properti.";
      }
    } else {
      kosList = _defaultKosList();
      lokasiContext =
          "User tidak menyebut lokasi spesifik, bantu berdasarkan preferensi lain. Pertimbangkan rating properti sebagai salah satu faktor rekomendasi.";
    }

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  """
              Kamu adalah asisten ramah Appkonkos, aplikasi pencari kos dan kontrakan di seluruh indonesia.

              Konteks: $lokasiContext

              Data properti yang tersedia:
              $kosList

              Pertanyaan user: $userMessage

              Tugasmu:
              Tampilkan maksimal 5 properti paling relevan.
              Jika ada jarak, urutkan dari yang terdekat, lalu rating tertinggi.
              Setelah nama properti wajib tambahkan format [MATCH: Nama Properti].
              Jawaban singkat, ramah, tanpa markdown, dan langsung ke inti.
              Maksimal 1-2 kalimat per properti.
              Jika tidak ada yang cocok, katakan dengan jujur.
              """,
            },
          ],
        },
      ],
    };

    http.Response response;
    int retry = 0;
    while (true) {
      await Future.delayed(const Duration(seconds: 1));
      response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 503 && retry < 1) {
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

  // Simpan pesan dan load ke storage
  void _saveMessages() {
    final encoded = _messages
        .map(
          (m) => {
            'userId': m.user.id,
            'text': m.text,
            'createdAt': m.createdAt.toIso8601String(),
          },
        )
        .toList();
    _box.write(_storageKey, jsonEncode(encoded));
  }

  void _loadMessages() {
    final raw = _box.read<String>(_storageKey);
    if (raw == null) return;

    try {
      final List decoded = jsonDecode(raw);
      final loaded = decoded.map((m) {
        final user = m['userId'] == '1' ? _currentUser : _botUser;
        return ChatMessage(
          user: user,
          text: m['text'],
          createdAt: DateTime.parse(m['createdAt']),
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(loaded);
      });
    } catch (e) {
      debugPrint("Load messages error: $e");
    }
  }

  // ─── Handle Send ──────────────────────────────────────────────────────────
  void _handleSendMessage(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      _isTyping = true;
    });
    _saveMessages();

    try {
      final answer = await askGemini(m.text);

      setState(() {
        _isTyping = false;
        _messages.insert(
          0,
          ChatMessage(user: _botUser, createdAt: DateTime.now(), text: answer),
        );
      });
      _saveMessages();
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
      appBar: AppBar(
        title: const Text("Asisten Appkonkos AI"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _box.remove(_storageKey);
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    user: _botUser,
                    createdAt: DateTime.now(),
                    text: "Halo! Saya Asisten Appkonkos ...",
                  ),
                );
              });
            },
          ),
        ],
      ),
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

    final RegExp regExp = RegExp(r'\[MATCH:\s*(.*?)\]');
    final matches = regExp.allMatches(message.text);

    if (matches.isEmpty) {
      return Text(message.text);
    }

    try {
      final List<Widget> widgets = [];
      String remainingText = message.text;

      final firstMatchStart = matches.first.start;
      if (firstMatchStart > 0) {
        final introText = remainingText.substring(0, firstMatchStart).trim();
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

      for (final match in matches) {
        final propertyName = match.group(1)?.trim() ?? '';

        final matchStart = match.start;
        final lineStart = remainingText.lastIndexOf('\n', matchStart - 1) + 1;
        String lineDesc = remainingText.substring(lineStart, matchStart).trim();
        lineDesc = lineDesc.replaceFirst(RegExp(r'^\d+\.\s*'), '');
        lineDesc = lineDesc
            .replaceFirst(
              RegExp(RegExp.escape(propertyName), caseSensitive: false),
              '',
            )
            .replaceFirst(RegExp(r'^\s*[-–]\s*'), '')
            .trim();

        final afterMatch = remainingText.substring(match.end);
        final nextMatchIdx =
            RegExp(r'\[MATCH:').firstMatch(afterMatch)?.start ??
            afterMatch.length;
        final afterText = afterMatch.substring(0, nextMatchIdx).trim();

        final fullDesc = [
          lineDesc,
          afterText,
        ].where((s) => s.isNotEmpty).join(' ');

        final property = homeController.allProperties.firstWhereOrNull(
          (p) => p.name.toLowerCase().contains(propertyName.toLowerCase()),
        );

        if (property != null) {
          widgets.add(_buildPropertyCard(property, fullDesc));
          widgets.add(const SizedBox(height: 12));
        }
      }

      final lastMatchEnd = matches.last.end;
      if (lastMatchEnd < message.text.length) {
        final closingText = message.text.substring(lastMatchEnd).trim();
        final lines = closingText.split('\n');
        final closingOnly = lines
            .where(
              (l) =>
                  !RegExp(r'^\d+\.').hasMatch(l.trim()) && l.trim().isNotEmpty,
            )
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
      return Text(message.text.replaceAll(RegExp(r'\[MATCH:.*?\]'), '').trim());
    }
  }

  Widget _buildPropertyCard(
    dynamic property,
    String description, {
    String? distance,
  }) {
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
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
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
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      property.type ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.orange),
                      const SizedBox(width: 3),

                      Text(
                        property.rating?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (distance != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.route, size: 13, color: Colors.blue),
                        const SizedBox(width: 3),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          property.location,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
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
                        fontSize: 11,
                        color: Colors.black54,
                      ),
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
                          onTap: () => Get.to(
                            () => const DetailScreen(),
                            arguments: property,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Lihat Detail →",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
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
