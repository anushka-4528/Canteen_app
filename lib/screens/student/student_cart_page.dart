import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Still needed for address selection warning
import 'package:provider/provider.dart';
// Removed Razorpay import as it's handled by the service
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// Removed Firestore import as it's handled by the service
// import 'package:cloud_firestore/cloud_firestore.dart';

// Assuming Address model is defined in address_service.dart or a model file
import '../../services/address_service.dart';
import '../../services/cart_service.dart';
import '../../services/menu_services.dart';
import '../../services/payment_service.dart';
// Removed PaymentSuccessPage import, navigation handled by service
// import 'payment_success_page.dart';


class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Removed Razorpay instance and related variables/methods
  // late Razorpay _razorpay;
  // double _amountInRupees = 0.0; // Calculate locally in build method

  @override
  void initState() {
    super.initState();
    // Removed Razorpay initialization
    // It's good practice to load initial data here if needed, e.g., address
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<AddressService>(context, listen: false).loadSelectedAddress();
    // });
  }

  @override
  void dispose() {
    // Removed Razorpay cleanup
    super.dispose();
  }

  // Removed _handleSuccess, _handleError, _handleExternalWallet
  // These are now handled within PaymentService

  @override
  Widget build(BuildContext context) {
    // Access providers
    final cartService = Provider.of<CartService>(context);
    final menuService = Provider.of<MenuService>(context);
    final addressService = Provider.of<AddressService>(context);
    // Access PaymentService only when needed (in onPressed), not listening here
    // final paymentService = Provider.of<PaymentService>(context, listen: false);

    final cartItems = cartService.cartItems;
    // Ensure loadSelectedAddress has been called somewhere (e.g., in initState or main.dart)
    final selectedAddress = addressService.selectedAddress ?? "Select Address";

    // Calculate the total amount - Moved calculation directly into build
    double amountInRupees = cartItems.fold<double>(0.0, (sum, item) {
      // Ensure item map contains 'id', 'price', and 'quantity' keys
      final itemId = item['id'];
      final itemPrice = item['price'] as num?; // Cast to num? for safety
      final itemQuantity = item['quantity'] as int?; // Cast to int? for safety

      if (itemId == null || itemPrice == null || itemQuantity == null) {
        print("Warning: Cart item missing id, price, or quantity. Item: $item");
        return sum; // Skip this item if data is invalid
      }

      // Check stock using the valid itemId
      return menuService.isInStock(itemId)
          ? sum + (itemPrice.toDouble() * itemQuantity.toDouble())
          : sum;
    });

    int amountInPaise = (amountInRupees * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'), // Updated title
        backgroundColor: const Color(0xFF757373), // Consider using Theme colors
      ),
      body: cartItems.isEmpty
          ? const Center(
          child: Text(
            "Your cart is empty.",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ))
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
                  // Safe access to item properties
                  final itemId = item['id'];
                  final itemName = item['name'] as String? ?? 'Unknown Item';
                  final itemPrice = item['price'] as num? ?? 0.0;
                  final itemQuantity = item['quantity'] as int? ?? 0;

                  if (itemId == null) {
                    // Optionally render a placeholder for invalid items
                    return Card(child: ListTile(title: Text("Invalid item data")));
                  }

                  final inStock = menuService.isInStock(itemId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(itemName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                              ),
                              if (!inStock)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: const Text('Out of Stock',
                                      style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            inStock
                                ? '₹${itemPrice.toStringAsFixed(2)}'
                                : '₹0.00', // Show 0 if out of stock
                            style: TextStyle(
                                fontSize: 14,
                                color: inStock ? Colors.black54 : Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              if (inStock)
                                Row(
                                  children: [
                                    // Decrease Quantity Button
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20), // Smaller icon
                                      onPressed: itemQuantity > 1
                                          ? () => cartService.decreaseQuantity(itemId)
                                          : () => cartService.removeItemFromCart(itemId), // Remove if quantity becomes 0
                                      tooltip: 'Decrease quantity',
                                    ),
                                    Text('$itemQuantity',
                                        style:
                                        const TextStyle(fontSize: 16)),
                                    // Increase Quantity Button
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20), // Smaller icon
                                      onPressed: () => cartService.increaseQuantity(itemId),
                                      tooltip: 'Increase quantity',
                                    ),
                                  ],
                                )
                              else
                                const Text('Unavailable',
                                    style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),

                              // Remove Item Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, // Use outline icon
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    cartService.removeItemFromCart(itemId),
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
                            : 'To: $selectedAddress', // Clearer label
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15, // Slightly smaller
                            fontWeight: selectedAddress == "Select Address"
                                ? FontWeight.normal
                                : FontWeight.w500,
                            color: selectedAddress == "Select Address"
                                ? Colors.redAccent // Highlight if not selected
                                : Colors.black87
                        )
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
            const Divider(), // Add a divider

            // Total & Checkout Button Area
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Display Total Amount
                  Text('Total: ₹${amountInRupees.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),

                  // Checkout Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment, color: Colors.white, size: 18),
                    label: const Text('Proceed to Pay', // More descriptive
                        style: TextStyle(color: Colors.white)),
                    onPressed: (amountInPaise <= 0 || cartItems.isEmpty) // Disable if cart is empty or total is zero
                        ? null // Disable button
                        : () {
                      // Validate address selection
                      if (selectedAddress == "Select Address") {
                        Fluttertoast.showToast( // Use Fluttertoast for simple messages
                          msg: 'Please select a delivery address first.',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.redAccent,
                          textColor: Colors.white,
                        );
                        return; // Stop execution
                      }

                      // --- Initiate Payment ---
                      final paymentService = Provider.of<PaymentService>(context, listen: false);
                      paymentService.openCheckout(
                        amount: amountInPaise,
                        deliveryAddress: selectedAddress, // Pass the selected address
                        // Optional: You can add a description
                        // description: "Order from Canteen App"
                      );
                      // --- Payment process is now handled by PaymentService ---
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (amountInPaise <= 0 || cartItems.isEmpty) ? Colors.grey : Colors.deepPurple, // Use a theme color, disable visually
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)), // More rounded
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjust padding
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to show the address selection modal sheet
  void _showAddressSelectionSheet(BuildContext context, AddressService addressService, String currentSelectedAddress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take up more height if needed
      shape: const RoundedRectangleBorder( // Add rounded corners to the sheet
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (_) => Padding( // Add padding to constrain height and allow safe areas
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox( // Constrain max height
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6, // Max 60% of screen height
          ),
          child: Column( // Use Column for title + list
            mainAxisSize: MainAxisSize.min, // Take minimum height
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Adjusted padding
                child: Text(
                  "Select Delivery Address",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), // Bolder title
                ),
              ),
              const Divider(height: 1, thickness: 1), // Thicker divider
              // Make the list scrollable if addresses exceed available space
              Expanded( // Use Expanded instead of Flexible for scrollable content in Column
                child: ListView(
                  // No shrinkWrap needed when using Expanded
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: addressService.addresses.isEmpty
                      ? [const ListTile(title: Center(child: Text("No addresses available.")))] // Handle empty addresses
                      : addressService.addresses
                      .map((addr) => ListTile(
                    leading: Icon(
                      addr.title == currentSelectedAddress
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: addr.title == currentSelectedAddress
                          ? Theme.of(context).primaryColor // Use theme color
                          : Colors.grey,
                    ),
                    title: Text(addr.title),
                    // *** REMOVED subtitle line as Address model has no details field ***
                    onTap: () {
                      addressService.selectAddress(addr.title);
                      Navigator.pop(context); // Close the bottom sheet
                    },
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
