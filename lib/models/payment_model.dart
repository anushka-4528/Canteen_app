import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ Required for Timestamp

class PaymentModel {
  final String orderId;
  final double amount;
  final String status;
  final String? paymentUrl;
  final String? qrCodeUrl;
  final DateTime timestamp;

  PaymentModel({
    required this.orderId,
    required this.amount,
    required this.status,
    this.paymentUrl,
    this.qrCodeUrl,
    required this.timestamp,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      orderId: map['orderId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentUrl: map['paymentUrl'],
      qrCodeUrl: map['qrCodeUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'amount': amount,
      'status': status,
      'paymentUrl': paymentUrl,
      'qrCodeUrl': qrCodeUrl,
      'timestamp': Timestamp.fromDate(timestamp), // 🔁 Store as Firestore Timestamp
    };
  }
}
