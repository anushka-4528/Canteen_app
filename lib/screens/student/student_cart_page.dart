// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:provider/provider.dart';
// import '../../services/address_service.dart';
// import '../../services/cart_service.dart';
// import '../../services/menu_services.dart';
// import '../../services/payment_service.dart';
// import '../../models/order_model.dart' as mymodel;
// import 'payment_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CartPage extends StatefulWidget {
//   @override
//   State<CartPage> createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   final TextEditingController _addressController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     super.dispose();
//   }
//
//   void _showAddressSelectionSheet(BuildContext context, AddressService addressService, String selectedAddress) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return ListView.builder(
//           itemCount: addressService.addresses.length,
//           itemBuilder: (context, index) {
//             final address = addressService.addresses[index];
//             return ListTile(
//               title: Text(address.title),
//               onTap: () {
//                 addressService.selectAddress(address.title);
//                 Navigator.pop(context);
//               },
//             );
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final cartService = Provider.of<CartService>(context);
//     final menuService = Provider.of<MenuService>(context);
//     final addressService = Provider.of<AddressService>(context);
//
//     final cartItems = cartService.cartItems;
//     final selectedAddress = addressService.selectedAddress ?? "Select Address";
//     final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
//
//     // Filter out out-of-stock items for order calculation
//     final inStockItems = cartItems.where((item) {
//       final itemId = item['id'];
//       return itemId != null && menuService.isInStock(itemId);
//     }).toList();
//
//     // Calculate total price only for in-stock items
//     double totalPrice = inStockItems.fold<double>(0.0, (sum, item) {
//       final itemPrice = item['price'] as num? ?? 0.0;
//       final itemQuantity = item['quantity'] as int? ?? 0;
//       return sum + (itemPrice.toDouble() * itemQuantity.toDouble());
//     });
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         backgroundColor: const Color(0xFF757373),
//       ),
//       body: cartItems.isEmpty
//           ? const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)))
//           : Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // Cart items list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, i) {
//                   final item = cartItems[i];
//                   final itemId = item['id'];
//                   final itemName = item['name'] as String? ?? 'Unknown Item';
//                   final itemPrice = item['price'] as num? ?? 0.0;
//                   final itemQuantity = item['quantity'] as int? ?? 0;
//
//                   if (itemId == null) {
//                     return Card(child: ListTile(title: Text("Invalid item data")));
//                   }
//
//                   final inStock = menuService.isInStock(itemId);
//
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                               ),
//                               if (!inStock)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)),
//                                   child: const Text('Out of Stock', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Text(inStock ? '₹${itemPrice.toStringAsFixed(2)}' : '₹0.00',
//                               style: TextStyle(fontSize: 14, color: inStock ? Colors.black54 : Colors.grey)),
//                           const SizedBox(height: 12),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               if (inStock)
//                                 Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.remove_circle_outline, size: 20),
//                                       onPressed: itemQuantity > 1
//                                           ? () => cartService.decreaseQuantity(itemId)
//                                           : () => cartService.removeItemFromCart(itemId),
//                                       tooltip: 'Decrease quantity',
//                                     ),
//                                     Text('$itemQuantity', style: const TextStyle(fontSize: 16)),
//                                     IconButton(
//                                       icon: const Icon(Icons.add_circle_outline, size: 20),
//                                       onPressed: () => cartService.increaseQuantity(itemId),
//                                       tooltip: 'Increase quantity',
//                                     ),
//                                   ],
//                                 )
//                               else
//                                 const Text('Unavailable', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
//
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
//                                 onPressed: () => cartService.removeItemFromCart(itemId),
//                                 tooltip: 'Remove item',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Show warning if there are out-of-stock items
//             if (cartItems.length > inStockItems.length)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 8),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   border: Border.all(color: Colors.orange),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.warning, color: Colors.orange[700], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Out-of-stock items will be excluded from your order',
//                         style: TextStyle(color: Colors.orange[700], fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//             // Address selector
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       selectedAddress == "Select Address"
//                           ? 'Select Delivery Address'
//                           : 'To: $selectedAddress',
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: selectedAddress == "Select Address"
//                             ? FontWeight.normal
//                             : FontWeight.w500,
//                         color: selectedAddress == "Select Address"
//                             ? Colors.redAccent
//                             : Colors.black87,
//                       ),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       _showAddressSelectionSheet(context, addressService, selectedAddress);
//                     },
//                     child: const Text('Change'),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(),
//
//             // Checkout section
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Total: ₹${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       ElevatedButton(
//                         onPressed: inStockItems.isEmpty || selectedAddress == "Select Address"
//                             ? null
//                             : () {
//                           // Show confirmation dialog if there are out-of-stock items
//                           if (cartItems.length > inStockItems.length) {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return AlertDialog(
//                                   title: const Text('Confirm Order'),
//                                   content: Text(
//                                     'Your cart contains ${cartItems.length - inStockItems.length} out-of-stock item(s) that will be excluded from your order. Do you want to proceed?',
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () => Navigator.of(context).pop(),
//                                       child: const Text('Cancel'),
//                                     ),
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.of(context).pop();
//                                         _proceedToCheckout(inStockItems, totalPrice, selectedAddress, userId);
//                                       },
//                                       child: const Text('Proceed'),
//                                     ),
//                                   ],
//                                 );
//                               },
//                             );
//                           } else {
//                             _proceedToCheckout(inStockItems, totalPrice, selectedAddress, userId);
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: (inStockItems.isEmpty || selectedAddress == "Select Address") ? Colors.grey : Colors.black,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                         ),
//                         child: const Text('Checkout', style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _proceedToCheckout(List<Map<String, dynamic>> inStockItems, double totalPrice, String selectedAddress, String userId) {
//     final orderId = DateTime.now().millisecondsSinceEpoch.toString();
//
//     // Create order with only in-stock items
//     final order = mymodel.Order(
//       id: orderId,
//       items: List<Map<String, dynamic>>.from(inStockItems), // Only include in-stock items
//       total: totalPrice,
//       location: selectedAddress,
//       status: 'Pending',
//       userId: userId,
//       time: Timestamp.now(),
//     );
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PaymentPage(
//           amountInPaise: (totalPrice * 100).toInt(),
//           order: order,
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../services/menu_services.dart';
import '../../services/payment_service.dart';
import '../../models/order_model.dart' as mymodel;
import 'payment_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _showAddressSelectionSheet(BuildContext context, AddressService addressService, String selectedAddress) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: addressService.addresses.length,
          itemBuilder: (context, index) {
            final address = addressService.addresses[index];
            return ListTile(
              title: Text(address.title),
              onTap: () {
                addressService.selectAddress(address.title);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  // Helper method to get Telugu name for an item
  String? _getTeluguName(String itemId, MenuService menuService) {
    try {
      // Use the existing getItemById method from MenuService
      final item = menuService.getItemById(itemId);
      // Return the translatedName field from the MenuItem object
      return item?.translatedName;
    } catch (e) {
      print("Error getting Telugu name for item $itemId: $e");
      return null;
    }
  }

  // Method to enrich cart items with Telugu names
  List<Map<String, dynamic>> _enrichItemsWithTelugu(List<Map<String, dynamic>> items, MenuService menuService) {
    return items.map((item) {
      final enrichedItem = Map<String, dynamic>.from(item);
      final itemId = item['id'];

      if (itemId != null) {
        final teluguName = _getTeluguName(itemId, menuService);
        if (teluguName != null) {
          enrichedItem['telugu_name'] = teluguName;
        }
      }

      return enrichedItem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final menuService = Provider.of<MenuService>(context);
    final addressService = Provider.of<AddressService>(context);

    final cartItems = cartService.cartItems;
    final selectedAddress = addressService.selectedAddress ?? "Select Address";
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Filter out out-of-stock items for order calculation
    final inStockItems = cartItems.where((item) {
      final itemId = item['id'];
      return itemId != null && menuService.isInStock(itemId);
    }).toList();

    // Calculate total price only for in-stock items
    double totalPrice = inStockItems.fold<double>(0.0, (sum, item) {
      final itemPrice = item['price'] as num? ?? 0.0;
      final itemQuantity = item['quantity'] as int? ?? 0;
      return sum + (itemPrice.toDouble() * itemQuantity.toDouble());
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF757373),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Cart items list
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, i) {
                  final item = cartItems[i];
                  final itemId = item['id'];
                  final itemName = item['name'] as String? ?? 'Unknown Item';
                  final itemPrice = item['price'] as num? ?? 0.0;
                  final itemQuantity = item['quantity'] as int? ?? 0;

                  if (itemId == null) {
                    return Card(child: ListTile(title: Text("Invalid item data")));
                  }

                  final inStock = menuService.isInStock(itemId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(itemName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              if (!inStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Out of Stock', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(inStock ? '₹${itemPrice.toStringAsFixed(2)}' : '₹0.00',
                              style: TextStyle(fontSize: 14, color: inStock ? Colors.black54 : Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (inStock)
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: itemQuantity > 1
                                          ? () => cartService.decreaseQuantity(itemId)
                                          : () => cartService.removeItemFromCart(itemId),
                                      tooltip: 'Decrease quantity',
                                    ),
                                    Text('$itemQuantity', style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () => cartService.increaseQuantity(itemId),
                                      tooltip: 'Increase quantity',
                                    ),
                                  ],
                                )
                              else
                                const Text('Unavailable', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),

                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => cartService.removeItemFromCart(itemId),
                                tooltip: 'Remove item',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Show warning if there are out-of-stock items
            if (cartItems.length > inStockItems.length)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Out-of-stock items will be excluded from your order',
                        style: TextStyle(color: Colors.orange[700], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),

            // Address selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedAddress == "Select Address"
                          ? 'Select Delivery Address'
                          : 'To: $selectedAddress',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selectedAddress == "Select Address"
                            ? FontWeight.normal
                            : FontWeight.w500,
                        color: selectedAddress == "Select Address"
                            ? Colors.redAccent
                            : Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showAddressSelectionSheet(context, addressService, selectedAddress);
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Checkout section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: ₹${totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: inStockItems.isEmpty || selectedAddress == "Select Address"
                            ? null
                            : () {
                          // Show confirmation dialog if there are out-of-stock items
                          if (cartItems.length > inStockItems.length) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Order'),
                                  content: Text(
                                    'Your cart contains ${cartItems.length - inStockItems.length} out-of-stock item(s) that will be excluded from your order. Do you want to proceed?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _proceedToCheckout(inStockItems, totalPrice, selectedAddress, userId, menuService);
                                      },
                                      child: const Text('Proceed'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _proceedToCheckout(inStockItems, totalPrice, selectedAddress, userId, menuService);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (inStockItems.isEmpty || selectedAddress == "Select Address") ? Colors.grey : Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Checkout', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout(List<Map<String, dynamic>> inStockItems, double totalPrice, String selectedAddress, String userId, MenuService menuService) {
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Enrich items with Telugu names before creating the order
    final enrichedItems = _enrichItemsWithTelugu(inStockItems, menuService);

    // Create order with enriched items (containing both English and Telugu names)
    final order = mymodel.Order(
      id: orderId,
      items: enrichedItems,
      total: totalPrice,
      location: selectedAddress,
      status: 'Pending',
      userId: userId,
      time: Timestamp.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          amountInPaise: (totalPrice * 100).toInt(),
          order: order,
        ),
      ),
    );
  }
}