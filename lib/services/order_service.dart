import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/order_model.dart';

class OrderService with ChangeNotifier {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  OrderService({String? location}) {
    _fetchOrders(location);
  }

  /// Fetch orders in real-time with optional location filtering
  void _fetchOrders(String? location) {
    fs.Query query = _firestore
        .collection('canteenOrders')
        .orderBy('time', descending: true);

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    query.snapshots().listen(
          (fs.QuerySnapshot snapshot) {
        _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        notifyListeners();
      },
      onError: (error) {
        print("Error fetching orders: $error");
      },
    );
  }

  /// Add a new order to Firestore and reflect it in local state
  Future<void> addOrder(Order order) async {
    try {
      final docRef = await _firestore.collection('canteenOrders').add({
        'items': order.items,
        'total': order.total,
        'location': order.location,
        'status': order.status,
        'time': fs.Timestamp.now(),
      });

      final newOrder = Order(
        id: docRef.id,
        items: order.items,
        total: order.total,
        location: order.location,
        status: order.status,
      );

      _orders.insert(0, newOrder);
      notifyListeners();
    } catch (e) {
      print("Error adding order: $e");
    }
  }

  /// Update the status of an order in Firestore
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('canteenOrders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (e) {
      print("Error updating order status: $e");
    }
  }
}
