// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import '../models/menu_item.dart';
// import '../models/category.dart';
//
// class MenuService extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   List<MenuItem> _menuItems = [];
//   List<Category> _categories = [];
//   List<MenuItem> _favorites = [];
//   List<MenuItem> _popularItems = [];
//
//   bool _isLoading = true;
//   String _error = '';
//
//   bool get isLoading => _isLoading;
//   String get error => _error;
//   List<MenuItem> get menuItems => _menuItems;
//   List<Category> get categories => _categories;
//   List<MenuItem> get favorites => _favorites;
//   List<MenuItem> get popularItems => _popularItems;
//
//   MenuService() {
//     _categories = [
//       Category(id: 'cat_rice', name: 'Rice', imageAsset: 'assets/images/rice1.jpg',translatedName: ''),
//       Category(id: 'cat_noodles', name: 'Noodles', imageAsset: 'assets/images/noodles1.jpg',translatedName: ''),
//       Category(id: 'cat_appetizers', name: 'Appetizers', imageAsset: 'assets/images/appetizers.jpg',translatedName: ''),
//       Category(id: 'cat_beverages', name: 'Beverages', imageAsset: 'assets/images/beverages.jpg',translatedName: ''),
//     ];
//     fetchMenuItems();
//     fetchFavorites();
//   }
//
//   Future<void> fetchMenuItems() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();
//
//     try {
//       final querySnapshot = await _firestore.collection('menuItems').get();
//       _menuItems = querySnapshot.docs
//           .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       _error = 'Failed to fetch menu items: $e';
//       print(_error);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchFavorites() async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;
//
//     try {
//       final snapshot = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .get();
//
//       _favorites = snapshot.docs
//           .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
//           .toList();
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to fetch favorites: $e';
//       print(_error);
//     }
//   }
//
//   Future<void> toggleFavorite(MenuItem item, bool isFavorite) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return;
//
//     final favRef = _firestore
//         .collection('users')
//         .doc(userId)
//         .collection('favorites')
//         .doc(item.id);
//
//     try {
//       if (isFavorite) {
//         await favRef.set(item.toMap());
//       } else {
//         await favRef.delete();
//       }
//
//       await fetchFavorites(); // Always reload the favorites list
//     } catch (e) {
//       _error = 'Failed to toggle favorite: $e';
//       print(_error);
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   Future<bool> isFavorite(String itemId) async {
//     final userId = FirebaseAuth.instance.currentUser?.uid;
//     if (userId == null) return false;
//
//     try {
//       final doc = await _firestore
//           .collection('users')
//           .doc(userId)
//           .collection('favorites')
//           .doc(itemId)
//           .get();
//       return doc.exists;
//     } catch (e) {
//       _error = 'Failed to check if item is favorite: $e';
//       print(_error);
//       return false;
//     }
//   }
//
//   List<MenuItem> getItemsByCategory(List<MenuItem> items, String categoryId) {
//     return items.where((item) => item.categoryId == categoryId).toList();
//   }
//
//   // Method to update stock in Firestore and locally
//   Future<void> updateStockStatus(String itemId, bool inStock) async {
//     try {
//       // Update stock status in Firestore
//       await _firestore.collection('menuItems').doc(itemId).update({'inStock': inStock});
//
//       // Update stock status locally
//       _menuItems = _menuItems.map((item) {
//         return item.id == itemId ? item.copyWith(inStock: inStock) : item;
//       }).toList();
//
//       notifyListeners();
//     } catch (e) {
//       _error = 'Failed to update stock: $e';
//       print(_error);
//     }
//   }
//
//   // Listen to real-time stock changes
//   void listenToStockChanges(void Function(String itemId, bool inStock) callback) {
//     _firestore.collection('menuItems').snapshots().listen((snapshot) {
//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         final itemId = doc.id;
//         final inStock = data['inStock'] ?? true;
//         callback(itemId, inStock);
//       }
//     });
//   }
//
//   // Method to update item stock locally without Firestore update (useful for UI updates)
//   void updateItemStockLocally(String itemId, bool inStock) {
//     _menuItems = _menuItems.map((item) {
//       return item.id == itemId ? item.copyWith(inStock: inStock) : item;
//     }).toList();
//     notifyListeners();
//   }
//
//   Future<void> getPopularItems(List<String> itemIds) async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();
//
//     try {
//       List<MenuItem> items = [];
//       for (String id in itemIds) {
//         final doc = await _firestore.collection('menuItems').doc(id).get();
//         if (doc.exists) {
//           items.add(MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>));
//         }
//       }
//       _popularItems = items;
//     } catch (e) {
//       _error = 'Failed to load popular items: $e';
//       print(_error);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//   bool isInStock(String itemId) {
//     final item = _menuItems.cast<MenuItem?>().firstWhere(
//           (item) => item?.id == itemId,
//       orElse: () => null,
//     );
//     return item?.inStock ?? false;
//   }
//
//
// }
//
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
      Category(id: 'cat_rice', name: 'Rice', imageAsset: 'assets/images/rice1.jpg', translatedName: 'అన్నం'),
      Category(id: 'cat_noodles', name: 'Noodles', imageAsset: 'assets/images/noodles1.jpg', translatedName: 'నూడుల్స్'),
      Category(id: 'cat_appetizers', name: 'Appetizers', imageAsset: 'assets/images/appetizers.jpg', translatedName: 'స్టార్టర్స్'),
      Category(id: 'cat_beverages', name: 'Beverages', imageAsset: 'assets/images/beverages.jpg', translatedName: 'పానీయాలు'),
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

  bool isInStock(String itemId) {
    final item = _menuItems.cast<MenuItem?>().firstWhere(
          (item) => item?.id == itemId,
      orElse: () => null,
    );
    return item?.inStock ?? false;
  }

  // NEW METHOD: Get item by ID for Telugu name lookup
  MenuItem? getItemById(String itemId) {
    try {
      return _menuItems.firstWhere(
            (item) => item.id == itemId,
      );
    } catch (e) {
      print('Item with ID $itemId not found');
      return null;
    }
  }

  // NEW METHOD: Get item details as Map for cart enrichment
  Map<String, dynamic>? getItemDetailsById(String itemId) {
    final item = getItemById(itemId);
    if (item == null) return null;

    return {
      'id': item.id,
      'name': item.name,
      'telugu_name': item.translatedName, // Using translatedName field
      'price': item.price,
      'categoryId': item.categoryId,
      'inStock': item.inStock,
      'description': item.description,

    };
  }

  // NEW METHOD: Get Telugu name for an item
  String? getTeluguName(String itemId) {
    final item = getItemById(itemId);
    return item?.translatedName;
  }

  // NEW METHOD: Get item name based on language preference
  String getItemName(String itemId, {bool useTeluguName = false}) {
    final item = getItemById(itemId);
    if (item == null) return 'Unknown Item';

    if (useTeluguName && item.translatedName != null && item.translatedName!.isNotEmpty) {
      return item.translatedName!;
    }
    return item.name;
  }

  // NEW METHOD: Get category name based on language preference
  String getCategoryName(String categoryId, {bool useTeluguName = false}) {
    try {
      final category = _categories.firstWhere(
            (cat) => cat.id == categoryId,
      );

      if (useTeluguName && category.translatedName.isNotEmpty) {
        return category.translatedName;
      }
      return category.name;
    } catch (e) {
      return 'Unknown Category';
    }
  }

  // NEW METHOD: Get all items with language preference
  List<MenuItem> getMenuItemsWithLanguage({bool useTeluguNames = false}) {
    if (!useTeluguNames) {
      return _menuItems;
    }

    // Return items with Telugu names as display names
    return _menuItems.map((item) {
      // Create a copy with display name set to Telugu name if available
      return item.copyWith(
        name: (item.translatedName != null && item.translatedName!.isNotEmpty)
            ? item.translatedName!
            : item.name,
      );
    }).toList();
  }

  // NEW METHOD: Search items by name (supports both English and Telugu)
  List<MenuItem> searchItems(String query, {bool searchInTelugu = false}) {
    if (query.isEmpty) return _menuItems;

    return _menuItems.where((item) {
      final englishMatch = item.name.toLowerCase().contains(query.toLowerCase());

      if (searchInTelugu && item.translatedName != null) {
        final teluguMatch = item.translatedName!.toLowerCase().contains(query.toLowerCase());
        return englishMatch || teluguMatch;
      }

      return englishMatch;
    }).toList();
  }
}