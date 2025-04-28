import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  static const String _apiKey = 'AIzaSyACZprG9y3jRLqZzrdYEN1xrJ7VQ-KvJqo';
  static const String _url = 'https://api.mymemory.translated.net/get';

  Future<String> translateText(String text, String targetLang) async {
    final response = await http.get(Uri.parse('$_url?q=$text&langpair=en|$targetLang'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['responseData']['translatedText'] ?? text;  // Fallback to original text if translation fails
    } else {
      throw Exception('Failed to load translation');
    }
  }
}

