// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class OrderStatusPage extends StatelessWidget {
//   final String orderId;
//
//   const OrderStatusPage({Key? key, required this.orderId}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         title: const Text('Order Status', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black87),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('canteenOrders')
//             .doc(orderId)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text('Order not found',
//                       style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500)
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           final orderData = snapshot.data!.data() as Map<String, dynamic>;
//           final status = orderData['status'] ?? 'Unknown';
//           final items = orderData['items'] as List<dynamic>;
//           final location = orderData['location'] ?? 'Unknown';
//           final total = orderData['total'] ?? 0.0;
//           final timestamp = orderData['timestamp'] as Timestamp? ?? Timestamp.now();
//           final orderTime = DateFormat('MMM d, h:mm a').format(timestamp.toDate());
//           final estimatedDelivery = orderData['estimatedDelivery'] ?? '15-20 min';
//
//           // If the order is delivered, pop the screen after a delay
//           if (status == 'Delivered') {
//             Future.delayed(const Duration(seconds: 5), () {
//               if (Navigator.canPop(context)) Navigator.pop(context);
//             });
//           }
//
//           return SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Order ID and Timestamp
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(16),
//                   color: Colors.white,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('Order #${orderId.substring(0, 8).toUpperCase()}',
//                               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
//                           ),
//                           Text(orderTime,
//                               style: TextStyle(color: Colors.grey[600], fontSize: 14)
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text('Estimated delivery: $estimatedDelivery',
//                           style: TextStyle(color: Colors.grey[700], fontSize: 14)
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // Status Timeline
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   color: Colors.white,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Delivery Status',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                       ),
//                       const SizedBox(height: 24),
//
//                       // Timeline
//                       _buildStatusTimeline(context, status),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 8),
//
//                 // Order Details
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(20),
//                   color: Colors.white,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text('Order Details',
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
//                       ),
//                       const SizedBox(height: 16),
//
//                       // Delivery Location
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(Icons.location_on, color: Colors.grey[700], size: 20),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text('Delivery Location',
//                                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(location,
//                                     style: TextStyle(color: Colors.grey[700], fontSize: 14)
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const Divider(height: 30),
//
//                       // Order Items
//                       ...items.map((item) {
//                         final name = item['name'] ?? '';
//                         final quantity = item['quantity'] ?? 1;
//                         final price = item['price'] ?? 0.0;
//
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 12),
//                           child: Row(
//                             children: [
//                               Container(
//                                 width: 36,
//                                 height: 36,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: Colors.orange[50],
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text('$quantity',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Text(name,
//                                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                                 ),
//                               ),
//                               Text('₹${(price * quantity).toStringAsFixed(2)}',
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                               ),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//
//                       const Divider(height: 30),
//
//                       // Total
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text('Total',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                           Text('₹${total.toStringAsFixed(2)}',
//                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // Help Button
//                 if (status != 'Delivered')
//                   Center(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.support_agent),
//                       label: const Text('Need Help?'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[200],
//                         foregroundColor: Colors.black87,
//                         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       onPressed: () {
//                         // Show help dialog or navigate to help page
//                         ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Support feature coming soon'))
//                         );
//                       },
//                     ),
//                   ),
//
//                 const SizedBox(height: 40),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
//     final statuses = ['Preparing', 'Ready', 'On the way', 'Delivered'];
//     int currentStep = statuses.indexWhere((s) => s == currentStatus);
//     if (currentStep == -1) currentStep = 0;
//
//     return Column(
//       children: List.generate(statuses.length, (index) {
//         final isActive = index <= currentStep;
//         final isCompleted = index < currentStep;
//
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Status circle
//             Column(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: isActive ? Colors.green : Colors.grey[300],
//                     shape: BoxShape.circle,
//                   ),
//                   child: isCompleted
//                       ? const Icon(Icons.check, color: Colors.white, size: 16)
//                       : isActive
//                       ? const Icon(Icons.circle, color: Colors.white, size: 8)
//                       : null,
//                 ),
//                 if (index < statuses.length - 1)
//                   Container(
//                     width: 2,
//                     height: 40,
//                     color: isCompleted ? Colors.green : Colors.grey[300],
//                   ),
//               ],
//             ),
//             const SizedBox(width: 16),
//             // Status text and description
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     statuses[index],
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                       color: isActive ? Colors.black : Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _getStatusDescription(statuses[index]),
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   SizedBox(height: index < statuses.length - 1 ? 24 : 0),
//                 ],
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
//
//   String _getStatusDescription(String status) {
//     switch (status) {
//       case 'Preparing':
//         return 'Your order is being prepared in the kitchen';
//       case 'Ready':
//         return 'Your order is ready for pickup';
//       case 'On the way':
//         return 'Your order is on the way to your location';
//       case 'Delivered':
//         return 'Your order has been delivered. Enjoy!';
//       default:
//         return '';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderStatusPage extends StatefulWidget {
  final String orderId;

  const OrderStatusPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Order Status',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('canteenOrders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return _buildError('Order not found');
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final status = orderData['status'] ?? 'Unknown';

          if (status == 'Delivered') {
            return _buildDeliveredMessage();
          }

          return _buildOrderDetails(orderData);
        },
      ),
    );
  }

  Widget _buildDeliveredMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 20),
          const Text(
            'Order Delivered!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
                fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(Map<String, dynamic> orderData) {
    final status = orderData['status'] ?? 'Unknown';
    final items = orderData['items'] as List<dynamic>;
    final location = orderData['location'] ?? 'Unknown';
    final total = orderData['total'] ?? 0.0;
    final timestamp = orderData['timestamp'] as Timestamp? ?? Timestamp.now();
    final orderTime = DateFormat('MMM d, h:mm a').format(timestamp.toDate());
    final estimatedDelivery = orderData['estimatedDelivery'] ?? '15-20 min';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(orderTime,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Estimated delivery: $estimatedDelivery',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildStatusTimeline(status),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery Location',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(location,
                              style: TextStyle(
                                  color: Colors.grey[700], fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(height: 30),

                ...items.map((item) {
                  final name = item['name'] ?? '';
                  final quantity = item['quantity'] ?? 1;
                  final price = item['price'] ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('$quantity',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700])),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500)),
                        ),
                        Text('₹${(price * quantity).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }).toList(),

                const Divider(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(String currentStatus) {
    final statuses = ['Preparing', 'Ready', 'On the way', 'Delivered'];
    int currentStep = statuses.indexWhere((s) => s == currentStatus);
    if (currentStep == -1) currentStep = 0;

    return Column(
      children: List.generate(statuses.length, (index) {
        final isActive = index <= currentStep;
        final isCompleted = index < currentStep;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : isActive
                      ? const Icon(Icons.circle, color: Colors.white, size: 8)
                      : null,
                ),
                if (index < statuses.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statuses[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(statuses[index]),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: index < statuses.length - 1 ? 24 : 0),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'Preparing':
        return 'Your order is being prepared in the kitchen';
      case 'Ready':
        return 'Your order is ready for pickup';
      case 'On the way':
        return 'Your order is on the way to your location';
      case 'Delivered':
        return 'Your order has been delivered. Enjoy!';
      default:
        return '';
    }
  }
}