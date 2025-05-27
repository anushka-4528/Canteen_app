import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../services/menu_services.dart';
import '../../services/cart_service.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final menuService = Provider.of<MenuService>(context);
    final cartService = Provider.of<CartService>(context);

    // Filter the favorites items from the menu items
    final favoriteItems = menuService.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF757373),
        elevation: 4,
      ),
      body: favoriteItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No favorites yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              'Add items to your favorites by tapping the heart icon',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: favoriteItems.length,
          itemBuilder: (context, index) {
            final item = favoriteItems[index];
            final cartItem = cartService.cartItems.firstWhere(
                  (element) => element['id'] == item.id,
              orElse: () => {},
            );
            final quantity = cartItem.isNotEmpty ? cartItem['quantity'] ?? 0 : 0;
            // FIX: Use menuService.isInStock() instead of item.inStock for consistency
            final isInStock = menuService.isInStock(item.id);

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
                                  ),
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
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Favorite Icon
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red[50],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    menuService.toggleFavorite(item, false); // Remove from favorites
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
                                      onTap: isInStock ? () => cartService.decreaseQuantity(item.id) : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isInStock ? Color(0xFFEEEEEE) : Colors.grey[300],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(7),
                                            bottomLeft: Radius.circular(7),
                                          ),
                                        ),
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                            Icons.remove,
                                            color: isInStock ? Color(0xFF757373) : Colors.grey[500],
                                            size: 20
                                        ),
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
                                          color: isInStock ? Colors.black : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: isInStock ? () => cartService.increaseQuantity(item.id) : null,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: isInStock ? Color(0xFFEEEEEE) : Colors.grey[300],
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(7),
                                            bottomRight: Radius.circular(7),
                                          ),
                                        ),
                                        width: 36,
                                        height: 36,
                                        child: Icon(
                                            Icons.add,
                                            color: isInStock ? Color(0xFF757373) : Colors.grey[500],
                                            size: 20
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : ElevatedButton(
                                onPressed: isInStock
                                    ? () => cartService.addItemToCart({
                                  'id': item.id,
                                  'name': item.name,
                                  'price': item.price,
                                })
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
        ),
      ),
    );
  }
}