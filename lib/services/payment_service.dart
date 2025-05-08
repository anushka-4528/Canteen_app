// import 'package:flutter/material.dart';
// import '../../screens/student/payment_failure_page.dart';
// import 'package:flutter_application5/screens/student/payment_success_page.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class PaymentService extends ChangeNotifier {
//   late final Razorpay _razorpay;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   int? _latestAmount;
//   String? _currentDeliveryAddress; // To store the address temporarily
//   final BuildContext context; // Keep context if needed for navigation FROM the service
//
//   // Constructor now only takes context (or potentially nothing if context isn't needed here)
//   PaymentService(this.context) { // <--- Modified constructor
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }
//
//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }
//
//   /// Opens the Razorpay checkout with the given [amount] in paise.
//   void openCheckout({
//     required int amount,
//     required String deliveryAddress, // <--- Added deliveryAddress parameter here
//     String description = 'Canteen Order',
//   }) {
//     _latestAmount = amount;
//     _currentDeliveryAddress = deliveryAddress; // <-- Store the address
//
//     final user = _auth.currentUser;
//     if (user == null) {
//       print('User is not logged in');
//       // Maybe show a snackbar or dialog using the 'context' if needed
//       return;
//     }
//
//     final options = {
//       'key': 'rzp_test_e0wRer1OCMA2HN', // Replace with your Razorpay test key
//       'amount': amount,
//       'name': 'Your Canteen Name',
//       'description': description,
//       'prefill': {
//         'contact': user.phoneNumber ?? '',
//         'email': user.email ?? '',
//       },
//       'currency': 'INR',
//     };
//
//     try {
//       _razorpay.open(options);
//     } catch (e) {
//       print('Error opening Razorpay: $e');
//       // Handle error display if needed
//     }
//   }
//
//   /// Handle payment success callback
//   void _handleSuccess(PaymentSuccessResponse response) async {
//     // Use the stored delivery address
//     if (_currentDeliveryAddress == null) {
//       print('Error: Delivery address was not set before payment success.');
//       // Handle this critical error appropriately
//       _handleError(PaymentFailureResponse(-1, 'Internal Error: Missing delivery address', null)); // Simulate error
//       return;
//     }
//
//     try {
//       final user = _auth.currentUser!;
//       final txn = {
//         'uid': user.uid,
//         'orderId': response.orderId,
//         'paymentId': response.paymentId,
//         'signature': response.signature,
//         'amount': _latestAmount,
//         'timestamp': FieldValue.serverTimestamp(),
//         'deliveryAddress': _currentDeliveryAddress, // <--- Use stored address
//       };
//
//       // Store transaction details in Firestore
//       await _firestore.collection('transactions').add(txn);
//       print('Transaction successful: ${response.paymentId}');
//
//       // Add the order to the 'orders' collection after payment success
//       await _firestore.collection('orders').add({
//         'uid': user.uid,
//         'orderId': response.orderId,
//         'amount': _latestAmount,
//         'deliveryAddress': _currentDeliveryAddress,
//         'orderStatus': 'Placed', // Default status
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//
//       print('Order placed successfully for user: ${user.uid}');
//
//       // Use the context passed in the constructor for navigation
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentSuccessPage(
//             paymentId: response.paymentId ?? "N/A",
//             deliveryAddress: _currentDeliveryAddress!, // <-- Use stored address
//             amount: _latestAmount ?? 0,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error writing to Firestore: $e');
//       // Handle Firestore write error
//       _handleError(PaymentFailureResponse(-1, 'Failed to save transaction: $e', null)); // Simulate error
//     } finally {
//       _currentDeliveryAddress = null; // Clear address after use
//       _latestAmount = null; // Clear amount
//     }
//   }
//
//   /// Handle payment failure callback
//   void _handleError(PaymentFailureResponse response) {
//     print('Payment failed: ${response.code} | ${response.message}');
//     // Use the context passed in the constructor for navigation
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => PaymentFailurePage(
//           errorMessage: response.message ?? "Unknown error occurred.",
//         ),
//       ),
//     );
//     _currentDeliveryAddress = null; // Clear address on error too
//     _latestAmount = null; // Clear amount
//   }
//
//   /// Handle external wallet callback
//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print('External wallet selected: ${response.walletName}');
//   }
// }
