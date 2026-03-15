import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../home/controllers/home_controller.dart';

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

  final String apiKey = 'AIzaSyAeZv3Aolub2Uetg5bU1lmb-ha3zMUsudw';
  final String modelName = 'gemini-2.5-flash';

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        user: _botUser,
        createdAt: DateTime.now(),
        text: "Halo! Saya Asisten Appkonkos Dekat. Ada yang bisa dibantu?",
      ),
    );
  }

  Future<String> askGemini(String userMessage) async {
    final kosList = homeController.properties
        .map((p) => '${p.name} (${p.type}, ${p.location}, Rp${p.price})')
        .join(', ');

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final body = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  """
              kamu adalah Kamu adalah asisten ramah Appkonkos.
              Aturan menjawab:
              - Jangan gunakan tanda ** atau format markdown.
              - Jawab dengan teks biasa yang rapi.
              - Fokus membantu mencari kos dan kontrakan.

              Data kos yang tersedia:
              $kosList
              Pertanyaan user:
              $userMessage
              """,
            },
          ],
        },
      ],
    };

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
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
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Bot AI")),
      body: DashChat(
        currentUser: _currentUser,
        onSend: _handleSendMessage,
        messages: _messages,
        typingUsers: _isTyping ? [_botUser] : [],
      ),
    );
  }
}
