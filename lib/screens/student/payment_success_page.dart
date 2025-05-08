import 'package:flutter/material.dart';
import '../canteen_staff/order_status_page.dart'; // Import the status page

class PaymentSuccessPage extends StatelessWidget {
  final String paymentId;
  final String deliveryAddress;
  final int amount;
  final String orderId; // New field to track the actual Firestore order

  const PaymentSuccessPage({
    Key? key,
    required this.paymentId,
    required this.deliveryAddress,
    required this.amount,
    required this.orderId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text('Payment Successful!', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text('Payment ID: $paymentId'),
              Text('Delivery Address: $deliveryAddress'),
              Text('Amount Paid: ₹${amount / 100}'),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderStatusPage(orderId: orderId),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long, color: Colors.white),
                label: const Text('Track My Order', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}