import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch categories (if needed)
  Stream<List<Map<String, dynamic>>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Fetch menu items by categoryId
  Stream<List<MenuItem>> getMenuItemsByCategory(String categoryId) {
    return _firestore
        .collection('menu') // Ensure your collection name is correct
        .where('categoryId', isEqualTo: categoryId) // Filter by category
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }


  /// Toggle stock status
  Future<void> toggleStockStatus(String itemId, bool inStock) async {
    await _firestore.collection('menu').doc(itemId).update({'inStock': inStock});
  }

  /// Toggle favorite status
  Future<void> toggleFavoriteStatus(String itemId, bool isFavorite) async {
    await _firestore.collection('menu').doc(itemId).update({'isFavorite': isFavorite});
  }

  /// Add new menu item
  Future<void> addMenuItem(MenuItem item, String categoryId) async {
    await _firestore.collection('menu').add({
      ...item.toMap(),
      'categoryId': categoryId,
    });
  }

  /// Update existing menu item
  Future<void> updateMenuItem(MenuItem item) async {
    await _firestore.collection('menu').doc(item.id).update(item.toMap());
  }

  /// Delete menu item
  Future<void> deleteMenuItem(String itemId) async {
    await _firestore.collection('menu').doc(itemId).delete();
  }
  Future<MenuItem?> getMenuItemById(String itemId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('menuItems')
          .doc(itemId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return MenuItem(
          id: doc.id,
          name: data['name'],
          price: data['price'],

          description: data['description'],
          inStock: data['inStock'],
          categoryId: data['categoryId'],
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting menu item by ID: $e');
      return null;
    }
  }

}
