import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final Color neonColor = message.isUser ? Colors.cyanAccent : Colors.pinkAccent;
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: neonColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: neonColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(message.isUser ? 15 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 15),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Courier', // Using Courier for a retro-future vibe
                shadows: [
                  Shadow(
                    color: neonColor.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 10, 
                color: neonColor.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
