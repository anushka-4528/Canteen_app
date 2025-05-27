// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart' as fs;
// import '../models/order_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class OrderService with ChangeNotifier {
//   final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
//   FirebaseAuth _auth = FirebaseAuth.instance;
//
//   List<Order> _orders = [];
//   List<Order> get orders => _orders;
//
//   OrderService() {
//     _auth.authStateChanges().listen((User? user) {
//       if (user != null) {
//         // Fetch orders once the user is authenticated
//         _fetchOrders();
//       } else {
//         // Clear the orders when the user logs out
//         _orders = [];
//         notifyListeners();
//       }
//     });
//   }
//
//   /// Fetch orders in real-time with optional location filtering
//   void _fetchOrders({String? location}) {
//     final currentUser = _auth.currentUser;
//     if (currentUser == null) {
//       print("User is not logged in. Cannot fetch orders.");
//       return;
//     }
//
//     // Debug log
//     print("Fetching orders for user: ${currentUser.uid}");
//
//     // Start query
//     fs.Query query = _firestore
//         .collection('canteenOrders')
//         .where('userId', isEqualTo: currentUser.uid);
//
//     // Add location filter if provided
//     if (location != null && location.isNotEmpty) {
//       query = query.where('location', isEqualTo: location);
//     }
//
//     // 🔧 Optional: Add this back after index is created
//     // query = query.orderBy('time', descending: true);
//
//     query.snapshots().listen(
//           (fs.QuerySnapshot snapshot) {
//         print("Fetched ${snapshot.docs.length} orders.");
//
//         for (var doc in snapshot.docs) {
//           print("Order doc: ${doc.id} => ${doc.data()}");
//         }
//
//         _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
//         notifyListeners();
//       },
//       onError: (error) {
//         print("Error fetching orders: $error");
//       },
//     );
//   }
//
//
//   /// Add a new order to Firestore and reflect it in local state
//   Future<void> addOrder(Order order) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print("User not logged in. Cannot place order.");
//         return;
//       }
//
//       final docRef = await fs.FirebaseFirestore.instance.collection('canteenOrders').add({
//         'items': order.items,
//         'total': order.total,
//         'location': order.location,
//         'status': order.status,
//         'time': fs.Timestamp.now(),  // Corrected for 'fs' alias
//         'userId': user.uid, // Correct userId handling here
//       });
//
//       final newOrder = Order(
//         id: docRef.id,
//         items: order.items,
//         total: order.total,
//         location: order.location,
//         status: order.status,
//         time: fs.Timestamp.now(),  // Use 'fs.Timestamp.now()' here
//         userId: user.uid,  // Pass userId as a parameter
//       );
//
//       _orders.insert(0, newOrder);  // Add the new order to the list of orders
//       notifyListeners();  // Notify listeners to update the UI
//
//     } catch (e) {
//       print("Error adding order: $e");  // Print out the error for debugging
//     }
//   }
//
//
//   /// Update the status of an order in Firestore
//   Future<void> updateOrderStatus(String orderId, String newStatus) async {
//     try {
//       await _firestore
//           .collection('canteenOrders')
//           .doc(orderId)
//           .update({'status': newStatus});
//     } catch (e) {
//       print("Error updating order status: $e");
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService with ChangeNotifier {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  OrderService() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // Fetch orders once the user is authenticated
        _fetchOrders();
      } else {
        // Clear the orders when the user logs out
        _orders = [];
        notifyListeners();
      }
    });
  }

  /// Fetch orders in real-time with optional location filtering
  void _fetchOrders({String? location}) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("User is not logged in. Cannot fetch orders.");
      return;
    }

    // Debug log
    print("Fetching orders for user: ${currentUser.uid}");

    // Start query
    fs.Query query = _firestore
        .collection('canteenOrders')
        .where('userId', isEqualTo: currentUser.uid);

    // Add location filter if provided
    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    // 🔧 Optional: Add this back after index is created
    // query = query.orderBy('time', descending: true);

    query.snapshots().listen(
          (fs.QuerySnapshot snapshot) {
        print("Fetched ${snapshot.docs.length} orders.");

        for (var doc in snapshot.docs) {
          print("Order doc: ${doc.id} => ${doc.data()}");
        }

        _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        notifyListeners();
      },
      onError: (error) {
        print("Error fetching orders: $error");
      },
    );
  }

  /// Add a new order to Firestore with both English and Telugu item names
  Future<void> addOrder(Order order) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in. Cannot place order.");
        return;
      }

      // Ensure each item has both English and Telugu names
      final processedItems = order.items.map((item) {
        final processedItem = Map<String, dynamic>.from(item);

        // Make sure we have both name and telugu_name fields
        if (!processedItem.containsKey('telugu_name')) {
          // If Telugu name is not provided, you might want to set a default
          // or fetch it from your menu service
          processedItem['telugu_name'] = item['name']; // Fallback to English name
          print("Warning: Telugu name not found for item ${item['name']}, using English name as fallback");
        }

        return processedItem;
      }).toList();

      final docRef = await fs.FirebaseFirestore.instance.collection('canteenOrders').add({
        'items': processedItems, // Use processed items with Telugu names
        'total': order.total,
        'location': order.location,
        'status': order.status,
        'time': fs.Timestamp.now(),
        'userId': user.uid,
      });

      final newOrder = Order(
        id: docRef.id,
        items: processedItems, // Use processed items
        total: order.total,
        location: order.location,
        status: order.status,
        time: fs.Timestamp.now(),
        userId: user.uid,
      );

      _orders.insert(0, newOrder);
      notifyListeners();

      print("Order added successfully with bilingual item names");

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

      // Update local state as well
      final orderIndex = _orders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex] = Order(
          id: _orders[orderIndex].id,
          items: _orders[orderIndex].items,
          total: _orders[orderIndex].total,
          location: _orders[orderIndex].location,
          status: newStatus, // Updated status
          time: _orders[orderIndex].time,
          userId: _orders[orderIndex].userId,
        );
        notifyListeners();
      }

    } catch (e) {
      print("Error updating order status: $e");
    }
  }

  /// Helper method to get item name based on language preference
  String getItemName(Map<String, dynamic> item, {bool useTeluguName = false}) {
    if (useTeluguName && item.containsKey('telugu_name')) {
      return item['telugu_name'] ?? item['name'] ?? 'Unknown Item';
    }
    return item['name'] ?? 'Unknown Item';
  }

  /// Get orders with item names in specified language
  List<Order> getOrdersWithLanguage({bool useTeluguNames = false}) {
    if (!useTeluguNames) {
      return _orders;
    }

    // Return orders with Telugu names displayed
    return _orders.map((order) {
      final translatedItems = order.items.map((item) {
        final translatedItem = Map<String, dynamic>.from(item);
        if (item.containsKey('telugu_name')) {
          translatedItem['display_name'] = item['telugu_name'];
        } else {
          translatedItem['display_name'] = item['name'];
        }
        return translatedItem;
      }).toList();

      return Order(
        id: order.id,
        items: translatedItems,
        total: order.total,
        location: order.location,
        status: order.status,
        time: order.time,
        userId: order.userId,
      );
    }).toList();
  }
}
