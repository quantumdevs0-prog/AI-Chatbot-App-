import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost on the host machine
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<String> sendMessage({
    required String message,
    required String apiKey,
    required String model,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'api_key': apiKey,
          'model': model,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'No response from bot';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: Could not connect to backend. Make sure it is running.';
    }
  }
}
