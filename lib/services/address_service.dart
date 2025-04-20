import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/address_model.dart'; // Make sure this matches your file name

class AddressService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Address> _addresses = [];
  bool _isLoading = false;
  String _error = '';

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String get error => _error;

  AddressService() {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'User not logged in';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .get();

      _addresses = snapshot.docs
          .map((doc) => Address.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch addresses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAddress(Address address) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc();

      final newAddress = Address(
        id: docRef.id,
        title: address.title,
        addressLine: address.addressLine,
        city: address.city,
        pincode: address.pincode,
      );

      await docRef.set(newAddress.toMap());
      _addresses.add(newAddress);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add address: $e';
      notifyListeners();
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      final user = _auth.currentUser;
      if (user == null || address.id.isEmpty) throw Exception('Invalid update');

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(address.id);

      await docRef.update(address.toMap());

      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = address;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update address: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addressId)
          .delete();

      _addresses.removeWhere((address) => address.id == addressId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete address: $e';
      notifyListeners();
    }
  }
}
