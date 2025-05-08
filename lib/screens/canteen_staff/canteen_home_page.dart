import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/menu_item.dart';
import '../../models/order_model.dart';
import '../../services/cart_service.dart';
import '../../services/menu_services.dart';
import '../../services/order_service.dart';
import '../auth/login_selection.dart';

class CanteenHomePage extends StatefulWidget {
  const CanteenHomePage({Key? key}) : super(key: key);

  @override
  State<CanteenHomePage> createState() => _CanteenHomePageState();
}

class _CanteenHomePageState extends State<CanteenHomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isTelugu = false;

  void _openSearchSheet() {
    final menuService = Provider.of<MenuService>(context, listen: false);
    final cartService = Provider.of<CartService>(context, listen: false);
    List<MenuItem> allItems = menuService.menuItems;
    List<MenuItem> filteredItems = List.from(allItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: _isTelugu ? 'ఆహారాన్ని శోధించండి...' : 'Search food...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              filteredItems = allItems
                                  .where((item) => item.name
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                                  .toList();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            final cartItem = cartService.cartItems.firstWhere(
                                  (cartItem) => cartItem['id'] == item.id,
                              orElse: () => {},
                            );
                            final quantity = cartItem.isNotEmpty ? cartItem['quantity'] : 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Switch(
                                            value: item.inStock,
                                            activeColor: Colors.green,
                                            inactiveThumbColor: Colors.red[300],
                                            onChanged: (val) {
                                              setState(() {
                                                final updatedItem = MenuItem(
                                                  id: item.id,
                                                  name: item.name,
                                                  price: item.price,
                                                  categoryId: item.categoryId,
                                                  inStock: val,
                                                  description: item.description,
                                                  translatedName: item.translatedName,
                                                );

                                                int index = filteredItems.indexOf(item);
                                                filteredItems[index] = updatedItem;
                                              });

                                              menuService.updateStockStatus(item.id, val);
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.inStock ? 'In Stock' : 'Out of Stock',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: item.inStock ? Colors.green : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);
    final nonDeliveredOrders = orderService.orders.where((order) => order.status != 'Delivered').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Home', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF757373),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginSelection()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _openSearchSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _isTelugu ? 'ఆహారాన్ని శోధించండి...' : 'Search for food...',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: nonDeliveredOrders.isEmpty
                ? const Center(child: Text("No orders yet"))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: nonDeliveredOrders.length,
              itemBuilder: (context, index) {
                final order = nonDeliveredOrders[index];
                final itemNames = order.items
                    .map((item) => item['name'] as String)
                    .toList()
                    .join(', ');

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Items: ',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              TextSpan(
                                text: itemNames,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Order ID: ${order.id}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Location: ${order.location}', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text('Total: ₹${order.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final newStatus = order.status == 'Ready' ? 'Delivered' : 'Ready';
                            await orderService.updateOrderStatus(order.id, newStatus);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Order marked as $newStatus!")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: order.status == 'Ready' ? Colors.blue : Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            order.status == 'Ready' ? 'Mark as Delivered' : 'Mark as Ready',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
