import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save payment details in Firestore under 'payments' collection
  Future<void> storePaymentDetails(
      String orderId,
      double amount,
      String status,
      String email, {
        String? userId,
      }) async {
    await _db.collection('payments').doc(orderId).set({
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'email': email,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update payment status in 'payments' collection
  Future<void> updatePaymentStatus(String orderId, String newStatus) async {
    final docRef = _db.collection('payments').doc(orderId);
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Save order details in 'orders' collection
  Future<void> saveOrderDetails(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add({
      ...orderData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update order payment status by orderId field (not doc ID)
  Future<void> updateOrderPaymentStatus(String orderId, String status) async {
    final orderQuery = _db.collection('orders').where('orderId', isEqualTo: orderId).limit(1);
    final snapshot = await orderQuery.get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'paymentStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get live updates of payment status for an orderId
  Stream<DocumentSnapshot> getPaymentStream(String orderId) {
    return _db.collection('payments').doc(orderId).snapshots();
  }

  // Get all orders for a user (for history or admin view)
  Stream<QuerySnapshot> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
