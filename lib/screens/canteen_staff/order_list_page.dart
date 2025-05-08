import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrderListPage extends StatelessWidget {
  final String title;
  final String filterStatus;

  const OrderListPage({
    Key? key,
    required this.title,
    required this.filterStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final List<Order> allOrders = orderService.orders;

    final List<Order> filteredOrders;
    if (filterStatus == 'All') {
      filteredOrders = allOrders;
    } else if (filterStatus == 'Pending') {
      filteredOrders = allOrders.where((order) => order.status != 'Ready' && order.status != 'Delivered').toList();
    } else if (filterStatus == 'Ready') {
      filteredOrders = allOrders.where((order) => order.status == 'Ready').toList();
    } else {
      filteredOrders = [];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: filteredOrders.isEmpty
          ? Center(child: Text(filterStatus == 'All' ? "No orders found" : "No $filterStatus orders"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final Order order = filteredOrders[index];
          final itemNames = order.items.map((item) => item['name']).join(', ');

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: ListTile(
              title: Text(itemNames, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Order ID: ${order.id}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('Delivery Address: ${order.location}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('Total: ₹${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    order.status,
                    style: TextStyle(
                      color: order.status == 'Ready'
                          ? Colors.green
                          : order.status == 'Delivered'
                          ? Colors.blue
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (order.status != 'Delivered')
                    ElevatedButton(
                      onPressed: () async {
                        final newStatus = order.status == 'Ready' ? 'Delivered' : 'Ready';
                        await Provider.of<OrderService>(context, listen: false)
                            .updateOrderStatus(order.id, newStatus);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: order.status == 'Ready' ? Colors.blue : Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        order.status == 'Ready' ? 'Deliver' : 'Ready',
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
