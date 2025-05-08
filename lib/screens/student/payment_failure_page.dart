import 'package:flutter/material.dart';

class PaymentFailurePage extends StatelessWidget {
  final String errorMessage;

  const PaymentFailurePage({Key? key, required this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Failed'), backgroundColor: Colors.red),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 60),
            const SizedBox(height: 20),
            const Text('Payment Failed', style: TextStyle(fontSize: 20, color: Colors.red)),
            const SizedBox(height: 20),
            Text(errorMessage, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}