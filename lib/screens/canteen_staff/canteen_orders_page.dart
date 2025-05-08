import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';

class CanteenOrdersPage extends StatefulWidget {
  const CanteenOrdersPage({Key? key}) : super(key: key);

  @override
  State<CanteenOrdersPage> createState() => _CanteenOrdersPageState();
}

class _CanteenOrdersPageState extends State<CanteenOrdersPage> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final List<Order> allOrders = orderService.orders;

    List<Order> filteredOrders = allOrders.where((order) {
      switch (selectedFilter) {
        case 'Completed':
          return order.status == 'Delivered';
        case 'Pending':
          return order.status != 'Ready' && order.status != 'Delivered';
        case 'Ready':
          return order.status == 'Ready';
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Orders',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF757373),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterGrid(),
            const SizedBox(height: 16),
            Expanded(
              child: filteredOrders.isEmpty
                  ? const Center(child: Text("No orders found"))
                  : ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGrid() {
    return SizedBox(
      height: 220,
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.0,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildFilterTile(
            label: "All Orders",
            filter: "All",
            icon: Icons.list,
            color: Colors.blue.shade50,
            borderColor: Colors.blue,
            iconColor: Colors.blue,
          ),
          _buildFilterTile(
            label: "Completed Orders",
            filter: "Completed",
            icon: Icons.check_circle_outline,
            color: Colors.orange.shade50,
            borderColor: Colors.orange,
            iconColor: Colors.orange,
          ),
          _buildFilterTile(
            label: "Pending",
            filter: "Pending",
            icon: Icons.hourglass_bottom,
            color: Colors.red.shade50,
            borderColor: Colors.red,
            iconColor: Colors.red,
          ),
          _buildFilterTile(
            label: "Ready for Pickup",
            filter: "Ready",
            icon: Icons.check_circle,
            color: Colors.green.shade50,
            borderColor: Colors.green,
            iconColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile({
    required String label,
    required String filter,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required Color iconColor,
  }) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? borderColor.withOpacity(0.2) : color,
          border: Border.all(color: isSelected ? borderColor : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final itemNames = order.items.map((item) => item['name']).join(', ');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemNames,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text('Order ID: ${order.id}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text('Delivery Address: ${order.location}', style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹${order.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    if (order.status == 'Delivered')
                      Text(
                        'Delivered',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (order.status != 'Delivered')
                      ElevatedButton(
                        onPressed: () async {
                          final newStatus = order.status == 'Ready' ? 'Delivered' : 'Ready';
                          await Provider.of<OrderService>(context, listen: false)
                              .updateOrderStatus(order.id, newStatus);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: order.status == 'Ready' ? Colors.blue : Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          order.status == 'Ready' ? 'Mark as Delivered' : 'Mark as Ready',
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
