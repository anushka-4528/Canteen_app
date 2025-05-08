import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TranslateService with ChangeNotifier {
  final String _apiKey = 'AIzaSyACZprG9y3jRLqZzrdYEN1xrJ7VQ-KvJqo';
  final Map<String, String> _cache = {}; // <English, Telugu>

  Future<String> translateText(String text, {String targetLang = 'te'}) async {
    if (_cache.containsKey(text)) {
      return _cache[text]!;
    }

    final url = Uri.parse('https://translation.googleapis.com/language/translate/v2?key=$_apiKey');

    final response = await http.post(
      url,
      body: jsonEncode({
        'q': text,
        'target': targetLang,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translated = data['data']['translations'][0]['translatedText'];
      _cache[text] = translated; // Save it
      return translated;
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
