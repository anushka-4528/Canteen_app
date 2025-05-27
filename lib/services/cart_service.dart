import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    try {
      print('Adding item to cart: ${item.toString()}'); // Debug log

      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
      final itemDoc = cartRef.doc(item['id']);

      final docSnapshot = await itemDoc.get();
      if (docSnapshot.exists) {
        await itemDoc.update({'quantity': FieldValue.increment(1)});
        print('Updated existing item quantity'); // Debug log
      } else {
        await itemDoc.set({
          'id': item['id'],
          'name': item['name'],
          'price': item['price'],
          'image': item['image'] ?? '', // Handle null image
          'quantity': 1,
          'inStock': true,
        });
        print('Added new item to cart'); // Debug log
      }
    } catch (e) {
      print('Error adding item to cart: $e');
      // You might want to show a snackbar or toast to the user
    }
  }

  /// Remove an item from the cart
  Future<void> removeItemFromCart(String itemId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartItemRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(itemId);

        await cartItemRef.delete();
        print('Removed item from cart: $itemId'); // Debug log
      }
    } catch (e) {
      print('Error removing item from cart: $e');
    }
  }

  /// Clear all items from the cart
  Future<void> clearCart() async {
    try {
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
      final snapshot = await cartRef.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('Cart cleared'); // Debug log
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  /// Update the quantity of an item in the cart
  Future<void> updateItemQuantity(String itemId, int quantity) async {
    try {
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
    } catch (e) {
      print('Error updating item quantity: $e');
    }
  }

  /// Increase the quantity of an item in the cart
  Future<void> increaseQuantity(String itemId) async {
    try {
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
      final itemDoc = cartRef.doc(itemId);
      final docSnapshot = await itemDoc.get();

      if (docSnapshot.exists) {
        int currentQuantity = docSnapshot['quantity'];
        await itemDoc.update({'quantity': currentQuantity + 1});
        print('Increased quantity for item: $itemId'); // Debug log
      }
    } catch (e) {
      print('Error increasing quantity: $e');
    }
  }

  /// Decrease the quantity of an item in the cart - FIXED
  Future<void> decreaseQuantity(String itemId) async {
    try {
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
      final itemDoc = cartRef.doc(itemId);
      final doc = await itemDoc.get();

      if (doc.exists) {
        final currentQty = doc.data()?['quantity'] ?? 1;
        final newQty = currentQty - 1;

        if (newQty <= 0) {
          await removeItemFromCart(itemId);
        } else {
          await itemDoc.update({'quantity': newQty});
        }
        print('Decreased quantity for item: $itemId'); // Debug log
      }
    } catch (e) {
      print('Error decreasing quantity: $e');
    }
  }

  /// Checkout: Move cart to canteen orders
  Future<void> checkout() async {
    try {
      final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
      final cartSnapshot = await cartRef.get();

      if (cartSnapshot.docs.isEmpty) return;

      final orderItems = cartSnapshot.docs.map((doc) => doc.data()).toList();
      final timestamp = Timestamp.now();

      await _firestore.collection('canteenOrders').add({
        'userId': _userId,
        'items': orderItems,
        'status': 'Received',
        'time': timestamp,
      });

      await clearCart();
      print('Checkout completed'); // Debug log
    } catch (e) {
      print('Error during checkout: $e');
    }
  }

  /// Listen for stock updates and mark out-of-stock items
  Future<void> listenForStockUpdates() async {
    try {
      FirebaseFirestore.instance
          .collection('menuItems')
          .snapshots()
          .listen((snapshot) async {
        for (var doc in snapshot.docs) {
          final itemId = doc.id;
          final inStock = doc['inStock'];

          final cartRef = _firestore
              .collection('users')
              .doc(_userId)
              .collection('cart')
              .doc(itemId);

          final cartSnapshot = await cartRef.get();
          if (cartSnapshot.exists) {
            await cartRef.update({'inStock': inStock});
          }
        }
      });
    } catch (e) {
      print('Error listening for stock updates: $e');
    }
  }

  /// Total items count function
  int totalItemsCount() {
    int total = 0;
    for (var item in _cartItems) {
      total += item['quantity'] as int;
    }
    return total;
  }
}