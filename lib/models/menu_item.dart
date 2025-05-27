import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  String id;
  final String name;
  final String description;
  final String categoryId;
  final bool inStock;
  final double price;
  final String translatedName;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.translatedName,
    required this.categoryId,
    required this.inStock,
    required this.price,
  });

  factory MenuItem.fromMap(String id, Map<String, dynamic> data) {
    return MenuItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      // Fix: Check for both 'teluguName' and 'translatedName' fields
      translatedName: data['teluguName'] ?? data['translatedName'] ?? '',
      categoryId: data['categoryId'] ?? '',
      inStock: data['inStock'] ?? true,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'teluguName': translatedName, // Store as 'teluguName' to match Firestore
      'categoryId': categoryId,
      'inStock': inStock,
      'price': price,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    bool? inStock,
    double? price,
    String? translatedName,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      translatedName: translatedName ?? this.translatedName,
      categoryId: categoryId ?? this.categoryId,
      inStock: inStock ?? this.inStock,
      price: price ?? this.price,
    );
  }
}