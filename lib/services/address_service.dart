// lib/services/address_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/address_model.dart';

class AddressService with ChangeNotifier {
  List<Address> _addresses = [
    Address(title: 'Block A'),
    Address(title: 'Block B'),
    Address(title: 'Block C'),
    Address(title: 'Block D'),
    Address(title: 'Block E'),
    Address(title: 'Block F'),
  ];

  String? _selectedAddress;

  List<Address> get addresses => _addresses;

  String? get selectedAddress => _selectedAddress;

  Future<void> loadSelectedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedAddress = prefs.getString('selected_address') ?? _addresses.first.title;
    notifyListeners();
  }

  Future<void> selectAddress(String title) async {
    _selectedAddress = title;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_address', title);
    notifyListeners();
  }
}
