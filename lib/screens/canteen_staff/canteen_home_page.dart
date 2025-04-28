import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/menu_item.dart';
import '../../services/menu_services.dart';
import '../../services/cart_service.dart';
import '../../services/translation_service.dart';
import '../auth/login_selection.dart';

class HomePage extends StatefulWidget {


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<MenuItem> _filteredItems = [];
  List<MenuItem> _originalItems = [];
  bool _isTelugu = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
     // Set language based on passed parameter
    final menuService = Provider.of<MenuService>(context, listen: false);
    _filteredItems = menuService.menuItems;
    _originalItems = menuService.menuItems;
  }



  void _filterItems(String query) {
    final menuService = Provider.of<MenuService>(context, listen: false);
    final filteredItems = menuService.menuItems
        .where((item) =>
        item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredItems = filteredItems;
    });
  }

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
                            final isInStock = item.inStock;

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
                                                // Create a new instance of MenuItem with updated inStock value
                                                final updatedItem = MenuItem(
                                                  id: item.id,
                                                  name: item.name,
                                                  price: item.price,
                                                  categoryId: item.categoryId,
                                                  inStock: val, // Update stock status
                                                  description: item.description,
                                                );

                                                // Replace the old item with the updated one
                                                int index = filteredItems.indexOf(item);
                                                filteredItems[index] = updatedItem;
                                              });

                                              // Update the stock status in the database
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isTelugu ? 'హోమ్' : 'Home Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF757373),
        elevation: 0,
        actions: [

          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () => _openSearchSheet(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        _isTelugu ? 'ఆహారాన్ని శోధించండి...' : 'Search for food...',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Spacer(),
                      Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginSelection()),
          (route) => false,
    );
  }
}
