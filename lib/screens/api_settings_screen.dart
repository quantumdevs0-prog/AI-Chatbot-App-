import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  String? _selectedModel;
  List<String> _models = [];
  bool _isLoadingModels = false;
  String _provider = "";

  static const String baseUrl = 'http://10.0.2.2:8000';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKeyController.text = prefs.getString('api_key') ?? '';
      _selectedModel = prefs.getString('model');
    });
  }

  Future<void> _fetchModels() async {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter API Key first')),
      );
      return;
    }

    setState(() {
      _isLoadingModels = true;
      _models = [];
      _selectedModel = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/models'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'api_key': apiKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _models = List<String>.from(data['models']);
          _provider = data['provider'] ?? '';

          if (_models.isNotEmpty) {
            _selectedModel = _models.first;   // first chat model after filtering
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch models: $e')),
      );
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_apiKeyController.text.trim().isEmpty || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter API Key and select a model')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', _apiKeyController.text.trim());
    await prefs.setString('model', _selectedModel!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings Saved Successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('// CONFIGURATION', style: TextStyle(letterSpacing: 2)),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF0D0D0D),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ACCESS_TOKEN:',
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apiKeyController,
                style: const TextStyle(color: Colors.cyanAccent),
                decoration: const InputDecoration(
                  labelText: 'TOKEN_ID',
                  prefixIcon: Icon(Icons.vpn_key, color: Colors.cyanAccent),
                  filled: true,
                  fillColor: Color(0xFF1A1A1A),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _isLoadingModels ? null : _fetchModels,
                icon: _isLoadingModels
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.pinkAccent),
                      )
                    : const Icon(Icons.download, color: Colors.pinkAccent),
                label: Text(
                  _isLoadingModels ? 'SYNCING...' : 'FETCH_NEURAL_MODELS',
                  style: const TextStyle(color: Colors.pinkAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.pinkAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 30),
              if (_provider.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'HOST_PROVIDER: ${_provider.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              if (_models.isNotEmpty) ...[
                const Text(
                  'NEURAL_MODEL_SELECT:',
                  style: TextStyle(
                    color: Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    border: Border.all(color: Colors.cyanAccent),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedModel,
                      dropdownColor: const Color(0xFF1A1A1A),
                      style: const TextStyle(color: Colors.cyanAccent, fontFamily: 'Courier'),
                      isExpanded: true,
                      items: _models.map((String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedModel = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.cyanAccent.withOpacity(0.1),
                  side: const BorderSide(color: Colors.cyanAccent, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                ),
                child: const Text(
                  'EXECUTE_UPDATE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.cyanAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '// WARNING: Unauthorized access prohibited',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.pinkAccent, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
