import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final int amountInPaise;

  const PaymentPage({super.key, required this.amountInPaise});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _startPayment() async {
    var options = {
      'key': 'rzp_test_e0wRer1OCMA2HN', // 🔑 Replace with your actual Razorpay Key
      'amount': widget.amountInPaise,
      'name': 'Test Canteen',
      'description': 'Food Order',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@gmail.com',
      }
    };
    _razorpay.open(options);
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('payments').doc(response.paymentId).set({
        'userId': user.uid,
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'amount': widget.amountInPaise / 100, // Convert to ₹
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful')),
    );
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double displayAmount = widget.amountInPaise / 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Razorpay Payment"),
        backgroundColor: Color(0xFF757373),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _startPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text("Pay ₹$displayAmount", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
