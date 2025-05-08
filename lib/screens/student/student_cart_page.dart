// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart'; // Still needed for address selection warning
// import 'package:provider/provider.dart';
// // Removed Razorpay import as it's handled by the service
// // import 'package:razorpay_flutter/razorpay_flutter.dart';
// // Removed Firestore import as it's handled by the service
// // import 'package:cloud_firestore/cloud_firestore.dart';
//
// // Assuming Address model is defined in address_service.dart or a model file
// import '../../services/address_service.dart';
// import '../../services/cart_service.dart';
// import '../../services/menu_services.dart';
// import '../../services/payment_service.dart';
// // Removed PaymentSuccessPage import, navigation handled by service
// // import 'payment_success_page.dart';
//
//
// class CartPage extends StatefulWidget {
//   @override
//   State<CartPage> createState() => _CartPageState();
// }
//
// class _CartPageState extends State<CartPage> {
//   // Removed Razorpay instance and related variables/methods
//   // late Razorpay _razorpay;
//   // double _amountInRupees = 0.0; // Calculate locally in build method
//
//   @override
//   void initState() {
//     super.initState();
//     // Removed Razorpay initialization
//     // It's good practice to load initial data here if needed, e.g., address
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   Provider.of<AddressService>(context, listen: false).loadSelectedAddress();
//     // });
//   }
//
//   @override
//   void dispose() {
//     // Removed Razorpay cleanup
//     super.dispose();
//   }
//
//   // Removed _handleSuccess, _handleError, _handleExternalWallet
//   // These are now handled within PaymentService
//
//   @override
//   Widget build(BuildContext context) {
//     // Access providers
//     final cartService = Provider.of<CartService>(context);
//     final menuService = Provider.of<MenuService>(context);
//     final addressService = Provider.of<AddressService>(context);
//     // Access PaymentService only when needed (in onPressed), not listening here
//     // final paymentService = Provider.of<PaymentService>(context, listen: false);
//
//     final cartItems = cartService.cartItems;
//     // Ensure loadSelectedAddress has been called somewhere (e.g., in initState or main.dart)
//     final selectedAddress = addressService.selectedAddress ?? "Select Address";
//
//     // Calculate the total amount - Moved calculation directly into build
//     double amountInRupees = cartItems.fold<double>(0.0, (sum, item) {
//       // Ensure item map contains 'id', 'price', and 'quantity' keys
//       final itemId = item['id'];
//       final itemPrice = item['price'] as num?; // Cast to num? for safety
//       final itemQuantity = item['quantity'] as int?; // Cast to int? for safety
//
//       if (itemId == null || itemPrice == null || itemQuantity == null) {
//         print("Warning: Cart item missing id, price, or quantity. Item: $item");
//         return sum; // Skip this item if data is invalid
//       }
//
//       // Check stock using the valid itemId
//       return menuService.isInStock(itemId)
//           ? sum + (itemPrice.toDouble() * itemQuantity.toDouble())
//           : sum;
//     });
//
//     int amountInPaise = (amountInRupees * 100).toInt();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Cart',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)), // Updated title
//         backgroundColor: const Color(0xFF757373), // Consider using Theme colors
//       ),
//       body: cartItems.isEmpty
//           ? const Center(
//           child: Text(
//             "Your cart is empty.",
//             style: TextStyle(fontSize: 18, color: Colors.grey),
//           ))
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
//                   // Safe access to item properties
//                   final itemId = item['id'];
//                   final itemName = item['name'] as String? ?? 'Unknown Item';
//                   final itemPrice = item['price'] as num? ?? 0.0;
//                   final itemQuantity = item['quantity'] as int? ?? 0;
//
//                   if (itemId == null) {
//                     // Optionally render a placeholder for invalid items
//                     return Card(child: ListTile(title: Text("Invalid item data")));
//                   }
//
//                   final inStock = menuService.isInStock(itemId);
//
//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 16),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16)),
//                     elevation: 4,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(itemName,
//                                     style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w600)),
//                               ),
//                               if (!inStock)
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 8, vertical: 4),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red[100],
//                                     borderRadius:
//                                     BorderRadius.circular(12),
//                                   ),
//                                   child: const Text('Out of Stock',
//                                       style: TextStyle(
//                                           color: Colors.red,
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold)),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             inStock
//                                 ? '₹${itemPrice.toStringAsFixed(2)}'
//                                 : '₹0.00', // Show 0 if out of stock
//                             style: TextStyle(
//                                 fontSize: 14,
//                                 color: inStock ? Colors.black54 : Colors.grey),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                             children: [
//                               if (inStock)
//                                 Row(
//                                   children: [
//                                     // Decrease Quantity Button
//                                     IconButton(
//                                       icon: const Icon(Icons.remove_circle_outline, size: 20), // Smaller icon
//                                       onPressed: itemQuantity > 1
//                                           ? () => cartService.decreaseQuantity(itemId)
//                                           : () => cartService.removeItemFromCart(itemId), // Remove if quantity becomes 0
//                                       tooltip: 'Decrease quantity',
//                                     ),
//                                     Text('$itemQuantity',
//                                         style:
//                                         const TextStyle(fontSize: 16)),
//                                     // Increase Quantity Button
//                                     IconButton(
//                                       icon: const Icon(Icons.add_circle_outline, size: 20), // Smaller icon
//                                       onPressed: () => cartService.increaseQuantity(itemId),
//                                       tooltip: 'Increase quantity',
//                                     ),
//                                   ],
//                                 )
//                               else
//                                 const Text('Unavailable',
//                                     style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
//
//                               // Remove Item Button
//                               IconButton(
//                                 icon: const Icon(Icons.delete_outline, // Use outline icon
//                                     color: Colors.redAccent),
//                                 onPressed: () =>
//                                     cartService.removeItemFromCart(itemId),
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
//                         selectedAddress == "Select Address"
//                             ? 'Select Delivery Address'
//                             : 'To: $selectedAddress', // Clearer label
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             fontSize: 15, // Slightly smaller
//                             fontWeight: selectedAddress == "Select Address"
//                                 ? FontWeight.normal
//                                 : FontWeight.w500,
//                             color: selectedAddress == "Select Address"
//                                 ? Colors.redAccent // Highlight if not selected
//                                 : Colors.black87
//                         )
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       // Show address selection bottom sheet
//                       _showAddressSelectionSheet(context, addressService, selectedAddress);
//                     },
//                     child: const Text('Change'),
//                   ),
//                 ],
//               ),
//             ),
//             const Divider(), // Add a divider
//
//             // Total & Checkout Button Area
//             Padding(
//               padding: const EdgeInsets.only(top: 8, bottom: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Display Total Amount
//                   Text('Total: ₹${amountInRupees.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                           fontSize: 18, fontWeight: FontWeight.bold)),
//
//                   // Checkout Button
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.payment, color: Colors.white, size: 18),
//                     label: const Text('Proceed to Pay', style: TextStyle(color: Colors.white)),
//                     onPressed: (amountInPaise <= 0 || cartItems.isEmpty)
//                         ? null // Disable if cart is empty or total is zero
//                         : () {
//                       // Validate address selection
//                       if (selectedAddress == "Select Address") {
//                         Fluttertoast.showToast(
//                           msg: 'Please select a delivery address first.',
//                           toastLength: Toast.LENGTH_LONG,
//                           gravity: ToastGravity.CENTER,
//                           backgroundColor: Colors.redAccent,
//                           textColor: Colors.white,
//                         );
//                         return; // Stop execution
//                       }
//
//                       // Initiate the payment process
//                       final paymentService = Provider.of<PaymentService>(context, listen: false);
//                       paymentService.openCheckout(
//                         amount: amountInPaise,
//                         deliveryAddress: selectedAddress,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: (amountInPaise <= 0 || cartItems.isEmpty) ? Colors.grey : Colors.deepPurple,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     ),
//                   )
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Helper function to show the address selection modal sheet
//   void _showAddressSelectionSheet(BuildContext context, AddressService addressService, String currentSelectedAddress) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true, // Allows sheet to take up more height if needed
//       shape: const RoundedRectangleBorder( // Add rounded corners to the sheet
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
//       ),
//       builder: (_) => Padding( // Add padding to constrain height and allow safe areas
//         padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: ConstrainedBox( // Constrain max height
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.6, // Max 60% of screen height
//           ),
//           child: Column( // Use Column for title + list
//             mainAxisSize: MainAxisSize.min, // Take minimum height
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Adjusted padding
//                 child: Text(
//                   "Select Delivery Address",
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), // Bolder title
//                 ),
//               ),
//               const Divider(height: 1, thickness: 1), // Thicker divider
//               // Make the list scrollable if addresses exceed available space
//               Expanded( // Use Expanded instead of Flexible for scrollable content in Column
//                 child: ListView(
//                   // No shrinkWrap needed when using Expanded
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   children: addressService.addresses.isEmpty
//                       ? [const ListTile(title: Center(child: Text("No addresses available.")))] // Handle empty addresses
//                       : addressService.addresses
//                       .map((addr) => ListTile(
//                     leading: Icon(
//                       addr.title == currentSelectedAddress
//                           ? Icons.radio_button_checked
//                           : Icons.radio_button_unchecked,
//                       color: addr.title == currentSelectedAddress
//                           ? Theme.of(context).primaryColor // Use theme color
//                           : Colors.grey,
//                     ),
//                     title: Text(addr.title),
//                     // *** REMOVED subtitle line as Address model has no details field ***
//                     onTap: () {
//                       addressService.selectAddress(addr.title);
//                       Navigator.pop(context); // Close the bottom sheet
//                     },
//                   ))
//                       .toList(),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../models/order_model.dart' as mymodel;
import 'payment_screen.dart';
import '../../services/address_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final addressService = Provider.of<AddressService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cart',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF757373),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: cartService.getCartItemsStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final cartItems = snapshot.data!;

            final totalPrice = cartItems.fold<double>(
              0,
                  (sum, item) =>
              (item['quantity'] as int) > 0
                  ? sum + (item['price'] as num) * (item['quantity'] as num)
                  : sum,
            );

            if (cartItems.isEmpty) {
              return const Center(child: Text("Your cart is empty"));
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final quantity = item['quantity'] as int? ?? 0;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${(item['price'] as num).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey[700]),
                                    ),
                                    const SizedBox(height: 12),

                                    quantity == 0
                                        ? Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Out of Stock',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            await cartService
                                                .removeItemFromCart(
                                                item['id']);
                                          },
                                        ),
                                      ],
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove,
                                                    size: 18),
                                                onPressed: () async {
                                                  await cartService
                                                      .decreaseQuantity(
                                                      item['id']);
                                                },
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8.0),
                                                child: Text(
                                                  '$quantity',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add,
                                                    size: 18),
                                                onPressed: () async {
                                                  await cartService
                                                      .increaseQuantity(
                                                      item['id']);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            await cartService
                                                .removeItemFromCart(
                                                item['id']);
                                          },
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
                    },
                  ),
                ),

                // Address selection + total + checkout
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Select Delivery Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: addressService.selectedAddress,
                            items: addressService.addresses
                                .map<DropdownMenuItem<String>>((address) {
                              return DropdownMenuItem<String>(
                                value: address.title,
                                child: Text(
                                  address.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                              );
                            }).toList(),
                            onChanged: (newAddress) {
                              if (newAddress != null) {
                                addressService.selectAddress(newAddress);
                              }
                            },
                            icon: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total: ₹${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: cartItems.isEmpty ||
                                addressService.selectedAddress == null
                                ? null
                                : () {
                              final orderId = DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString();
                              final order = mymodel.Order(
                                id: orderId,
                                items: List<Map<String, dynamic>>.from(
                                    cartItems),
                                total: totalPrice,
                                location:
                                addressService.selectedAddress!,
                                status: 'Pending',
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PaymentPage(
                                    amountInPaise:
                                    (totalPrice * 100).toInt(),
                                    order: order,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Checkout',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../services/menu_services.dart';
import '../../services/payment_service.dart';
import '../../models/order_model.dart' as mymodel;
import 'payment_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final menuService = Provider.of<MenuService>(context);
    final addressService = Provider.of<AddressService>(context);

    final cartItems = cartService.cartItems;
    final selectedAddress = addressService.selectedAddress ?? "Select Address";

    double totalPrice = cartItems.fold<double>(0.0, (sum, item) {
      final itemId = item['id'];
      final itemPrice = item['price'] as num?;
      final itemQuantity = item['quantity'] as int?;

      if (itemId == null || itemPrice == null || itemQuantity == null) {
        print("Warning: Cart item missing id, price, or quantity. Item: $item");
        return sum;
      }

      final inStock = menuService.isInStock(itemId);
      return inStock
          ? sum + (itemPrice.toDouble() * itemQuantity.toDouble())
          : sum;
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

            // Address selector + total + checkout
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
                          : 'To: $selectedAddress', // Clearer label
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15, // Slightly smaller
                        fontWeight: selectedAddress == "Select Address"
                            ? FontWeight.normal
                            : FontWeight.w500,
                        color: selectedAddress == "Select Address"
                            ? Colors.redAccent // Highlight if not selected
                            : Colors.black87,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show address selection bottom sheet
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
                        onPressed: cartItems.isEmpty || selectedAddress == "Select Address"
                            ? null
                            : () {
                          final orderId = DateTime.now().millisecondsSinceEpoch.toString();
                          final order = mymodel.Order(
                            id: orderId,
                            items: List<Map<String, dynamic>>.from(cartItems),
                            total: totalPrice,
                            location: selectedAddress,
                            status: 'Pending',
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
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
}
