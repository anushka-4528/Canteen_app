// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class MenuItem {
//   final String id;
//   final String name;
//   final String description;
//   final String categoryId; // Updated to categoryId
//   final bool inStock;
//   final double price;
//
//   MenuItem({
//     required this.id,
//     required this.name,
//     required this.description,
//
//     required this.categoryId, // Updated to categoryId
//     required this.inStock,
//     required this.price,
//   });
//
//   // Convert a document from Firestore into a MenuItem object
//   factory MenuItem.fromMap(String id, Map<String, dynamic> data) {
//     return MenuItem(
//       id: id,
//       name: data['name'] ?? '',
//       description: data['description'] ?? '',
//
//       categoryId: data['categoryId'] ?? '',
//       // Updated to categoryId
//       inStock: data['inStock'] ?? true,
//       price: (data['price'] ?? 0).toDouble(),
//     );
//   }
//
//   // Convert a MenuItem object into a map for Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'description': description,
//
//       'categoryId': categoryId, // Updated to categoryId
//       'inStock': inStock,
//       'price': price,
//     };
//   }
//
//   // Method to copy the MenuItem with updated inStock value
//   MenuItem copyWith(
//       {String? id, String? name, String? description, String? imageUrl, String? categoryId, bool? inStock}) {
//     return MenuItem(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       description: description ?? this.description,
//
//       categoryId: categoryId ?? this.categoryId,
//       // Updated to categoryId
//       inStock: inStock ?? this.inStock,
//       price: price ?? this.price,
//     );
//   }
// }
//
//
//
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final String categoryId; // Updated to categoryId
  final bool inStock;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId, // Updated to categoryId
    required this.inStock,
    required this.price,
  });

  // Convert a document from Firestore into a MenuItem object
  factory MenuItem.fromMap(String id, Map<String, dynamic> data) {
    return MenuItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      inStock: data['inStock'] ?? true,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  // Convert a MenuItem object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId, // Updated to categoryId
      'inStock': inStock,
      'price': price,
    };
  }

  // Method to copy the MenuItem with updated inStock value
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    bool? inStock,
    double? price,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      inStock: inStock ?? this.inStock,
      price: price ?? this.price,
    );
  }
}

