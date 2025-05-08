// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// //
// // import '../models/menu_item.dart';
// // import '../models/category.dart';
// //
// // class CanteenMenuService extends ChangeNotifier {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //
// //   List<MenuItem> _menuItems = [];
// //   List<Category> _categories = [];
// //
// //
// //   bool _isLoading = true;
// //   String _error = '';
// //
// //   bool get isLoading => _isLoading;
// //   String get error => _error;
// //   List<MenuItem> get menuItems => _menuItems;
// //   List<Category> get categories => _categories;
// //
// //   CanteenMenuService() {
// //     _categories = [
// //       Category(id: 'cat_rice', name: 'Rice', imageAsset: 'assets/images/rice1.jpg'),
// //       Category(id: 'cat_noodles', name: 'Noodles', imageAsset: 'assets/images/noodles1.jpg'),
// //       Category(id: 'cat_appetizers', name: 'Appetizers', imageAsset: 'assets/images/appetizers.jpg'),
// //       Category(id: 'cat_beverages', name: 'Beverages', imageAsset: 'assets/images/beverages.jpg'),
// //     ];
// //     fetchMenuItems();
// //
// //   }
// //
// //   Future<void> fetchMenuItems() async {
// //     _isLoading = true;
// //     _error = '';
// //     notifyListeners();
// //
// //     try {
// //       final querySnapshot = await _firestore.collection('menuItems').get();
// //       _menuItems = querySnapshot.docs
// //           .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
// //           .toList();
// //     } catch (e) {
// //       _error = 'Failed to fetch menu items: $e';
// //       print(_error);
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }
// //
// //
// //
// //
// //
// //
// //
// //   List<MenuItem> getItemsByCategory(List<MenuItem> items, String categoryId) {
// //     return items.where((item) => item.categoryId == categoryId).toList();
// //   }
// //
// //   // Method to update stock in Firestore and locally
// //   Future<void> updateStockStatus(String itemId, bool inStock) async {
// //     try {
// //       // Update stock status in Firestore
// //       await _firestore.collection('menuItems').doc(itemId).update({'inStock': inStock});
// //
// //       // Update stock status locally
// //       _menuItems = _menuItems.map((item) {
// //         return item.id == itemId ? item.copyWith(inStock: inStock) : item;
// //       }).toList();
// //
// //       notifyListeners();
// //     } catch (e) {
// //       _error = 'Failed to update stock: $e';
// //       print(_error);
// //     }
// //   }
// //
// //   // Listen to real-time stock changes
// //   void listenToStockChanges(void Function(String itemId, bool inStock) callback) {
// //     _firestore.collection('menuItems').snapshots().listen((snapshot) {
// //       for (var doc in snapshot.docs) {
// //         final data = doc.data();
// //         final itemId = doc.id;
// //         final inStock = data['inStock'] ?? true;
// //         callback(itemId, inStock);
// //       }
// //     });
// //   }
// //
// //   // Method to update item stock locally without Firestore update (useful for UI updates)
// //   void updateItemStockLocally(String itemId, bool inStock) {
// //     _menuItems = _menuItems.map((item) {
// //       return item.id == itemId ? item.copyWith(inStock: inStock) : item;
// //     }).toList();
// //     notifyListeners();
// //   }
// //
// //
// //   bool isInStock(String itemId) {
// //     final item = _menuItems.cast<MenuItem?>().firstWhere(
// //           (item) => item?.id == itemId,
// //       orElse: () => null,
// //     );
// //     return item?.inStock ?? false;
// //   }
// //
// //
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:translator/translator.dart';
// import 'package:hive/hive.dart';
//
// import '../models/menu_item.dart';
// import '../models/category.dart';
//
// class CanteenMenuService extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final GoogleTranslator _translator = GoogleTranslator();
//
//   List<MenuItem> _menuItems = [];
//   List<Category> _categories = [];
//
//   bool _isLoading = true;
//   String _error = '';
//
//   bool _isTelugu = false;
//
//   bool get isLoading => _isLoading;
//
//   String get error => _error;
//
//   List<MenuItem> get menuItems => _menuItems;
//
//   List<Category> get categories => _categories;
//
//   bool get isTelugu => _isTelugu;
//
//   CanteenMenuService() {
//     _initializeCategories();
//     _loadCachedMenuItems();
//   }
//
//   void toggleLanguage(bool value) {
//     _isTelugu = value;
//     _translateMenuItems();
//     _translateCategories();
//     notifyListeners();
//   }
//
//   Future<void> _loadCachedMenuItems() async {
//     var box = await Hive.openBox('menuItems');
//     if (box.isNotEmpty) {
//       _menuItems = box.values.toList().cast<MenuItem>();
//       notifyListeners();
//     } else {
//       fetchMenuItems(); // Fallback to fetch if no cache
//     }
//   }
//
//   Future<void> _initializeCategories() async {
//     var box = await Hive.openBox('categories');
//     if (box.isNotEmpty) {
//       _categories = box.values.toList().cast<Category>();
//       notifyListeners();
//     } else {
//       fetchCategories(); // Fallback to fetch if no cache
//     }
//   }
//
//   Future<void> fetchMenuItems() async {
//     _isLoading = true;
//     _error = '';
//     notifyListeners();
//
//     try {
//       final querySnapshot = await _firestore.collection('menuItems').get();
//       final List<MenuItem> fetchedItems = [];
//
//       for (var doc in querySnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         MenuItem menuItem = MenuItem.fromMap(doc.id, data);
//
//         fetchedItems.add(menuItem);
//       }
//
//       _menuItems = fetchedItems;
//
//       // Cache menu items locally
//       var box = await Hive.openBox('menuItems');
//       for (var item in fetchedItems) {
//         await box.put(item.id, item);
//       }
//     } catch (e) {
//       _error = 'Failed to fetch menu items: $e';
//       print(_error);
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchCategories() async {
//     try {
//       // Initialize categories manually with empty translatedName
//       List<Category> fetchedCategories = [
//         Category(id: 'cat_rice',
//             name: 'Rice',
//             imageAsset: 'assets/images/rice1.jpg',
//             translatedName: ''),
//         Category(id: 'cat_noodles',
//             name: 'Noodles',
//             imageAsset: 'assets/images/noodles1.jpg',
//             translatedName: ''),
//         Category(id: 'cat_appetizers',
//             name: 'Appetizers',
//             imageAsset: 'assets/images/appetizers.jpg',
//             translatedName: ''),
//         Category(id: 'cat_beverages',
//             name: 'Beverages',
//             imageAsset: 'assets/images/beverages.jpg',
//             translatedName: ''),
//       ];
//
//       _categories = fetchedCategories;
//
//       // Cache categories locally using Hive
//       var box = await Hive.openBox('categories');
//       for (var category in _categories) {
//         await box.put(category.id, category);
//       }
//
//       // If the current language is Telugu, translate category names
//       if (_isTelugu) {
//         await _translateCategories();
//       }
//
//       notifyListeners();
//     } catch (e) {
//       print('Failed to fetch categories: $e');
//     }
//   }
//
//   Future<void> _translateCategories() async {
//     if (_isTelugu) {
//       try {
//         List<Category> translatedCategories = [];
//         for (var category in _categories) {
//           final translation = await _translator.translate(
//               category.name, to: 'te');
//           translatedCategories.add(
//             Category(
//               id: category.id,
//               name: category.name, // Original name
//               imageAsset: category.imageAsset,
//               translatedName: translation.text, // Translated name
//             ),
//           );
//         }
//
//         _categories = translatedCategories;
//         notifyListeners();
//       } catch (e) {
//         print('Category translation failed: $e');
//       }
//     }
//   }
//
//   Future<void> _translateMenuItems() async {
//     if (_isTelugu) {
//       try {
//         List<MenuItem> translatedItems = [];
//         for (var menuItem in _menuItems) {
//           final nameTranslation = await _translator.translate(
//               menuItem.name, to: 'te');
//           final descTranslation = await _translator.translate(
//               menuItem.description, to: 'te');
//
//           translatedItems.add(menuItem.copyWith(
//             translatedName: nameTranslation.text,
//
//           ));
//         }
//
//         _menuItems = translatedItems;
//         notifyListeners();
//       } catch (e) {
//         print('Menu item translation failed: $e');
//       }
//     }
//   }
//
//
//   List<MenuItem> getItemsByCategory(String categoryId) {
//     return _menuItems.where((item) => item.categoryId == categoryId).toList();
//   }
//
//   Future<void> updateStockStatus(String itemId, bool inStock) async {
//     try {
//       await _firestore.collection('menuItems').doc(itemId).update(
//           {'inStock': inStock});
//
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
//   void listenToStockChanges(
//       void Function(String itemId, bool inStock) callback) {
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
//   void updateItemStockLocally(String itemId, bool inStock) {
//     _menuItems = _menuItems.map((item) {
//       return item.id == itemId ? item.copyWith(inStock: inStock) : item;
//     }).toList();
//     notifyListeners();
//   }
//
//   bool isInStock(String itemId) {
//     try {
//       final item = _menuItems.firstWhere((item) => item.id == itemId);
//       return item.inStock;
//     } catch (e) {
//       return false; // If item not found, treat as not in stock
//     }
//   }
//
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';
import '../models/category.dart';
import 'translation_service.dart';

class CanteenMenuService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TranslateService _translateService = TranslateService();

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

  Future<void> toggleLanguage(bool value) async {
    _isTelugu = value;
    await fetchData();
    notifyListeners();
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMenuItems() async {
    final snapshot = await _firestore.collection('menuItems').get();
    List<MenuItem> items = [];

    for (var doc in snapshot.docs) {
      final item = MenuItem.fromMap(doc.id, doc.data());
      if (_isTelugu) {
        final translatedName = await _translateService.translateText(item.name, targetLang: 'te');
        final translatedDesc = await _translateService.translateText(item.description, targetLang: 'te');
        items.add(item.copyWith(
          translatedName: translatedName,
        ));
      } else {
        items.add(item);
      }
    }

    _menuItems = items;
  }

  Future<void> fetchCategories() async {
    List<Category> staticCategories = [
      Category(id: 'cat_rice', name: 'Rice', imageAsset: 'assets/images/rice1.jpg',),
      Category(id: 'cat_noodles', name: 'Noodles', imageAsset: 'assets/images/noodles1.jpg'),
      Category(id: 'cat_appetizers', name: 'Appetizers', imageAsset: 'assets/images/appetizers.jpg'),
      Category(id: 'cat_beverages', name: 'Beverages', imageAsset: 'assets/images/beverages.jpg'),
    ];

    if (_isTelugu) {
      _categories = await Future.wait(staticCategories.map((category) async {
        final translated = await _translateService.translateText(category.name, targetLang: 'te');
        return category.copyWith(translatedName: translated);
      }));
    } else {
      _categories = staticCategories;
    }
  }

  List<MenuItem> getItemsByCategory(String categoryId) {
    return _menuItems.where((item) => item.categoryId == categoryId).toList();
  }

  String getMenuItemName(MenuItem item) {
    return _isTelugu ? (item.translatedName.isNotEmpty ? item.translatedName : item.name) : item.name;
  }

  String getCategoryName(Category category) {
    return _isTelugu ? (category.translatedName.isNotEmpty ? category.translatedName : category.name) : category.name;
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
    }
  }



  Future<void> addMenuItem(MenuItem item) async {
  try {
  final menuCollection = _firestore.collection('menuItems');

  // Add the new item to the menu collection
  final docRef = await menuCollection.add({
  'name': item.name,
  'description': item.description,
  'categoryId': item.categoryId,
  'price': item.price,
  'inStock': item.inStock,
  'translatedName': item.translatedName,
  // Optionally add image URL if applicable

  });

  // Set the id of the item after adding to Firestore
  item.id = docRef.id;

  // Optionally notify listeners to update the UI
  notifyListeners();
  } catch (e) {
  error = 'Failed to add item: $e';
  }
  }
  }


