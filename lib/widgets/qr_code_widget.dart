import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeWidget extends StatelessWidget {
  final String qrCodeData;
  final double amount;
  final String? orderId;

  const QRCodeWidget({
    super.key,
    required this.qrCodeData,
    required this.amount,
    this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan to Pay ₹${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 220.0,
              backgroundColor: Colors.white,
            ),
            SizedBox(height: 16),
            Text('Campus Canteen',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue[700])),
            Text(
              orderId != null
                  ? 'Order ID: $orderId'
                  : 'UPI ID: canteen@campus',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Scan this QR code with any UPI app',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
