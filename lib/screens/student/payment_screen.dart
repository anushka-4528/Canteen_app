import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/order_model.dart' as mymodel;
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import 'package:provider/provider.dart';
import 'payment_success_page.dart';
import 'payment_failure_page.dart';

class PaymentPage extends StatefulWidget {
  final int amountInPaise;
  final mymodel.Order order;

  const PaymentPage({
    Key? key,
    required this.amountInPaise,
    required this.order,
  }) : super(key: key);

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
    _startPayment();
  }

  void _startPayment() {
    var options = {
      'key': 'rzp_test_e0wRer1OCMA2HN',
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
      // Save payment details
      await FirebaseFirestore.instance.collection('payments').doc(response.paymentId).set({
        'userId': user.uid,
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'amount': widget.amountInPaise / 100,
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add the order and get the document ID
      final docRef = await FirebaseFirestore.instance.collection('canteenOrders').add({
        'items': widget.order.items,
        'total': widget.order.total,
        'location': widget.order.location,
        'status': 'Pending', // ✅ enforce default status
        'time': FieldValue.serverTimestamp(),
      });


      // Clear cart
      Provider.of<CartService>(context, listen: false).clearCart();

      // Navigate to success screen with Firestore orderId
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            paymentId: response.paymentId ?? '',
            deliveryAddress: widget.order.location,
            amount: widget.amountInPaise,
            orderId: docRef.id, // ✅ This fixes the error
          ),
        ),
      );
    }
  }

  void _handleError(PaymentFailureResponse response) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentFailurePage(
          errorMessage: response.message ?? 'Something went wrong',
        ),
      ),
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
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}