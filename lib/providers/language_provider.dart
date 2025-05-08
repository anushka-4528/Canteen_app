import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isTelugu = false;

  bool get isTelugu => _isTelugu;

  void toggleLanguage() {
    _isTelugu = !_isTelugu;
    notifyListeners();
  }
}
