import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  const ChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: Colors.cyanAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Colors.pinkAccent,
          surface: const Color(0xFF1A1A1A),
          onSurface: Colors.cyanAccent.withOpacity(0.8),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.cyanAccent),
          bodyMedium: TextStyle(color: Colors.cyanAccent),
          titleLarge: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          foregroundColor: Colors.pinkAccent,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.cyanAccent,
            side: const BorderSide(color: Colors.cyanAccent, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyanAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pinkAccent, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.cyanAccent),
          hintStyle: TextStyle(color: Color(0xFF333333)),
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
