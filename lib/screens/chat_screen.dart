import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import 'api_settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('api_key') ?? '';
    final model = prefs.getString('model') ?? 'gpt-4o-mini';

    if (apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set your API Key in Settings first')),
        );
      }
      return;
    }

    setState(() {
      _messages.add(Message(text: text, isUser: true, timestamp: DateTime.now()));
      _messageController.clear();
      _isLoading = true;
    });

    final reply = await _apiService.sendMessage(
      message: text,
      apiKey: apiKey,
      model: model,
    );

    setState(() {
      _messages.add(Message(text: reply, isUser: false, timestamp: DateTime.now()));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEURAL LINK // CHAT', 
          style: TextStyle(letterSpacing: 2, fontSize: 18)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ApiSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0D0D0D),
              const Color(0xFF1A1A1A).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.pinkAccent,
                  minHeight: 1,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                border: Border(top: BorderSide(color: Colors.cyanAccent, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '> INPUT_COMMAND...',
                        hintStyle: TextStyle(color: Colors.cyanAccent.withOpacity(0.3)),
                        filled: true,
                        fillColor: Colors.black,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.cyanAccent),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 4,
                        )
                      ]
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.bolt),
                      onPressed: _handleSend,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
