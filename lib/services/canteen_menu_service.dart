import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/category.dart';

class CanteenMenuService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MenuItem> _menuItems = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _error = '';
  bool _isTelugu = false;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<MenuItem> get menuItems => _menuItems;
  List<Category> get categories => _categories;
  bool get isTelugu => _isTelugu;

  set error(String message) {
    _error = message;
    notifyListeners();
  }

  CanteenMenuService() {
    fetchData();
  }

  void toggleLanguage(bool value) {
    _isTelugu = value;
    notifyListeners(); // Just update UI, no need to refetch data
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await Future.wait([
        fetchCategories(),
        fetchMenuItems(),
      ]);
    } catch (e) {
      _error = 'Error fetching data: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMenuItems() async {
    try {
      final snapshot = await _firestore.collection('menuItems').get();
      List<MenuItem> items = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final item = MenuItem.fromMap(doc.id, data);
        items.add(item);
      }

      _menuItems = items;
    } catch (e) {
      _error = 'Failed to fetch menu items: $e';
      print(_error);
      rethrow;
    }
  }

  Future<void> fetchCategories() async {
    try {
      // Check if categories exist in Firestore, otherwise use static data
      final snapshot = await _firestore.collection('categories').get();

      if (snapshot.docs.isNotEmpty) {
        // Fetch categories from Firestore if they exist
        List<Category> firestoreCategories = [];
        for (var doc in snapshot.docs) {
          final category = Category.fromMap(doc.id, doc.data());
          firestoreCategories.add(category);
        }
        _categories = firestoreCategories;
      } else {
        // Use static categories with Telugu names
        List<Category> staticCategories = [
          Category(
              id: 'cat_rice',
              name: 'Rice',
              imageAsset: 'assets/images/rice1.jpg',
              translatedName: 'అన్నం' // Telugu for Rice
          ),
          Category(
              id: 'cat_noodles',
              name: 'Noodles',
              imageAsset: 'assets/images/noodles1.jpg',
              translatedName: 'నూడుల్స్' // Telugu for Noodles
          ),
          Category(
              id: 'cat_appetizers',
              name: 'Appetizers',
              imageAsset: 'assets/images/appetizers.jpg',
              translatedName: 'చిరుతిండిలు' // Telugu for Appetizers
          ),
          Category(
              id: 'cat_beverages',
              name: 'Beverages',
              imageAsset: 'assets/images/beverages.jpg',
              translatedName: 'పానీయాలు' // Telugu for Beverages
          ),
        ];
        _categories = staticCategories;
      }
    } catch (e) {
      _error = 'Failed to fetch categories: $e';
      print(_error);
      rethrow;
    }
  }

  List<MenuItem> getItemsByCategory(String categoryId) {
    return _menuItems.where((item) => item.categoryId == categoryId).toList();
  }

  String getMenuItemName(MenuItem item) {
    if (_isTelugu && item.translatedName.isNotEmpty) {
      return item.translatedName;
    }
    return item.name;
  }

  String getMenuItemDescription(MenuItem item) {
    // If your MenuItem model has translatedDescription field
    if (_isTelugu && item.translatedName.isNotEmpty) {
      // You might want to add translatedDescription to your model
      // return item.translatedDescription.isNotEmpty ? item.translatedDescription : item.description;
      return item.description;
    }
    return item.description;
  }

  String getCategoryName(Category category) {
    if (_isTelugu && category.translatedName.isNotEmpty) {
      return category.translatedName;
    }
    return category.name;
  }

  Future<void> updateStockStatus(String itemId, bool inStock) async {
    try {
      await _firestore.collection('menuItems').doc(itemId).update({'inStock': inStock});

      _menuItems = _menuItems.map((item) {
        return item.id == itemId ? item.copyWith(inStock: inStock) : item;
      }).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update stock: $e';
      print(_error);
    }
  }

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

  void updateItemStockLocally(String itemId, bool inStock) {
    _menuItems = _menuItems.map((item) {
      return item.id == itemId ? item.copyWith(inStock: inStock) : item;
    }).toList();

    notifyListeners();
  }

  bool isInStock(String itemId) {
    try {
      final item = _menuItems.firstWhere((item) => item.id == itemId);
      return item.inStock;
    } catch (e) {
      return false;
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    try {
      final menuCollection = _firestore.collection('menuItems');

      final docRef = await menuCollection.add({
        'name': item.name,
        'description': item.description,
        'categoryId': item.categoryId,
        'price': item.price,
        'inStock': item.inStock,
        'teluguName': item.translatedName, // Store Telugu name in Firestore
      });

      // Create new item with the generated ID
      final newItem = item.copyWith(id: docRef.id);
      _menuItems.add(newItem);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to add item: $e';
      print(_error);
    }
  }

  // Method to refresh data from Firestore
  Future<void> refreshData() async {
    await fetchData();
  }
}