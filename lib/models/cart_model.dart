class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final int quantity;
  final bool inStock;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
    required this.inStock,
  });

  factory CartItem.fromMap(Map<String, dynamic> data, String documentId) {
    return CartItem(
      id: documentId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      inStock: data['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'inStock': inStock,
    };
  }
}

