import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusBanner extends StatelessWidget {
  final String orderId;

  const OrderStatusBanner({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('canteenOrders').doc(orderId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return SizedBox.shrink();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'Pending';

        if (status == 'Delivered') return SizedBox.shrink(); // Hide banner when delivered

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: status == 'Ready' ? Colors.orange : Colors.grey[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  status == 'Ready' ? Icons.notifications_active : Icons.hourglass_empty,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Order $status',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}