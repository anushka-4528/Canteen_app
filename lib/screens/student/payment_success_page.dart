import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatelessWidget {
  final String paymentId;
  final String deliveryAddress;
  final int amount;

  // Update the constructor to accept these parameters
  PaymentSuccessPage({
    required this.paymentId,
    required this.deliveryAddress,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Success'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text('Payment ID: $paymentId'),
            Text('Delivery Address: $deliveryAddress'),
            Text('Amount Paid: ₹${amount / 100}'), // Convert paise to INR
          ],
        ),
      ),
    );
  }
}
