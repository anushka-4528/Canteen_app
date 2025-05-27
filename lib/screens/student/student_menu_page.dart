import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../services/menu_services.dart';
import '../../services/cart_service.dart';
import '../../models/category.dart';
import '../../services/translation_service.dart';

class StudentMenuScreen extends StatefulWidget {
  final String initialCategory;

  StudentMenuScreen({required this.initialCategory});

  @override
  _StudentMenuScreenState createState() => _StudentMenuScreenState();
}

class _StudentMenuScreenState extends State<StudentMenuScreen> {
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategory;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final menuService = Provider.of<MenuService>(context, listen: false);
      menuService.fetchMenuItems();
      menuService.fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF757373),
        elevation: 4,
      ),
      body: Consumer<MenuService>(
        builder: (context, menuService, child) {
          if (menuService.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (menuService.error.isNotEmpty) {
            return Center(child: Text(menuService.error));
          }

          List<MenuItem> filteredItems = menuService.getItemsByCategory(
            menuService.menuItems,
            _selectedCategoryId,
          );

          return Row(
            children: [
              // Category Sidebar
              Container(
                width: 120,
                color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: menuService.categories.length,
                  itemBuilder: (context, index) {
                    final category = menuService.categories[index];
                    return _buildCategoryButton(category);
                  },
                ),
              ),
              // Menu Items
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _buildMenuItemsList(filteredItems, cartService, menuService),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryButton(Category category) {
    bool isSelected = _selectedCategoryId == category.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = category.id;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border(
            bottom: BorderSide(color: Colors.grey[400]!),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(category.imageAsset, fit: BoxFit.contain),
            ),
            SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Color(0xFF757373) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemsList(List<MenuItem> items, CartService cartService, MenuService menuService) {
    if (items.isEmpty) {
      return Center(child: Text("No items found in this category"));
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFavorite = menuService.favorites.any((fav) => fav.id == item.id);
        final cartItem = cartService.cartItems.firstWhere(
              (element) => element['id'] == item.id,
          orElse: () => {},
        );
        final quantity = cartItem.isNotEmpty ? cartItem['quantity'] ?? 0 : 0;

        // Get inStock status directly from the MenuItem object
        final isInStock = item.inStock;

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isInStock ? Colors.black87 : Colors.grey[600],
                                )
                            ),
                          ),
                          if (!isInStock)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Text(
                                'Out of Stock',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                          '\₹${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          )
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Favorite Icon
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFavorite ? Colors.red[50] : Colors.grey[100],
                            ),
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey[600],
                                size: 22,
                              ),
                              onPressed: () {
                                menuService.toggleFavorite(item, !isFavorite);
                              },
                            ),
                          ),

                          // Add to cart button or quantity controls
                          quantity > 0
                              ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Color(0xFF757373)),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    print('Decrease quantity for item: ${item.id}'); // Debug log
                                    await cartService.decreaseQuantity(item.id);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                      ),
                                    ),
                                    width: 36,
                                    height: 36,
                                    child: Icon(Icons.remove, color: Color(0xFF757373), size: 20),
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$quantity',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    print('Increase quantity for item: ${item.id}'); // Debug log
                                    await cartService.increaseQuantity(item.id);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xFFEEEEEE),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(7),
                                        bottomRight: Radius.circular(7),
                                      ),
                                    ),
                                    width: 36,
                                    height: 36,
                                    child: Icon(Icons.add, color: Color(0xFF757373), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ElevatedButton(
                            onPressed: isInStock
                                ? () async {
                              print('Add to cart button pressed for item: ${item.name}'); // Debug log

                              try {
                                await cartService.addItemToCart({
                                  'id': item.id,
                                  'name': item.name,
                                  'price': item.price,
                                   // Include image if available
                                });

                                // Show success feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.name} added to cart!'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                print('Error adding to cart: $e');
                                // Show error feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to add item to cart'),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                                : null,
                            child: Text('Add to Cart'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: isInStock ? Colors.green : Colors.grey[400],
                              disabledBackgroundColor: Colors.grey[300],
                              disabledForegroundColor: Colors.grey[600],
                              elevation: isInStock ? 2 : 0,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
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
    );
  }
}