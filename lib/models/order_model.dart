import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final List<Map<String, dynamic>> items;
  final double total;
  final String location;
  final String status;
  final Timestamp? time;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.location,
    required this.status,
    this.time,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      items: List<Map<String, dynamic>>.from(data['items']),
      total: (data['total'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      status: data['status'] ?? '',
      time: data['time'],
    );
  }
}
