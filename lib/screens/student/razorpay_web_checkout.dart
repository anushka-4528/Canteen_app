import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RazorpayWebCheckout extends StatefulWidget {
  final int amountInPaise;  // e.g. 15000 for ₹150.00
  final String keyId;       // your Razorpay key

  const RazorpayWebCheckout({
    Key? key,
    required this.amountInPaise,
    required this.keyId,
  }) : super(key: key);

  @override
  State<RazorpayWebCheckout> createState() => _RazorpayWebCheckoutState();
}

class _RazorpayWebCheckoutState extends State<RazorpayWebCheckout> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    final amount = widget.amountInPaise;
    final key   = widget.keyId;
    final rupees = (amount / 100).toStringAsFixed(2);

    return """
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
  </head>
  <body style="display:flex;justify-content:center;align-items:center;height:100vh;margin:0">
    <button id="rzp-button" style="
      padding:16px 32px;
      font-size:18px;
      background:#528FF0;
      color:#fff;
      border:none;
      border-radius:8px;
      cursor:pointer;
    ">
      Pay ₹$rupees via UPI
    </button>

    <script>
      var options = {
        key: '$key',
        amount: $amount,
        name: 'My Canteen',
        description: 'Order Payment',
        method: { upi: true, card: false, netbanking: false, wallet: false, emi: false },
        prefill: { email:'', contact:'' },
        theme: { color:'#528FF0' }
      };
      var rzp = new Razorpay(options);
      document.getElementById('rzp-button').onclick = function(e) {
        rzp.open();
        e.preventDefault();
      };
      // Listen to events if you want to relay back to Flutter:
      rzp.on('payment.success', function(response) {
        window.flutter_inappwebview.callHandler('success', JSON.stringify(response));
      });
      rzp.on('payment.error', function(response) {
        window.flutter_inappwebview.callHandler('error', JSON.stringify(response));
      });
    </script>
  </body>
</html>
""";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay via UPI')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
