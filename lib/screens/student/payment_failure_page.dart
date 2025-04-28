import 'package:flutter/material.dart';

class PaymentFailurePage extends StatelessWidget {
  final String errorMessage;

  PaymentFailurePage({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Failed'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 60),
            SizedBox(height: 20),
            Text(
              'Payment Failed',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
            SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
