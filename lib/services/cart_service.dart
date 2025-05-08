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
  /// Remove an item from the cart
  Future<void> removeItemFromCart(String itemId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final cartItemRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(itemId);

      // Delete the item from Firestore
      await cartItemRef.delete();  // Use delete instead of update
    }
  }



  /// Clear all items from the cart
  Future<void> clearCart() async {
    final cartRef = _firestore.collection('users').doc(_userId).collection('cart');
    final snapshot = await cartRef.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
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

  /// Checkout: Move cart to canteen orders
  Future<void> checkout() async {
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
  }

  /// Decrease the quantity of an item in the cart
  Future<void> decreaseQuantity(String itemId) async {
    final cartRef = _firestore.collection('cart').doc(itemId);
    final doc = await cartRef.get();

    if (doc.exists) {
      final currentQty = doc.data()?['quantity'] ?? 1;
      final newQty = currentQty - 1;
      await cartRef.update({'quantity': newQty < 0 ? 0 : newQty});
    }
  }


  /// Listen for stock updates and handle out-of-stock items in the cart
  /// Listen for stock updates and mark out-of-stock items
  Future<void> listenForStockUpdates() async {
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
          // Update only the inStock flag, don't remove the item
          await cartRef.update({'inStock': inStock});
        }
      }
    });
  }


  /// ✅ TOTAL ITEMS COUNT FUNCTION (ADDED NOW)
  int totalItemsCount() {
    int total = 0;
    for (var item in _cartItems) {
      total += item['quantity'] as int;
    }
    return total;
  }
}