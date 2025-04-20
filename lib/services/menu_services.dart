import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/menu_item.dart';
import '../models/category.dart';

class MenuService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItem> _menuItems = [];
  List<Category> _categories = [];
  List<MenuItem> _favorites = [];
  List<MenuItem> _popularItems = [];

  bool _isLoading = true;
  String _error = '';

  bool get isLoading => _isLoading;
  String get error => _error;
  List<MenuItem> get menuItems => _menuItems;
  List<Category> get categories => _categories;
  List<MenuItem> get favorites => _favorites;
  List<MenuItem> get popularItems => _popularItems;

  MenuService() {
    _categories = [
      Category(id: 'cat_rice', name: 'Rice', imageAsset: 'assets/images/rice1.jpg'),
      Category(id: 'cat_noodles', name: 'Noodles', imageAsset: 'assets/images/noodles1.jpg'),
      Category(id: 'cat_appetizers', name: 'Appetizers', imageAsset: 'assets/images/appetizers.jpg'),
      Category(id: 'cat_beverages', name: 'Beverages', imageAsset: 'assets/images/beverages.jpg'),
    ];
    fetchMenuItems();
    fetchFavorites();
  }

  Future<void> fetchMenuItems() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final querySnapshot = await _firestore.collection('menuItems').get();
      _menuItems = querySnapshot.docs
          .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to fetch menu items: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavorites() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      _favorites = snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch favorites: $e';
      print(_error);
    }
  }

  Future<void> toggleFavorite(MenuItem item, bool isFavorite) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final favRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(item.id);

    try {
      if (isFavorite) {
        await favRef.set(item.toMap());
      } else {
        await favRef.delete();
      }

      await fetchFavorites(); // Always reload the favorites list
    } catch (e) {
      _error = 'Failed to toggle favorite: $e';
      print(_error);
    } finally {
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String itemId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(itemId)
          .get();
      return doc.exists;
    } catch (e) {
      _error = 'Failed to check if item is favorite: $e';
      print(_error);
      return false;
    }
  }

  List<MenuItem> getItemsByCategory(List<MenuItem> items, String categoryId) {
    return items.where((item) => item.categoryId == categoryId).toList();
  }

  // Method to update stock in Firestore and locally
  Future<void> updateStockStatus(String itemId, bool inStock) async {
    try {
      // Update stock status in Firestore
      await _firestore.collection('menuItems').doc(itemId).update({'inStock': inStock});

      // Update stock status locally
      _menuItems = _menuItems.map((item) {
        return item.id == itemId ? item.copyWith(inStock: inStock) : item;
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update stock: $e';
      print(_error);
    }
  }

  // Listen to real-time stock changes
  void listenToStockChanges(void Function(String itemId, bool inStock) callback) {
    _firestore.collection('menuItems').snapshots().listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final itemId = doc.id;
        final inStock = data['inStock'] ?? true;
        callback(itemId, inStock);
      }
    });
  }

  // Method to update item stock locally without Firestore update (useful for UI updates)
  void updateItemStockLocally(String itemId, bool inStock) {
    _menuItems = _menuItems.map((item) {
      return item.id == itemId ? item.copyWith(inStock: inStock) : item;
    }).toList();
    notifyListeners();
  }

  Future<void> getPopularItems(List<String> itemIds) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      List<MenuItem> items = [];
      for (String id in itemIds) {
        final doc = await _firestore.collection('menuItems').doc(id).get();
        if (doc.exists) {
          items.add(MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>));
        }
      }
      _popularItems = items;
    } catch (e) {
      _error = 'Failed to load popular items: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
