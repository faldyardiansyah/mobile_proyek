import 'dart:convert';
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
    firstName: 'Asisten Kos & kontrakan',
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
        text: "Halo! Saya Asisten Appkonkos. Ada yang bisa dibantu?",
      ),
    );
  }

Future<String> askGemini(String userMessage) async {
  final kosList = homeController.allProperties
      .map((p) => '${p.name} (Tipe: ${p.type}, Lokasi: ${p.location}, Harga: Rp${p.price})')
      .join(', ');

  final body = {
    "contents": [
      {
        "parts": [
          {
            "text": """
              Kamu adalah asisten ramah Appkonkos.
              Data properti tersedia: $kosList

              Pertanyaan user ini: $userMessage

              Tugasmu:
              1. Bantu user mencari tempat tinggal berdasarkan data di atas.
              2. Jika ada yang cocok, sebutkan namanya dan tambahkan kode [MATCH: Nama Properti] di akhir kalimat.
              3. Contoh: "Ada nih, Kontrakan Pak Budi di Lohbener sangat terjangkau. [MATCH: Kontrakan Pak Budi]"
              4. Jawab dengan teks biasa, jangan gunakan markdown (**).
              """
          },
        ],
      },
    ],
  };

    http.Response response;

    int retry = 0;
    while (true) {
      response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey'),
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
          ChatMessage(user: _botUser, createdAt: DateTime.now(), text: answer),
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
  print("Detail Error: $e"); 
}
  }

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
          return _buildMessageCard(message);
        },
      ),
    ),
  );
}

Widget _buildMessageCard(ChatMessage message) {
  if (message.user.id == _botUser.id && message.text.contains('[MATCH:')) {
    try {
      final RegExp regExp = RegExp(r'\[MATCH:\s*(.*?)\]');
      final match = regExp.firstMatch(message.text);
      final String? foundName = match?.group(1)?.trim();
      
      final String cleanText = message.text.split('[MATCH:')[0].trim();

      final property = homeController.allProperties.firstWhere(
        (p) => p.name.toLowerCase().contains(foundName?.toLowerCase() ?? ""),
        orElse: () => homeController.allProperties.first,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cleanText),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Get.toNamed('/detail', arguments: property),
            child: Container(
              width: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar & Tipe
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 130,
                          width: double.infinity,
                          color: Colors.blue.shade50,
                          child: const Icon(Icons.home_work_rounded, size: 50, color: Colors.blue),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                          child: Text(property.type, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  // Info & Rating
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(property.rating.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            const Icon(Icons.location_on, size: 14, color: Colors.grey),
                            Expanded(child: Text(property.location, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                        const Divider(height: 24),
                        Text("Rp ${property.price}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } catch (e) {
      return Text(message.text); 
    }
  }
  return Text(message.text);
}
}