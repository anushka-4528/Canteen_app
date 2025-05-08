import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreviousOrdersPage extends StatefulWidget {
  const PreviousOrdersPage({Key? key}) : super(key: key);

  @override
  State<PreviousOrdersPage> createState() => _PreviousOrdersPageState();
}

class _PreviousOrdersPageState extends State<PreviousOrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  String? _errorMessage;
  List<DocumentSnapshot> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from Firestore
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Please log in to view orders.";
        });
        return;
      }

      // Step 1: Get payment records for current user
      final paymentSnapshot = await _firestore
          .collection('payment')
          .where('userId', isEqualTo: user.uid)
          .get();

      final orderIds = paymentSnapshot.docs
          .map((doc) => doc.data()['orderId'] as String?)
          .where((id) => id != null && id!.isNotEmpty)
          .cast<String>()
          .toList();

      if (orderIds.isEmpty) {
        setState(() {
          _orders = [];
          _isLoading = false;
        });
        return;
      }

      // Step 2: Fetch corresponding orders from canteenOrders
      final ordersSnapshot = await _firestore
          .collection('canteenOrders')
          .where(FieldPath.documentId, whereIn: orderIds)
          .orderBy('time', descending: true)
          .get();

      setState(() {
        _orders = ordersSnapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load orders: $e";
        _isLoading = false;
      });
    }
  }

  //rom an order
  List<Map<String, dynamic>> extractOrderItems(Map<String, dynamic> data) {
    final rawItems = data['items'];
    if (rawItems is List) {
      return rawItems.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  // Reorder the items from previous order and add to the user's cart
  Future<void> _reorderItems(List<Map<String, dynamic>> items) async {
    final cartRef = _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('cart');

    try {
      for (var item in items) {
        final itemId = item['id'];
        if (itemId == null || itemId == '') continue;

        print('🛒 Adding item to cart: ${item['name']} (id: $itemId)');

        await cartRef.doc(itemId).set({
          'id': itemId,
          'name': item['name'] ?? 'Unknown Item',
          'price': item['price'] ?? 0,
          'quantity': item['quantity'] ?? 1,
          'timestamp': Timestamp.now(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Items added to cart!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("❌ Reorder error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add items: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Orders', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF757373),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No previous orders found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Browse Menu'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          final data = order.data() as Map<String, dynamic>;
          final orderItems = extractOrderItems(data);
          final timestamp = data['time'] as Timestamp?;
          final orderDate = timestamp?.toDate();

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 6)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (orderDate != null)
                        Text(
                          '${orderDate.day}/${orderDate.month}/${orderDate.year}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const Divider(),
                  ...orderItems.map((item) {
                    final name = item['name'] ?? 'Unknown';
                    final quantity = item['quantity'] ?? 1;
                    final price = item['price'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$name x$quantity'),
                          Text('₹$price'),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () => _reorderItems(orderItems),
                        child: const Text('Reorder'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
