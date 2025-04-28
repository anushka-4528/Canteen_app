import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser!.uid;

  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> get cartItems => _cartItems;

  CartService() {
    _listenToCartChanges();
    listenForStockUpdates();
  }

  /// Listen to cart changes in Firestore to update local cart items
  void _listenToCartChanges() {
    _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      _cartItems = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      notifyListeners();
    });
  }

  /// 🔥 NEW: Expose cart items stream for StreamBuilder
  Stream<List<Map<String, dynamic>>> getCartItemsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  /// Add an item to the cart, incrementing quantity if already in cart
  Future<void> addItemToCart(Map<String, dynamic> item) async {
    final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
    final itemDoc = cartRef.doc(item['id']);

    final docSnapshot = await itemDoc.get();
    if (docSnapshot.exists) {
      await itemDoc.update({'quantity': FieldValue.increment(1)});
    } else {
      await itemDoc.set({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'image': item['image'],
        'quantity': 1,
        'inStock': true,
      });
    }
  }

  /// Remove an item from the cart
  Future<void> removeItemFromCart(String itemId) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  /// Clear all items from the cart
  Future<void> clearCart() async {
    final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
    final snapshot = await cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    _cartItems.clear(); // Clear the local cart items too
    notifyListeners(); // Notify listeners to update UI
  }

  /// Update the quantity of an item in the cart
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItemFromCart(itemId);
    } else {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('cart')
          .doc(itemId)
          .update({'quantity': quantity});
    }
  }

  /// Increase the quantity of an item in the cart
  Future<void> increaseQuantity(String itemId) async {
    final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
    final itemDoc = cartRef.doc(itemId);
    final docSnapshot = await itemDoc.get();

    if (docSnapshot.exists) {
      int currentQuantity = docSnapshot['quantity'];
      await itemDoc.update({'quantity': currentQuantity + 1});
    }
  }

  /// Decrease the quantity of an item in the cart
  Future<void> decreaseQuantity(String itemId) async {
    final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
    final itemDoc = cartRef.doc(itemId);
    final docSnapshot = await itemDoc.get();

    if (docSnapshot.exists) {
      int currentQuantity = docSnapshot['quantity'];
      if (currentQuantity > 1) {
        await itemDoc.update({'quantity': currentQuantity - 1});
      } else {
        await removeItemFromCart(itemId);
      }
    }
  }

  /// Listen for stock updates and handle out-of-stock items in the cart
  Future<void> listenForStockUpdates() async {
    FirebaseFirestore.instance
        .collection('menuItems')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final itemId = doc.id;
        final inStock = doc['inStock'];

        // Update the stock status of items in the cart
        _cartItems = _cartItems.map((item) {
          if (item['id'] == itemId) {
            item['inStock'] = inStock; // Update stock status
            if (!inStock) {
              removeItemFromCart(itemId); // Remove out-of-stock items from cart
            }
          }
          return item;
        }).toList();
        notifyListeners();
      }
    });
  }
}
